import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../core/database/seed_data.dart';
import '../data/models/recipe_model.dart';
import '../data/models/education_model.dart';

class EducationProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient.instance;

  List<RecipeModel> _recipes = [];
  List<MealPlanDayModel> _weeklyMealPlan = [];
  List<RecommendedMenuModel> _recommendedMenus = [];
  List<EducationModel> _educationItems = [];
  List<QuizQuestion> _quizQuestions = [];

  String _selectedRecipeCategory = 'Semua';
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isLoadingMealPlan = false;
  bool _isOnlineSynced = false;

  List<RecipeModel> get allRecipes => _recipes;
  List<MealPlanDayModel> get weeklyMealPlan => _weeklyMealPlan;
  List<RecommendedMenuModel> get recommendedMenus => _recommendedMenus;
  List<EducationModel> get educationItems => _educationItems;
  List<QuizQuestion> get quizQuestions => _quizQuestions;
  String get selectedRecipeCategory => _selectedRecipeCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isLoadingMealPlan => _isLoadingMealPlan;
  bool get isOnlineSynced => _isOnlineSynced;

  EducationProvider() {
    _recipes = List.from(SeedData.initialRecipes);
    _educationItems = List.from(SeedData.initialEducation);
    _quizQuestions = List.from(SeedData.sampleQuizQuestions);
    loadRemoteContent();
  }

  Future<void> loadRemoteContent() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        fetchRecipes(),
        loadMealPlan(silent: true),
        _fetchEducationArticles(),
        _fetchDynamicContent(),
      ]);
    } catch (e) {
      debugPrint('[EducationProvider] Remote load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches recipes from `GET /api/recipes` with optional category & search query.
  Future<void> fetchRecipes({
    String? category,
    String? search,
    bool showLoading = false,
  }) async {
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final queryParams = <String, String>{};
      if (category != null &&
          category.isNotEmpty &&
          category.toLowerCase() != 'semua') {
        queryParams['category'] = category.toLowerCase();
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final res = await _apiClient.get(
        ApiConstants.recipes,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (res.isSuccess && res.data != null) {
        final rawRecipes = res.data['recipes'] as List<dynamic>?;
        if (rawRecipes != null) {
          final remoteList = rawRecipes
              .whereType<Map<String, dynamic>>()
              .map(RecipeModel.fromJson)
              .toList();

          if (remoteList.isNotEmpty || queryParams.isNotEmpty) {
            _recipes = remoteList;
            _isOnlineSynced = true;
          }
        }
      }
    } catch (e) {
      debugPrint('[EducationProvider] fetchRecipes error: $e');
    } finally {
      if (showLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  /// Fetches full recipe detail from `GET /api/recipes/:id` and updates cached list.
  Future<RecipeModel?> fetchRecipeDetail(String id) async {
    if (id.isEmpty || id.startsWith('rec_')) {
      return null;
    }

    try {
      final res = await _apiClient.get('${ApiConstants.recipes}/$id');
      if (res.isSuccess && res.data != null) {
        final rawRecipe = res.data['recipe'] as Map<String, dynamic>?;
        if (rawRecipe != null) {
          final detailed = RecipeModel.fromJson(rawRecipe);
          final idx = _recipes.indexWhere((r) => r.id == detailed.id);
          if (idx != -1) {
            _recipes[idx] = detailed;
            notifyListeners();
          }
          return detailed;
        }
      }
    } catch (e) {
      debugPrint('[EducationProvider] fetchRecipeDetail error: $e');
    }
    return null;
  }

  String _activePlanRisk = 'RENDAH';
  String _targetCalories = '1.500 - 1.700 kkal / hari';

  String get activePlanRisk => _activePlanRisk;
  String get targetCalories => _targetCalories;

  /// Fetches structured 7-day meal plan, recommended menus, and recipes from `GET /api/meal-plan`.
  Future<void> loadMealPlan({
    bool silent = false,
    String? childId,
    String? riskCategory,
  }) async {
    if (!silent) {
      _isLoadingMealPlan = true;
      notifyListeners();
    }

    try {
      final queryParams = <String, String>{};
      if (childId != null && childId.isNotEmpty) {
        queryParams['childId'] = childId;
      }
      if (riskCategory != null && riskCategory.isNotEmpty) {
        queryParams['riskCategory'] = riskCategory;
      }

      final res = await _apiClient.get(
        ApiConstants.mealPlan,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (res.isSuccess && res.data != null) {
        if (res.data['riskCategory'] != null) {
          _activePlanRisk = res.data['riskCategory'].toString();
        }
        if (res.data['targetCalories'] != null) {
          _targetCalories = res.data['targetCalories'].toString();
        }

        final rawWeekly = res.data['weeklyPlan'] as List<dynamic>?;
        if (rawWeekly != null && rawWeekly.isNotEmpty) {
          _weeklyMealPlan = rawWeekly
              .whereType<Map<String, dynamic>>()
              .map(MealPlanDayModel.fromJson)
              .toList();
        }

        final rawRecMenus = res.data['recommendedMenus'] as List<dynamic>?;
        if (rawRecMenus != null && rawRecMenus.isNotEmpty) {
          _recommendedMenus = rawRecMenus
              .whereType<Map<String, dynamic>>()
              .map(RecommendedMenuModel.fromJson)
              .toList();
        }

        final rawRecipes = res.data['recipes'] as List<dynamic>?;
        if (rawRecipes != null &&
            rawRecipes.isNotEmpty &&
            _searchQuery.isEmpty) {
          _recipes = rawRecipes
              .whereType<Map<String, dynamic>>()
              .map(RecipeModel.fromJson)
              .toList();
          _isOnlineSynced = true;
        }
      }
    } catch (e) {
      debugPrint('[EducationProvider] loadMealPlan error: $e');
    } finally {
      if (!silent) {
        _isLoadingMealPlan = false;
      }
      notifyListeners();
    }
  }

  /// Allows swapping a meal in a specific day & meal slot
  void swapMealSlot({
    required int dayIndex,
    required int mealIndex,
    required MealPlanItemModel newItem,
  }) {
    if (dayIndex < 0 || dayIndex >= _weeklyMealPlan.length) return;
    final targetDay = _weeklyMealPlan[dayIndex];
    if (mealIndex < 0 || mealIndex >= targetDay.meals.length) return;

    final updatedMeals = List<MealPlanItemModel>.from(targetDay.meals);
    updatedMeals[mealIndex] = newItem;

    _weeklyMealPlan[dayIndex] = MealPlanDayModel(
      dayNumber: targetDay.dayNumber,
      focusTitle: targetDay.focusTitle,
      meals: updatedMeals,
    );
    notifyListeners();
  }

  /// Syncs standard meal plan hours to reminders table via `POST /api/meal-plan/sync-reminders`
  Future<bool> syncMealReminders({String? childId}) async {
    try {
      final res = await _apiClient.post(
        '${ApiConstants.mealPlan}/sync-reminders',
        body: childId != null ? {'childId': childId} : {},
      );
      return res.isSuccess;
    } catch (e) {
      debugPrint('[EducationProvider] syncMealReminders error: $e');
      return false;
    }
  }

  Future<void> _fetchEducationArticles() async {
    final eduRes = await _apiClient.get(ApiConstants.educationArticles);
    if (eduRes.isSuccess && eduRes.data != null) {
      final rawArticles =
          (eduRes.data['data'] ?? eduRes.data['articles']) as List<dynamic>?;
      if (rawArticles != null && rawArticles.isNotEmpty) {
        final remoteEdu = rawArticles
            .whereType<Map<String, dynamic>>()
            .map(EducationModel.fromJson)
            .toList();

        final remoteTitles = remoteEdu
            .map((e) => e.title.toLowerCase())
            .toSet();
        final uniqueSeedEdu = SeedData.initialEducation
            .where((e) => !remoteTitles.contains(e.title.toLowerCase()))
            .toList();

        _educationItems = [...remoteEdu, ...uniqueSeedEdu];
      }
    }
  }

  Future<void> _fetchDynamicContent() async {
    final contentRes = await _apiClient.get(ApiConstants.content);
    if (contentRes.isSuccess && contentRes.data != null) {
      final quizData = contentRes.data['quiz'] as Map<String, dynamic>?;
      if (quizData != null && quizData['question'] != null) {
        final q = QuizQuestion.fromJson(quizData);
        if (!_quizQuestions.any((item) => item.question == q.question)) {
          _quizQuestions = [q, ..._quizQuestions];
        }
      }

      if (_recommendedMenus.isEmpty) {
        final rawMenus = contentRes.data['recommendedMenus'] as List<dynamic>?;
        if (rawMenus != null && rawMenus.isNotEmpty) {
          _recommendedMenus = rawMenus
              .whereType<Map<String, dynamic>>()
              .map(RecommendedMenuModel.fromJson)
              .toList();
        }
      }
    }
  }

  List<RecipeModel> get filteredRecipes {
    return _recipes.where((r) {
      final matchCat =
          _selectedRecipeCategory == 'Semua' ||
          r.category.toLowerCase() == _selectedRecipeCategory.toLowerCase();
      final q = _searchQuery.trim().toLowerCase();
      final matchSearch =
          q.isEmpty ||
          r.name.toLowerCase().contains(q) ||
          r.summary.toLowerCase().contains(q);
      return matchCat && matchSearch;
    }).toList();
  }

  void setRecipeCategory(String category) {
    _selectedRecipeCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Resolves a matching [RecipeModel] by either ID or title keyword.
  RecipeModel? findMatchingRecipe({
    String? recipeId,
    String? recipeTitle,
    String? mealTitle,
  }) {
    if (recipeId != null && recipeId.isNotEmpty) {
      final byId = _recipes.where((r) => r.id == recipeId).firstOrNull;
      if (byId != null) return byId;
    }

    if (recipeTitle != null && recipeTitle.trim().isNotEmpty) {
      final kw = recipeTitle.trim().toLowerCase();
      final byTitle = _recipes
          .where(
            (r) =>
                r.name.toLowerCase().contains(kw) ||
                kw.contains(r.name.toLowerCase()),
          )
          .firstOrNull;
      if (byTitle != null) return byTitle;
    }

    if (mealTitle != null && mealTitle.trim().isNotEmpty) {
      final mt = mealTitle.trim().toLowerCase();
      final byMealTitle = _recipes
          .where((r) => mt.contains(r.name.toLowerCase()))
          .firstOrNull;
      if (byMealTitle != null) return byMealTitle;
    }

    return null;
  }

  List<EducationModel> getVideos() =>
      _educationItems.where((e) => e.type == 'video').toList();

  List<EducationModel> getPodcasts() =>
      _educationItems.where((e) => e.type == 'podcast').toList();
}
