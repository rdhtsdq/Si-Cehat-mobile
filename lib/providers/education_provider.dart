import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../core/database/seed_data.dart';
import '../data/models/recipe_model.dart';
import '../data/models/education_model.dart';

class EducationProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient.instance;

  List<RecipeModel> _recipes = [];
  List<EducationModel> _educationItems = [];
  List<QuizQuestion> _quizQuestions = [];
  String _selectedRecipeCategory = 'Semua';
  bool _isLoading = false;

  List<RecipeModel> get allRecipes => _recipes;
  List<EducationModel> get educationItems => _educationItems;
  List<QuizQuestion> get quizQuestions => _quizQuestions;
  String get selectedRecipeCategory => _selectedRecipeCategory;
  bool get isLoading => _isLoading;

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
      // 1. Fetch remote recipes
      final recipeRes = await _apiClient.get(ApiConstants.recipes);
      if (recipeRes.isSuccess && recipeRes.data != null) {
        final rawRecipes = recipeRes.data['recipes'] as List<dynamic>?;
        if (rawRecipes != null && rawRecipes.isNotEmpty) {
          final remoteList = rawRecipes
              .map((r) => RecipeModel.fromJson(r as Map<String, dynamic>))
              .toList();

          // Merge: Keep remote recipes, append any unique seed recipes
          final remoteNames = remoteList.map((r) => r.name.toLowerCase()).toSet();
          final uniqueSeeds = SeedData.initialRecipes
              .where((r) => !remoteNames.contains(r.name.toLowerCase()))
              .toList();

          _recipes = [...remoteList, ...uniqueSeeds];
        }
      }

      // 2. Fetch remote education articles
      final eduRes = await _apiClient.get(ApiConstants.educationArticles);
      if (eduRes.isSuccess && eduRes.data != null) {
        final rawArticles = (eduRes.data['data'] ?? eduRes.data['articles']) as List<dynamic>?;
        if (rawArticles != null && rawArticles.isNotEmpty) {
          final remoteEdu = rawArticles
              .map((a) => EducationModel.fromJson(a as Map<String, dynamic>))
              .toList();

          final remoteTitles = remoteEdu.map((e) => e.title.toLowerCase()).toSet();
          final uniqueSeedEdu = SeedData.initialEducation
              .where((e) => !remoteTitles.contains(e.title.toLowerCase()))
              .toList();

          _educationItems = [...remoteEdu, ...uniqueSeedEdu];
        }
      }

      // 3. Fetch remote quiz and content
      final contentRes = await _apiClient.get(ApiConstants.content);
      if (contentRes.isSuccess && contentRes.data != null) {
        final quizData = contentRes.data['quiz'] as Map<String, dynamic>?;
        if (quizData != null && quizData['question'] != null) {
          final q = QuizQuestion.fromJson(quizData);
          if (!_quizQuestions.any((item) => item.question == q.question)) {
            _quizQuestions = [q, ..._quizQuestions];
          }
        }
      }
    } catch (e) {
      debugPrint('[EducationProvider] Remote load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<RecipeModel> get filteredRecipes {
    if (_selectedRecipeCategory == 'Semua') return _recipes;
    return _recipes
        .where((r) => r.category.toLowerCase() == _selectedRecipeCategory.toLowerCase())
        .toList();
  }

  void setRecipeCategory(String category) {
    _selectedRecipeCategory = category;
    notifyListeners();
  }

  List<EducationModel> getVideos() =>
      _educationItems.where((e) => e.type == 'video').toList();

  List<EducationModel> getPodcasts() =>
      _educationItems.where((e) => e.type == 'podcast').toList();
}
