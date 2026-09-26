import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../data/models/recipe_model.dart';
import '../../providers/education_provider.dart';
import 'menu_detail_screen.dart';

class MenuCatalogScreen extends StatelessWidget {
  const MenuCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eduProv = context.watch<EducationProvider>();
    final recipes = eduProv.filteredRecipes;
    final selectedCategory = eduProv.selectedRecipeCategory;

    final categories = ['Semua', 'Makanan', 'Minuman', 'Cemilan'];

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
          'Menu Tradisional Sehat',
          style: AppTypography.headingScreen.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Empat chip/tab satu baris sesuai PDF S12: Semua, Makanan, Minuman, Cemilan
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: categories.map((cat) {
                  final isActive = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(cat),
                      selected: isActive,
                      showCheckmark: false,
                      selectedColor: AppColors.primaryGreen,
                      backgroundColor: AppColors.fieldBackground,
                      labelStyle: TextStyle(
                        color: isActive ? Colors.white : AppColors.textDark,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.transparent),
                      ),
                      onSelected: (_) {
                        eduProv.setRecipeCategory(cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Daftar card horizontal sesuai PDF S12
            Expanded(
              child: recipes.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada menu pada kategori ini',
                        style: AppTypography.bodySecondary,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: recipes.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = recipes[index];
                        return _buildMenuHorizontalCard(context, item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuHorizontalCard(BuildContext context, RecipeModel item) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MenuDetailScreen(recipe: item),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Row(
            children: [
              // Foto/ikon makanan persegi di kiri dengan radius sesuai PDF
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.paleGreenBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  item.iconEmoji,
                  style: const TextStyle(fontSize: 38),
                ),
              ),
              const SizedBox(width: 16),
              // Judul bold dan deskripsi di kanan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTypography.titleCard.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.summary,
                      style: AppTypography.bodySecondary.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department, size: 14, color: AppColors.primaryGreenDark),
                        const SizedBox(width: 4),
                        Text(
                          item.calories,
                          style: AppTypography.bodySecondary.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreenDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
