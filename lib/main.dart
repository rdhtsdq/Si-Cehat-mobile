import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/api/api_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/services/reminder_service.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await ApiConstants.init();
  ReminderService.instance.start();
  runApp(const ProviderScope(child: SiCehatApp()));
}

class SiCehatApp extends StatelessWidget {
  const SiCehatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Si Cehat Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
