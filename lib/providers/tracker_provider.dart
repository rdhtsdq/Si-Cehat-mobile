import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../core/database/database_helper.dart';
import '../data/models/measurement_model.dart';
import '../data/models/activity_log_model.dart';

class TrackerProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Measurements state
  List<MeasurementModel> _measurements = [];
  bool _isLoading = true;
  dynamic _currentChildId;

  // Activities & Habits state
  List<ActivityLogModel> _activities = [];
  int _waterGlasses = 0;
  bool _isLoadingActivities = false;
  DateTime _activityDate = DateTime.now();

  List<MeasurementModel> get measurements => _measurements;
  bool get isLoading => _isLoading;
  MeasurementModel? get latestMeasurement =>
      _measurements.isNotEmpty ? _measurements.last : null;

  List<ActivityLogModel> get activities => _activities;
  int get waterGlasses => _waterGlasses;
  bool get isLoadingActivities => _isLoadingActivities;
  DateTime get activityDate => _activityDate;

  int get totalActiveMinutes => _activities
      .where((a) => a.category == 'Aktivitas Fisik')
      .fold(0, (sum, a) => sum + a.durationMinutes);

  double get activityPercentage => (totalActiveMinutes / 60.0).clamp(0.0, 1.0);

  String get activityStatus {
    if (totalActiveMinutes >= 60) return 'Sangat Aktif';
    if (totalActiveMinutes >= 30) return 'Cukup Aktif';
    return 'Kurang Aktif';
  }

  // --- GROWTH MEASUREMENTS METHODS ---
  Future<void> loadMeasurements(dynamic childId) async {
    _currentChildId = childId;
    _isLoading = true;
    notifyListeners();

    final token = await _apiClient.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final res = await _apiClient.get(
          ApiConstants.trackerGrowth,
          queryParams: {'childId': childId.toString()},
        );

        if (res.isSuccess && res.data != null) {
          final rawList =
              (res.data['history'] ?? res.data['measurements']) as List<dynamic>?;
          if (rawList != null) {
            _measurements = rawList
                .map((m) => MeasurementModel.fromJson(m as Map<String, dynamic>))
                .toList()
              ..sort((a, b) => a.date.compareTo(b.date));

            _isLoading = false;
            notifyListeners();
            return;
          }
        }
      } catch (e) {
        debugPrint('[TrackerProvider] Remote load measurements error: $e');
      }
    }

    // Local DB fallback
    try {
      _measurements = await _dbHelper.getMeasurements(childId);
    } catch (e) {
      debugPrint('[TrackerProvider] Local load measurements error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addMeasurement(MeasurementModel measurement) async {
    final token = await _apiClient.getToken();
    bool remoteSaved = false;

    if (token != null && token.isNotEmpty) {
      try {
        final res = await _apiClient.post(
          ApiConstants.trackerGrowth,
          body: {
            'childId': measurement.childId.toString(),
            'date': measurement.date,
            'weight': measurement.weight,
            'weightKg': measurement.weight,
            'height': measurement.height,
            'heightCm': measurement.height,
            'source': measurement.source,
            'notes': measurement.notes,
          },
        );
        if (res.isSuccess) {
          remoteSaved = true;
        }
      } catch (e) {
        debugPrint('[TrackerProvider] Remote add measurement error: $e');
      }
    }

    // Save locally to cache/offline
    await _dbHelper.insertMeasurement(measurement);

    if (_currentChildId != null) {
      await loadMeasurements(_currentChildId);
    }
    return remoteSaved;
  }

  Future<void> deleteMeasurement(dynamic id) async {
    final token = await _apiClient.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await _apiClient.delete('${ApiConstants.trackerGrowth}/$id');
      } catch (e) {
        debugPrint('[TrackerProvider] Remote delete measurement error: $e');
      }
    }

    await _dbHelper.deleteMeasurement(id);
    if (_currentChildId != null) {
      await loadMeasurements(_currentChildId);
    }
  }

  // --- ACTIVITIES & HABITS TRACKER METHODS ---
  Future<void> setActivityDate(dynamic childId, DateTime date) async {
    _activityDate = date;
    await loadActivities(childId, date: date);
  }

  Future<void> loadActivities(dynamic childId, {DateTime? date}) async {
    if (date != null) _activityDate = date;
    _currentChildId = childId;
    _isLoadingActivities = true;
    notifyListeners();

    final dateStr = _activityDate.toIso8601String().substring(0, 10);
    final token = await _apiClient.getToken();

    if (token != null && token.isNotEmpty) {
      try {
        final res = await _apiClient.get(
          ApiConstants.trackerActivities,
          queryParams: {
            'childId': childId.toString(),
            'date': dateStr,
          },
        );
        if (res.isSuccess &&
            res.data != null &&
            res.data['activities'] is List) {
          final list = res.data['activities'] as List;
          _activities = list
              .map((a) => ActivityLogModel.fromJson(a as Map<String, dynamic>))
              .toList();

          if (res.data['summary'] is Map &&
              res.data['summary']['waterGlasses'] != null) {
            _waterGlasses =
                (res.data['summary']['waterGlasses'] as num).toInt();
          }

          _isLoadingActivities = false;
          notifyListeners();
          return;
        }
      } catch (e) {
        debugPrint('[TrackerProvider] Remote load activities error: $e');
      }
    }

    // Local DB fallback
    try {
      _activities = await _dbHelper.getActivities(childId, dateStr);
      _waterGlasses = await _dbHelper.getWaterGlasses(childId, dateStr);
    } catch (e) {
      debugPrint('[TrackerProvider] Local load activities error: $e');
    } finally {
      _isLoadingActivities = false;
      notifyListeners();
    }
  }

  Future<bool> addActivity(ActivityLogModel activity) async {
    final token = await _apiClient.getToken();
    bool remoteSaved = false;

    if (token != null && token.isNotEmpty) {
      try {
        final res = await _apiClient.post(
          ApiConstants.trackerActivities,
          body: activity.toJson(),
        );
        if (res.isSuccess) remoteSaved = true;
      } catch (e) {
        debugPrint('[TrackerProvider] Remote add activity error: $e');
      }
    }

    await _dbHelper.insertActivity(activity);
    await loadActivities(activity.childId, date: _activityDate);
    return remoteSaved;
  }

  Future<void> deleteActivity(dynamic id, {dynamic childId}) async {
    final token = await _apiClient.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await _apiClient.delete('${ApiConstants.trackerActivities}/$id');
      } catch (e) {
        debugPrint('[TrackerProvider] Remote delete activity error: $e');
      }
    }

    await _dbHelper.deleteActivity(id);
    if (childId != null) {
      await loadActivities(childId, date: _activityDate);
    }
  }

  Future<void> setWater(dynamic childId, int glasses, {DateTime? date}) async {
    final targetDate = date ?? _activityDate;
    final dateStr = targetDate.toIso8601String().substring(0, 10);
    _waterGlasses = glasses.clamp(0, 20);
    notifyListeners();

    await _dbHelper.setWaterGlasses(childId, dateStr, _waterGlasses);

    // Sync to backend progress
    final token = await _apiClient.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await _apiClient.post(
          ApiConstants.progress,
          body: {
            'childId': childId.toString(),
            'date': dateStr,
            'waterGlasses': _waterGlasses,
            'activityMinutes': totalActiveMinutes,
          },
        );
      } catch (_) {}
    }
  }

  Future<void> incrementWater(dynamic childId, {DateTime? date}) async {
    await setWater(childId, _waterGlasses + 1, date: date);
  }

  Future<void> decrementWater(dynamic childId, {DateTime? date}) async {
    if (_waterGlasses > 0) {
      await setWater(childId, _waterGlasses - 1, date: date);
    }
  }
}
