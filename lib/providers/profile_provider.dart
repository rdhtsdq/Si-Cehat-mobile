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
  bool _isLoading = false;

  MotherModel? get mother => _mother;
  List<ChildModel> get children => _children;
  ChildModel? get activeChild => _activeChild;
  bool get isLoading => _isLoading;

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
          final profileData =
              profileRes.data['profile'] as Map<String, dynamic>?;
          if (profileData != null) {
            _mother = MotherModel.fromJson(profileData);
            await _apiClient.saveGuardianData(profileData);
            apiLoaded = true;
          }
        } else {
          final savedGuardian = await _apiClient.getSavedGuardianData();
          if (savedGuardian != null) {
            _mother = MotherModel.fromJson(savedGuardian);
          }
        }

        if (childrenRes.isSuccess && childrenRes.data != null) {
          final rawChildren = childrenRes.data['children'] as List<dynamic>?;
          if (rawChildren != null) {
            final prefs = await SharedPreferences.getInstance();
            final savedActiveId = prefs.getString('active_child_id');

            _children = rawChildren
                .map(
                  (item) => ChildModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();

            if (_children.isNotEmpty) {
              if (savedActiveId != null) {
                final match = _children.where(
                  (c) => c.id.toString() == savedActiveId,
                );
                _activeChild = match.isNotEmpty
                    ? match.first.copyWith(isActive: true)
                    : _children.first.copyWith(isActive: true);
              } else {
                _activeChild = _children.first.copyWith(isActive: true);
              }

              await prefs.setString(
                'active_child_id',
                _activeChild!.id.toString(),
              );

              _children = _children
                  .map(
                    (c) => c.copyWith(
                      isActive: c.id.toString() == _activeChild?.id.toString(),
                    ),
                  )
                  .toList();
            } else {
              _activeChild = null;
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

    // Fallback to local SQLite database only when in Demo / Offline mode
    final prefs = await SharedPreferences.getInstance();
    final isDemo = prefs.getBool('is_demo_mode') ?? false;
    if (isDemo) {
      try {
        _mother = await _dbHelper.getMotherProfile();
        _children = await _dbHelper.getChildren();
        _activeChild = await _dbHelper.getActiveChild();
      } catch (e) {
        debugPrint('[ProfileProvider] Local DB error: $e');
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  void updateLatestScreening({required String category, required int score}) {
    if (_activeChild == null) return;
    _activeChild = _activeChild!.copyWith(
      latestRiskCategory: category,
      latestRiskScore: score,
    );
    _children = _children
        .map(
          (c) => c.id.toString() == _activeChild!.id.toString()
              ? _activeChild!
              : c,
        )
        .toList();
    notifyListeners();
  }

  void clearSession() {
    _mother = null;
    _children = [];
    _activeChild = null;
    notifyListeners();
  }

  Future<void> updateMother(MotherModel updated) async {
    _mother = updated;
    notifyListeners();

    final token = await _apiClient.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final res = await _apiClient.put(
          ApiConstants.parentProfile,
          body: {
            'name': updated.name,
            'phone': updated.phone,
            'education': updated.education,
            'occupation': updated.occupation,
            'address': updated.address,
          },
        );
        if (res.isSuccess &&
            res.data is Map &&
            res.data['profile'] is Map<String, dynamic>) {
          final serverProfile = res.data['profile'] as Map<String, dynamic>;
          _mother = MotherModel.fromJson(serverProfile);
          await _apiClient.saveGuardianData(serverProfile);
          notifyListeners();
          return;
        }
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
            if (newChild.dateOfBirth.isNotEmpty)
              'birthDate': newChild.dateOfBirth,
            'gender': newChild.gender == 'Perempuan' ? 'FEMALE' : 'MALE',
            if (newChild.healthNotes.isNotEmpty)
              'healthHistory': newChild.healthNotes,
          },
        );
        if (res.isSuccess) {
          final created = res.data is Map ? res.data['child'] : null;
          if (created is Map && created['id'] != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('active_child_id', created['id'].toString());
          }
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
            if (updated.dateOfBirth.isNotEmpty)
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

    _children = _children
        .map((c) => c.copyWith(isActive: c.id.toString() == childId.toString()))
        .toList();
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
