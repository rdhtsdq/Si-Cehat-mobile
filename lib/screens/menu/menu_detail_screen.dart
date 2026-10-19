import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../data/models/recipe_model.dart';
import '../../providers/education_provider.dart';
import '../diary/food_diary_screen.dart';

class MenuDetailScreen extends StatefulWidget {
  final RecipeModel recipe;

  const MenuDetailScreen({super.key, required this.recipe});

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  late RecipeModel _recipe;
  bool _isLoadingDetail = false;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
    _loadLatestDetail();
  }

  Future<void> _loadLatestDetail() async {
    if (_recipe.id.isEmpty || _recipe.id.startsWith('rec_')) return;

    setState(() => _isLoadingDetail = true);
    try {
      final prov = context.read<EducationProvider>();
      final fresh = await prov.fetchRecipeDetail(_recipe.id);
      if (fresh != null && mounted) {
        setState(() => _recipe = fresh);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingDetail = false);
      }
    }
  }

  String _mapCategoryToMealType(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('cemilan') || lower.contains('camilan')) {
      return 'Camilan Sore';
    }
    if (lower.contains('minuman')) {
      return 'Camilan Pagi';
    }
    return 'Makan Siang';
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        _recipe.imageUrl != null && _recipe.imageUrl!.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            size: 28,
            color: AppColors.textDark,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _recipe.name,
          style: AppTypography.headingScreen.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: _loadLatestDetail,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLoadingDetail)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      color: AppColors.primaryGreen,
                    ),
                  ),

                // Foto hero makanan lebar, hampir persegi, ber-radius di bawah app bar sesuai PDF S13
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.paleGreenBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.lightGreen.withValues(alpha: 0.4),
                      ),
                    ),
                    child: hasImage
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                _recipe.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    _buildFallbackHeroContent(),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.65),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                right: 16,
                                bottom: 14,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _recipe.name,
                                      style: AppTypography.titleCard.copyWith(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _recipe.summary,
                                      style: AppTypography.bodySecondary
                                          .copyWith(
                                            fontSize: 12,
                                            color: Colors.white.withValues(
                                              alpha: 0.9,
                                            ),
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : _buildFallbackHeroContent(),
                  ),
                ),
                const SizedBox(height: 18),

                // Empat bidang kecil nutrisi berjajar: Energi, Serat, Protein, Gula
                Row(
                  children: [
                    Expanded(
                      child: _buildNutritionChip(
                        icon: Icons.local_fire_department,
                        label: 'Energi',
                        value: _recipe.calories,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildNutritionChip(
                        icon: Icons.grass,
                        label: 'Serat',
                        value: _recipe.fiber,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildNutritionChip(
                        icon: Icons.fitness_center,
                        label: 'Protein',
                        value: _recipe.protein,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildNutritionChip(
                        icon: Icons.water_drop_outlined,
                        label: 'Gula',
                        value: _recipe.sugar,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Bagian bawah: Bahan-bahan
                Text(
                  'Bahan-bahan (${_recipe.portion}):',
                  style: AppTypography.titleCard.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.fieldBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _recipe.ingredients
                        .map(
                          (ing) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '\u2022 ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  child: Text(
                                    ing,
                                    style: AppTypography.bodyRegular,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Cara Membuat
                Text(
                  'Cara Memasak:',
                  style: AppTypography.titleCard.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.fieldBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _recipe.instructions.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final step = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$index',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                step,
                                style: AppTypography.bodyRegular,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Catatan Manfaat Gizi
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.veryLightGreen,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.lightGreen.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.tips_and_updates_outlined,
                        color: AppColors.primaryGreenDark,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _recipe.note,
                          style: AppTypography.bodySecondary.copyWith(
                            color: AppColors.primaryGreenDark,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Action Button: Catat di Food Diary
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FoodDiaryScreen(
                            initialFood: _recipe.name,
                            initialMeal: _mapCategoryToMealType(
                              _recipe.category,
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                    label: const Text(
                      'Catat Menu Ini di Food Diary',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackHeroContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_recipe.iconEmoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 8),
            Text(
              _recipe.name,
              style: AppTypography.titleCard.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              _recipe.summary,
              style: AppTypography.bodySecondary.copyWith(fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.textDark),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodySecondary.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.bodyRegular.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
