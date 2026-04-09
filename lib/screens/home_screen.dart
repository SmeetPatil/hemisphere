import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'map/map_screen.dart';
import 'community/community_screen.dart';
import 'report/report_screen.dart';
import 'inbox/inbox_screen.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static final ValueNotifier<int> currentTabNotifier = ValueNotifier<int>(0);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    HomeScreen.currentTabNotifier.value = 0;
  }

  final List<Widget> _screens = const [
    MapScreen(),
    CommunityScreen(),
    ReportScreen(),
    InboxScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.h;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      extendBody: true,
      bottomNavigationBar: SizedBox(
        height: 69 + MediaQuery.of(context).padding.bottom,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Nav bar background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border(
                    top: BorderSide(color: AppColors.black, width: 2.0),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.black,
                      blurRadius: 0,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
              ),
            ),
            // Nav items row
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 69,
              child: Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      icon: Icons.map_outlined,
                      activeIcon: Icons.map_rounded,
                      label: 'MAP',
                      isActive: _currentIndex == 0,
                      onTap: () => setState(() {
                        _currentIndex = 0;
                        HomeScreen.currentTabNotifier.value = 0;
                      }),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.people_outline_rounded,
                      activeIcon: Icons.people_rounded,
                      label: 'HUB',
                      isActive: _currentIndex == 1,
                      onTap: () => setState(() {
                        _currentIndex = 1;
                        HomeScreen.currentTabNotifier.value = 1;
                      }),
                    ),
                  ),
                  const SizedBox(width: 72), // Space for center button
                  Expanded(
                    child: _NavItem(
                      icon: Icons.send_outlined,
                      activeIcon: Icons.send_rounded,
                      label: 'INBOX',
                      isActive: _currentIndex == 3,
                      onTap: () => setState(() {
                        _currentIndex = 3;
                        HomeScreen.currentTabNotifier.value = 3;
                      }),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'PROFILE',
                      isActive: _currentIndex == 4,
                      onTap: () => setState(() {
                        _currentIndex = 4;
                        HomeScreen.currentTabNotifier.value = 4;
                      }),
                    ),
                  ),
                ],
              ),
            ),
            // Floating center report button
            Positioned(
              top: -18,
              left: 0,
              right: 0,
              child: Center(
                child: _ReportNavButton(
                  isActive: _currentIndex == 2,
                  onTap: () => setState(() {
                    // If we are already on the Report screen, tap to return to Map (Index 0)
                    final nextIndex = _currentIndex == 2 ? 0 : 2;
                    _currentIndex = nextIndex;
                    HomeScreen.currentTabNotifier.value = nextIndex;
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.h;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.yellow : colors.navInactive,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isActive ? AppColors.yellow : colors.navInactive,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportNavButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _ReportNavButton({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.yellow,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.black, width: 2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.black,
              blurRadius: 0,
              offset: Offset(3, 3), // Sharp bento drop shadow
            ),
          ],
        ),
        child: Icon(
          isActive ? Icons.close_rounded : Icons.warning_rounded,
          color: AppColors.black,
          size: 28,
        ),
      ),
    );
  }
}
