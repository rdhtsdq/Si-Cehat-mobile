import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';
import '../data/models/measurement_model.dart';

class TrackerProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<MeasurementModel> _measurements = [];
  bool _isLoading = true;
  int? _currentChildId;

  List<MeasurementModel> get measurements => _measurements;
  bool get isLoading => _isLoading;

  MeasurementModel? get latestMeasurement =>
      _measurements.isNotEmpty ? _measurements.last : null;

  Future<void> loadMeasurements(int childId) async {
    _currentChildId = childId;
    _isLoading = true;
    notifyListeners();
    try {
      _measurements = await _dbHelper.getMeasurements(childId);
    } catch (e) {
      debugPrint('Error loading measurements: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMeasurement(MeasurementModel measurement) async {
    await _dbHelper.insertMeasurement(measurement);
    if (_currentChildId != null) {
      await loadMeasurements(_currentChildId!);
    }
  }
}
