import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../data/models/recipe_model.dart';
import '../../providers/education_provider.dart';
import 'menu_detail_screen.dart';

class MenuCatalogScreen extends StatefulWidget {
  const MenuCatalogScreen({super.key});

  @override
  State<MenuCatalogScreen> createState() => _MenuCatalogScreenState();
}

class _MenuCatalogScreenState extends State<MenuCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final prov = context.read<EducationProvider>();
      _searchController.text = prov.searchQuery;
      prov.fetchRecipes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          icon: const Icon(
            Icons.chevron_left,
            size: 28,
            color: AppColors.textDark,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Menu Tradisional Sehat',
          style: AppTypography.headingScreen.copyWith(fontSize: 20),
        ),
        actions: [
          IconButton(
            tooltip: 'Muat Ulang dari Server',
            onPressed: eduProv.isLoading
                ? null
                : () => eduProv.fetchRecipes(showLoading: true),
            icon: const Icon(Icons.refresh, color: AppColors.primaryGreenDark),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 10),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => eduProv.setSearchQuery(value),
                onSubmitted: (value) => eduProv.fetchRecipes(
                  category: selectedCategory,
                  search: value,
                  showLoading: true,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari resep sehat tradisional...',
                  hintStyle: AppTypography.bodySecondary.copyWith(fontSize: 13),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            eduProv.setSearchQuery('');
                            eduProv.fetchRecipes();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.fieldBackground,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Category Filter Chips
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
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
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
            const SizedBox(height: 12),

            if (eduProv.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColors.primaryGreen,
                ),
              ),

            // Daftar card horizontal
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryGreen,
                onRefresh: () => eduProv.fetchRecipes(showLoading: false),
                child: recipes.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 120),
                          Center(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.restaurant_menu_outlined,
                                  size: 48,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Belum ada menu pada kategori ini',
                                  style: AppTypography.bodySecondary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        itemCount: recipes.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final item = recipes[index];
                          return _buildMenuHorizontalCard(context, item);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuHorizontalCard(BuildContext context, RecipeModel item) {
    final hasImage = item.imageUrl != null && item.imageUrl!.trim().isNotEmpty;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => MenuDetailScreen(recipe: item)),
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
              // Foto/ikon makanan persegi di kiri dengan radius
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 80,
                  height: 80,
                  color: AppColors.paleGreenBg,
                  alignment: Alignment.center,
                  child: hasImage
                      ? Image.network(
                          item.imageUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Text(
                            item.iconEmoji,
                            style: const TextStyle(fontSize: 38),
                          ),
                        )
                      : Text(
                          item.iconEmoji,
                          style: const TextStyle(fontSize: 38),
                        ),
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
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              size: 14,
                              color: AppColors.primaryGreenDark,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              item.calories,
                              style: AppTypography.bodySecondary.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryGreenDark,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Protein: ${item.protein} \u00b7 Serat: ${item.fiber}',
                          style: AppTypography.bodySecondary.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
