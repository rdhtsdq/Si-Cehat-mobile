import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';
import '../data/models/mother_model.dart';
import '../data/models/child_model.dart';

class ProfileProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  MotherModel? _mother;
  List<ChildModel> _children = [];
  ChildModel? _activeChild;
  bool _isLoading = true;

  MotherModel? get mother => _mother;
  List<ChildModel> get children => _children;
  ChildModel? get activeChild => _activeChild;
  bool get isLoading => _isLoading;

  ProfileProvider() {
    loadProfiles();
  }

  Future<void> loadProfiles() async {
    _isLoading = true;
    notifyListeners();
    try {
      _mother = await _dbHelper.getMotherProfile();
      _children = await _dbHelper.getChildren();
      _activeChild = await _dbHelper.getActiveChild();
    } catch (e) {
      debugPrint('Error loading profiles: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMother(MotherModel updated) async {
    _mother = updated;
    notifyListeners();
    await _dbHelper.updateMotherProfile(updated);
  }

  Future<void> updateChild(ChildModel updated) async {
    await _dbHelper.updateChild(updated);
    await loadProfiles();
  }

  Future<void> addChild(ChildModel newChild) async {
    await _dbHelper.insertChild(newChild);
    await loadProfiles();
  }

  Future<void> selectActiveChild(int childId) async {
    await _dbHelper.setActiveChild(childId);
    await loadProfiles();
  }

  Future<void> resetAllData() async {
    await _dbHelper.resetDemoData();
    await loadProfiles();
  }
}
