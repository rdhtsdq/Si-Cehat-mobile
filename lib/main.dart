import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/api/api_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/services/local_notification_service.dart';
import 'core/services/notification_navigation.dart';
import 'core/services/push_notification_service.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await ApiConstants.init();
  await LocalNotificationService.instance.initialize();
  LocalNotificationService.instance.onNotificationTap =
      NotificationNavigation.handlePayload;
  await PushNotificationService.instance.initialize();
  runApp(const ProviderScope(child: SiCehatApp()));
}

class SiCehatApp extends StatelessWidget {
  const SiCehatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Si Cehat Mobile',
      debugShowCheckedModeBanner: false,
      navigatorKey: NotificationNavigation.navigatorKey,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
