import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../core/services/pending_nutrition_queue.dart';
import '../data/local_food_catalog.dart';
import '../data/models/nutrition_model.dart';

class NutritionProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient.instance;
  final PendingNutritionQueue _pendingQueue = PendingNutritionQueue();

  static const String _catalogCacheKey = 'nutrition_catalog_v1';

  List<FoodItem> _foods = List.from(localFoodCatalog);
  List<NutritionDraftItem> _draft = [];
  NutritionTarget _target = NutritionTarget.akgDefault;
  NutritionSummary? _summary;
  NutritionValues _batchTotals = NutritionValues.zero;

  bool _isLoadingCatalog = false;
  bool _isLoadingTarget = false;
  bool _isLoadingSummary = false;
  bool _isCalculating = false;
  bool _isSaving = false;
  String? _catalogError;
  int _pendingSyncCount = 0;

  List<FoodItem> get foods => _foods;
  List<NutritionDraftItem> get draft => _draft;
  NutritionTarget get target => _target;
  NutritionSummary? get summary => _summary;
  NutritionValues get batchTotals => _batchTotals;
  bool get isLoadingCatalog => _isLoadingCatalog;
  bool get isLoadingTarget => _isLoadingTarget;
  bool get isLoadingSummary => _isLoadingSummary;
  bool get isCalculating => _isCalculating;
  bool get isSaving => _isSaving;
  String? get catalogError => _catalogError;
  int get pendingSyncCount => _pendingSyncCount;
  bool get isOfflineCatalog => _catalogError != null;

  NutritionValues get localDraftTotals => _draft.fold(
        NutritionValues.zero,
        (total, item) => total + item.values,
      );

  NutritionProvider({bool autoLoad = true}) {
    if (autoLoad) {
      loadCatalog();
      _loadPendingCount();
    }
  }

  String _targetCacheKey(String childId) => 'nutrition_target_$childId';
  String _summaryCacheKey(String childId, String date) =>
      'nutrition_summary_${childId}_$date';

  Future<void> loadCatalog() async {
    _isLoadingCatalog = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_catalogCacheKey);
      if (cached != null && cached.isNotEmpty) {
        final decoded = jsonDecode(cached);
        if (decoded is List && decoded.isNotEmpty) {
          _foods = decoded
              .whereType<Map<String, dynamic>>()
              .map(FoodItem.fromJson)
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[NutritionProvider] Catalog cache error: $e');
    }

    try {
      final res = await _apiClient.get(
        ApiConstants.nutritionFoods,
        queryParams: {'limit': '200'},
      );
      if (res.isSuccess && res.data is Map<String, dynamic>) {
        final rawFoods = (res.data as Map<String, dynamic>)['foods'];
        if (rawFoods is List && rawFoods.isNotEmpty) {
          _foods = rawFoods
              .whereType<Map<String, dynamic>>()
              .map(FoodItem.fromJson)
              .toList();
          _catalogError = null;

          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_catalogCacheKey, jsonEncode(rawFoods));
          } catch (_) {}
        }
      } else {
        _catalogError = res.errorMessage ?? 'Katalog memakai data offline.';
      }
    } catch (e) {
      debugPrint('[NutritionProvider] Catalog error: $e');
      _catalogError = 'Katalog memakai data offline.';
    } finally {
      _isLoadingCatalog = false;
      notifyListeners();
    }

    await flushPendingBatches();
  }

  Future<void> loadTarget(String childId) async {
    _isLoadingTarget = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_targetCacheKey(childId));
      if (cached != null && cached.isNotEmpty) {
        _target = NutritionTarget.fromJson(
          jsonDecode(cached) as Map<String, dynamic>,
        );
      }
    } catch (e) {
      debugPrint('[NutritionProvider] Target cache error: $e');
    }

    try {
      final res = await _apiClient.get(
        ApiConstants.nutritionTarget,
        queryParams: {'childId': childId},
      );
      if (res.isSuccess && res.data is Map<String, dynamic>) {
        final rawTarget = (res.data as Map<String, dynamic>)['target'];
        if (rawTarget is Map<String, dynamic>) {
          _target = NutritionTarget.fromJson(rawTarget);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            _targetCacheKey(childId),
            jsonEncode(rawTarget),
          );
        }
      }
    } catch (e) {
      debugPrint('[NutritionProvider] Target error: $e');
    } finally {
      _isLoadingTarget = false;
      notifyListeners();
    }
  }

  Future<void> loadSummary(String childId, String date) async {
    _isLoadingSummary = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_summaryCacheKey(childId, date));
      if (cached != null && cached.isNotEmpty) {
        _summary = NutritionSummary.fromJson(
          jsonDecode(cached) as Map<String, dynamic>,
        );
      }
    } catch (e) {
      debugPrint('[NutritionProvider] Summary cache error: $e');
    }

    try {
      final res = await _apiClient.get(
        ApiConstants.nutritionSummary,
        queryParams: {'childId': childId, 'date': date},
      );
      if (res.isSuccess && res.data is Map<String, dynamic>) {
        final data = res.data as Map<String, dynamic>;
        _summary = NutritionSummary.fromJson(data);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          _summaryCacheKey(childId, date),
          jsonEncode(data),
        );
      }
    } catch (e) {
      debugPrint('[NutritionProvider] Summary error: $e');
    } finally {
      _isLoadingSummary = false;
      notifyListeners();
    }
  }

  void addDraft(
    FoodItem food, {
    double weightGram = 100,
    NutritionValues? preparedValues,
  }) {
    _draft = [
      ..._draft,
      NutritionDraftItem(
        food: food,
        weightGram: weightGram,
        preparedValues: preparedValues,
      ),
    ];
    _batchTotals = localDraftTotals;
    notifyListeners();
  }

  void removeDraft(int index) {
    if (index < 0 || index >= _draft.length) return;
    final next = List<NutritionDraftItem>.from(_draft)..removeAt(index);
    _draft = next;
    _batchTotals = localDraftTotals;
    notifyListeners();
  }

  void updateDraftWeight(int index, double weightGram) {
    if (index < 0 || index >= _draft.length) return;
    final next = List<NutritionDraftItem>.from(_draft);
    next[index] = NutritionDraftItem(
      food: next[index].food,
      weightGram: weightGram.isFinite && weightGram > 0 ? weightGram : 0,
    );
    _draft = next;
    _batchTotals = localDraftTotals;
    notifyListeners();
  }

  void clearDraft() {
    _draft = [];
    _batchTotals = NutritionValues.zero;
    notifyListeners();
  }

  Future<NutritionValues> calculateDraft({String? childId}) async {
    if (_draft.isEmpty) return NutritionValues.zero;

    _isCalculating = true;
    notifyListeners();

    final localTotals = localDraftTotals;

    try {
      final res = await _apiClient.post(
        ApiConstants.nutritionCalculateBatch,
        body: {
          if (childId != null && childId.isNotEmpty) 'childId': childId,
          'items': _draft
              .map(
                (item) => {
                  if (!item.food.id.startsWith('local-'))
                    'foodId': item.food.id,
                  'foodName': item.food.name,
                  'weightGram': item.weightGram,
                },
              )
              .toList(),
        },
      );

      if (res.isSuccess && res.data is Map<String, dynamic>) {
        final totals = (res.data as Map<String, dynamic>)['totals'];
        if (totals is Map<String, dynamic>) {
          _batchTotals = NutritionValues.fromJson(totals);
          return _batchTotals;
        }
      }
    } catch (e) {
      debugPrint('[NutritionProvider] Calculate batch error: $e');
    } finally {
      _isCalculating = false;
      notifyListeners();
    }

    _batchTotals = localTotals;
    return _batchTotals;
  }

  Future<bool> saveDraftToDiary({
    required String childId,
    required String date,
    required String mealSlot,
  }) async {
    if (_draft.isEmpty || _isSaving) return false;

    _isSaving = true;
    notifyListeners();

    final items = _draft
        .map(
          (item) => {
            if (!item.food.id.startsWith('local-'))
              'foodItemId': item.food.id,
            'foodName': item.food.name,
            'portion': '${item.weightGram.toStringAsFixed(0)} g',
            'weightGram': item.weightGram,
            ...item.values.toJson(),
          },
        )
        .toList();

    final payload = {
      'childId': childId,
      'date': date,
      'mealSlot': mealSlot,
      'items': items,
    };

    try {
      final res = await _apiClient.post(
        ApiConstants.foodDiaryBatch,
        body: payload,
      );
      if (res.isSuccess) {
        clearDraft();
        await loadSummary(childId, date);
        return true;
      }
    } catch (e) {
      debugPrint('[NutritionProvider] Save batch error: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }

    await _enqueuePendingBatch(payload);
    // The batch is now queued locally; clear the draft so the user cannot
    // accidentally enqueue the same items twice.
    clearDraft();
    return false;
  }

  Future<void> saveTarget(String childId, NutritionTarget target) async {
    final values = target.values;
    final res = await _apiClient.put(
      ApiConstants.nutritionTarget,
      body: {
        'childId': childId,
        ...values.toJson(),
      },
    );

    if (res.isSuccess) {
      _target = target;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          _targetCacheKey(childId),
          jsonEncode({
            ...target.values.toJson(),
            'source': target.source,
          }),
        );
      } catch (_) {}
      notifyListeners();
    }
  }

  Future<void> _enqueuePendingBatch(Map<String, dynamic> payload) async {
    try {
      await _pendingQueue.add(jsonEncode(payload));
      _pendingSyncCount = await _pendingQueue.count();
      notifyListeners();
    } catch (e) {
      debugPrint('[NutritionProvider] Enqueue pending batch error: $e');
    }
  }

  Future<void> flushPendingBatches() async {
    try {
      final raw = await _pendingQueue.read();
      if (raw.isEmpty) {
        _pendingSyncCount = 0;
        return;
      }

      final remaining = <String>[];
      for (final encoded in raw) {
        try {
          final res = await _apiClient.post(
            ApiConstants.foodDiaryBatch,
            body: jsonDecode(encoded) as Map<String, dynamic>,
          );
          if (!res.isSuccess) remaining.add(encoded);
        } catch (_) {
          remaining.add(encoded);
        }
      }

      await _pendingQueue.replace(remaining);
      _pendingSyncCount = remaining.length;
      notifyListeners();
    } catch (e) {
      debugPrint('[NutritionProvider] Flush pending batches error: $e');
    }
  }

  Future<void> _loadPendingCount() async {
    try {
      _pendingSyncCount = await _pendingQueue.count();
      notifyListeners();
    } catch (_) {}
  }
}
