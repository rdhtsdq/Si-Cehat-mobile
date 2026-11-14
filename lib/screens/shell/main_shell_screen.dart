import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/notification_navigation.dart';
import '../../core/widgets/calm_widgets.dart';
import '../home/home_screen.dart';
import '../tracker/tracker_screen.dart';
import '../education/education_screen.dart';
import '../profile/profile_select_screen.dart';

class MainShellScreen extends StatefulWidget {
  final int initialIndex;

  const MainShellScreen({super.key, this.initialIndex = 0});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pages = [
      HomeScreen(onNavigateTab: _onTabSelected),
      const TrackerScreen(showBackButton: false),
      const EducationScreen(showBackButton: false),
      const ProfileSelectScreen(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationNavigation.consumePending();
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTapped: _onTabSelected,
        items: const [
          AppNavItem(icon: Icons.home_outlined, label: 'Home'),
          AppNavItem(icon: Icons.show_chart_rounded, label: 'Tracker'),
          AppNavItem(icon: Icons.menu_book_outlined, label: 'Edukasi'),
          AppNavItem(icon: Icons.person_outline_rounded, label: 'Profil'),
        ],
      ),
    );
  }
}
