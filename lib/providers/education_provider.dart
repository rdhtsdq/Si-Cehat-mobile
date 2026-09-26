import 'package:flutter/material.dart';
import '../core/database/seed_data.dart';
import '../data/models/recipe_model.dart';
import '../data/models/education_model.dart';

class EducationProvider extends ChangeNotifier {
  List<RecipeModel> _recipes = [];
  List<EducationModel> _educationItems = [];
  List<QuizQuestion> _quizQuestions = [];
  String _selectedRecipeCategory = 'Semua';

  List<RecipeModel> get allRecipes => _recipes;
  List<EducationModel> get educationItems => _educationItems;
  List<QuizQuestion> get quizQuestions => _quizQuestions;
  String get selectedRecipeCategory => _selectedRecipeCategory;

  EducationProvider() {
    _recipes = List.from(SeedData.initialRecipes);
    _educationItems = List.from(SeedData.initialEducation);
    _quizQuestions = List.from(SeedData.sampleQuizQuestions);
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
