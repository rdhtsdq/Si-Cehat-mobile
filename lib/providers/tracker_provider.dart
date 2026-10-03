import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../core/database/database_helper.dart';
import '../data/models/measurement_model.dart';

class TrackerProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<MeasurementModel> _measurements = [];
  bool _isLoading = true;
  dynamic _currentChildId;

  List<MeasurementModel> get measurements => _measurements;
  bool get isLoading => _isLoading;

  MeasurementModel? get latestMeasurement =>
      _measurements.isNotEmpty ? _measurements.last : null;

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
          final rawList = (res.data['history'] ?? res.data['measurements']) as List<dynamic>?;
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
}
