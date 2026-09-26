import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/safety_banner.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _selectedTab = 0; // 0: Semua, 1: Populer, 2: Saya

  void _showNotice() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Komunitas & Moderasi'),
        content: const Text(
          'Fitur publikasi postingan komunitas memerlukan moderasi konten terverifikasi serta perlindungan privasi anak pada rilis penuh (D2).\n\nPada versi demo ini, feed ditampilkan sebagai pratinjau antarmuka.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

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
          'Komunitas',
          style: AppTypography.headingScreen.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tab Semua aktif hijau, Populer, Saya abu muda sesuai PDF S17
              Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      title: 'Semua',
                      isActive: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTabButton(
                      title: 'Populer',
                      isActive: _selectedTab == 1,
                      onTap: () => setState(() => _selectedTab = 1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTabButton(
                      title: 'Saya',
                      isActive: _selectedTab == 2,
                      onTap: () => setState(() => _selectedTab = 2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              const SafetyBanner(
                text: 'Pratinjau antarmuka komunitas. Belum terhubung ke forum publik demi perlindungan privasi anak.',
                type: BannerType.notice,
              ),

              // Dua bidang besar abu muda di area feed sesuai PDF S17
              Expanded(
                child: ListView(
                  children: [
                    _buildFeedPlaceholderCard(
                      title: 'Tips Mengurangi Jajanan Manis Saat Istirahat Sekolah',
                      author: 'Ibu Farida (Komunitas Parenting Bandung)',
                      content:
                          'Saya membiasakan membawakan bekal buah potong dingin dan air putih dingin dengan botol lucu. Alhamdulillah anak saya mulai terbiasa tidak jajan manis di kantin!',
                      likes: '24 Dukungan',
                      comments: '8 Diskusi',
                    ),
                    const SizedBox(height: 14),
                    _buildFeedPlaceholderCard(
                      title: 'Ide Variasi Sayur Asem Segar Tanpa Vetsin Berlebih',
                      author: 'Ibu Ratna',
                      content:
                          'Kombinasi asam jawa alami dengan kemiri sangrai dan sedikit lengkuas membuat kuah sayur asem gurih segar tanpa perlu pemanis tambahan. Anak-anak sangat suka kuahnya.',
                      likes: '19 Dukungan',
                      comments: '5 Diskusi',
                    ),
                  ],
                ),
              ),

              // Tombol hijau lebar "+ Buat Postingan" dekat bawah sesuai PDF S17
              PrimaryButton(
                text: '+ Buat Postingan',
                onPressed: _showNotice,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isActive ? AppColors.primaryGreen : AppColors.fieldBackground,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppTypography.buttonText.copyWith(
              color: isActive ? Colors.white : AppColors.textDark,
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedPlaceholderCard({
    required String title,
    required String author,
    required String content,
    required String likes,
    required String comments,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                child: const Icon(Icons.person, size: 16, color: AppColors.primaryGreenDark),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  author,
                  style: AppTypography.bodySecondary.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTypography.titleCard.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: AppTypography.bodySecondary.copyWith(
              fontSize: 13,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.thumb_up_alt_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(likes, style: AppTypography.bodySecondary.copyWith(fontSize: 11)),
              const SizedBox(width: 14),
              const Icon(Icons.chat_bubble_outline, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(comments, style: AppTypography.bodySecondary.copyWith(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
