import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../data/models/notification_model.dart';
import '../../providers/notification_provider.dart';
import 'consultation_screen.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifProv = context.watch<NotificationProvider>();
    final notifs = notifProv.notifications;
    final unreadCount = notifProv.unreadCount;

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
          'Pusat Notifikasi',
          style: AppTypography.headingScreen.copyWith(fontSize: 20),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => notifProv.markAllAsRead(),
              child: const Text(
                'Tandai Dibaca',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: (notifProv.isLoading && notifs.isEmpty)
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
            : notifs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Belum Ada Notifikasi',
                          style: AppTypography.titleCard.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pemberitahuan konsultasi dan pengingat akan muncul di sini.',
                          style: AppTypography.bodySecondary,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => notifProv.loadNotifications(),
                    color: AppColors.primaryGreen,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      itemCount: notifs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = notifs[index];
                        return _buildNotificationCard(context, item, notifProv);
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel item,
    NotificationProvider prov,
  ) {
    IconData iconData = Icons.notifications;
    Color iconColor = AppColors.primaryGreen;

    if (item.type == 'CONSULTATION') {
      iconData = Icons.medical_services_outlined;
      iconColor = const Color(0xFF0284C7);
    } else if (item.type == 'REMINDER') {
      iconData = Icons.alarm;
      iconColor = const Color(0xFFF59E0B);
    }

    final timeStr =
        '${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')} · ${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}';

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => prov.deleteNotification(item.id),
      child: Material(
        color: item.isRead ? Colors.white : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        elevation: item.isRead ? 0.5 : 1.5,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (!item.isRead) {
              prov.markAsRead(item.id);
            }
            if (item.type == 'CONSULTATION') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConsultationScreen()),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: item.isRead ? const Color(0xFFE2E8F0) : AppColors.lightGreen,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: iconColor.withValues(alpha: 0.12),
                  child: Icon(iconData, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          if (!item.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.message,
                        style: TextStyle(
                          fontSize: 12,
                          color: item.isRead ? AppColors.textSecondary : AppColors.textDark,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
