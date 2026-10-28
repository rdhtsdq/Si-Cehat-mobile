import 'package:flutter_riverpod/legacy.dart';
import 'auth_provider.dart';
import 'profile_provider.dart';
import 'tracker_provider.dart';
import 'reminder_provider.dart';
import 'education_provider.dart';
import 'notification_provider.dart';
import 'nutrition_provider.dart';

export 'auth_provider.dart';
export 'profile_provider.dart';
export 'tracker_provider.dart';
export 'reminder_provider.dart';
export 'education_provider.dart';
export 'notification_provider.dart';
export 'nutrition_provider.dart';

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) => AuthProvider());
final profileProvider = ChangeNotifierProvider<ProfileProvider>((ref) => ProfileProvider());
final trackerProvider = ChangeNotifierProvider<TrackerProvider>((ref) => TrackerProvider());
final reminderProvider = ChangeNotifierProvider<ReminderProvider>((ref) => ReminderProvider());
final educationProvider = ChangeNotifierProvider<EducationProvider>((ref) => EducationProvider());
final notificationProvider = ChangeNotifierProvider<NotificationProvider>((ref) => NotificationProvider());
final nutritionProvider = ChangeNotifierProvider<NutritionProvider>((ref) => NutritionProvider());
