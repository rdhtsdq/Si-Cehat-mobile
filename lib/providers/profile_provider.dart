import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../core/database/database_helper.dart';
import '../data/models/mother_model.dart';
import '../data/models/child_model.dart';

class ProfileProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient.instance;
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

    final token = await _apiClient.getToken();

    if (token != null && token.isNotEmpty) {
      bool apiLoaded = false;
      try {
        final profileRes = await _apiClient.get(ApiConstants.parentProfile);
        final childrenRes = await _apiClient.get(ApiConstants.children);

        if (profileRes.isSuccess && profileRes.data != null) {
          final profileData = profileRes.data['profile'] as Map<String, dynamic>?;
          if (profileData != null) {
            _mother = MotherModel.fromJson(profileData);
          }
        }

        if (childrenRes.isSuccess && childrenRes.data != null) {
          final rawChildren = childrenRes.data['children'] as List<dynamic>?;
          if (rawChildren != null) {
            final prefs = await SharedPreferences.getInstance();
            final savedActiveId = prefs.getString('active_child_id');

            _children = rawChildren
                .map((item) => ChildModel.fromJson(item as Map<String, dynamic>))
                .toList();

            if (_children.isNotEmpty) {
              if (savedActiveId != null) {
                final match = _children.where((c) => c.id.toString() == savedActiveId);
                _activeChild = match.isNotEmpty ? match.first.copyWith(isActive: true) : _children.first.copyWith(isActive: true);
              } else {
                _activeChild = _children.first.copyWith(isActive: true);
              }

              // Update isActive flag across list
              _children = _children.map((c) => c.copyWith(isActive: c.id.toString() == _activeChild?.id.toString())).toList();
            }
            apiLoaded = true;
          }
        }
      } catch (e) {
        debugPrint('[ProfileProvider] Remote load error: $e');
      }

      if (apiLoaded) {
        _isLoading = false;
        notifyListeners();
        return;
      }
    }

    // Fallback to local SQLite database (Demo / Offline mode)
    try {
      _mother = await _dbHelper.getMotherProfile();
      _children = await _dbHelper.getChildren();
      _activeChild = await _dbHelper.getActiveChild();
    } catch (e) {
      debugPrint('[ProfileProvider] Local DB error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMother(MotherModel updated) async {
    _mother = updated;
    notifyListeners();

    final token = await _apiClient.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await _apiClient.put(
          ApiConstants.parentProfile,
          body: {
            'name': updated.name,
            'phone': updated.phone,
            'education': updated.education,
            'occupation': updated.occupation,
            'address': updated.address,
          },
        );
      } catch (e) {
        debugPrint('[ProfileProvider] Remote update mother error: $e');
      }
    }

    await _dbHelper.updateMotherProfile(updated);
  }

  Future<void> addChild(ChildModel newChild) async {
    final token = await _apiClient.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final res = await _apiClient.post(
          ApiConstants.children,
          body: {
            'name': newChild.name,
            'birthDate': newChild.dateOfBirth,
            'gender': newChild.gender,
            'healthHistory': newChild.healthNotes,
          },
        );
        if (res.isSuccess) {
          await loadProfiles();
          return;
        }
      } catch (e) {
        debugPrint('[ProfileProvider] Remote add child error: $e');
      }
    }

    // Fallback to local db
    await _dbHelper.insertChild(newChild);
    await loadProfiles();
  }

  Future<void> updateChild(ChildModel updated) async {
    final token = await _apiClient.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final res = await _apiClient.put(
          '${ApiConstants.children}/${updated.id}',
          body: {
            'name': updated.name,
            'birthDate': updated.dateOfBirth,
            'gender': updated.gender == 'Perempuan' ? 'FEMALE' : 'MALE',
            'healthHistory': updated.healthNotes,
          },
        );
        if (res.isSuccess) {
          await loadProfiles();
          return;
        }
      } catch (e) {
        debugPrint('[ProfileProvider] Remote update child error: $e');
      }
    }

    await _dbHelper.updateChild(updated);
    await loadProfiles();
  }

  Future<void> selectActiveChild(dynamic childId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_child_id', childId.toString());
    } catch (_) {}

    _children = _children.map((c) => c.copyWith(isActive: c.id.toString() == childId.toString())).toList();
    final match = _children.where((c) => c.id.toString() == childId.toString());
    _activeChild = match.isNotEmpty ? match.first : null;
    notifyListeners();

    await _dbHelper.setActiveChild(childId);
  }

  Future<void> resetAllData() async {
    await _dbHelper.resetDemoData();
    await loadProfiles();
  }
}
