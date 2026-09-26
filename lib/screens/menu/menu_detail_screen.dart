import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../data/models/recipe_model.dart';

class MenuDetailScreen extends StatelessWidget {
  final RecipeModel recipe;

  const MenuDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          recipe.name,
          style: AppTypography.headingScreen.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto hero makanan lebar, hampir persegi, ber-radius di bawah app bar sesuai PDF S13
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.paleGreenBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.lightGreen.withValues(alpha: 0.4)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(recipe.iconEmoji, style: const TextStyle(fontSize: 64)),
                      const SizedBox(height: 8),
                      Text(
                        recipe.name,
                        style: AppTypography.titleCard.copyWith(fontSize: 18),
                      ),
                      Text(
                        recipe.summary,
                        style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Tiga bidang kecil abu muda berjajar: Energi, Serat, Protein (dengan ikon api untuk energi)
              Row(
                children: [
                  Expanded(
                    child: _buildNutritionChip(
                      icon: Icons.local_fire_department,
                      label: 'Energi',
                      value: recipe.calories,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildNutritionChip(
                      icon: Icons.grass,
                      label: 'Serat',
                      value: recipe.fiber,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildNutritionChip(
                      icon: Icons.fitness_center,
                      label: 'Protein',
                      value: recipe.protein,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Bagian bawah: Bahan-bahan
              Text(
                'Bahan-bahan (${recipe.portion}):',
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
                  children: recipe.ingredients
                      .map((ing) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                                Expanded(child: Text(ing, style: AppTypography.bodyRegular)),
                              ],
                            ),
                          ))
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
                  children: recipe.instructions.asMap().entries.map((entry) {
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
                          Expanded(child: Text(step, style: AppTypography.bodyRegular)),
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
                  border: Border.all(color: AppColors.lightGreen.withValues(alpha: 0.5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.tips_and_updates_outlined, color: AppColors.primaryGreenDark, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        recipe.note,
                        style: AppTypography.bodySecondary.copyWith(
                          color: AppColors.primaryGreenDark,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: AppColors.textDark),
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
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
