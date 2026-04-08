import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'map/map_screen.dart';
import 'community/community_screen.dart';
import 'report/report_screen.dart';
import 'feed/feed_screen.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MapScreen(),
    CommunityScreen(),
    ReportScreen(),
    FeedScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.h;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      extendBody: true,
      bottomNavigationBar: SizedBox(
        height: 69 + MediaQuery.of(context).padding.bottom,
        child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Nav bar background
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B101A).withValues(alpha: 0.85),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        border: Border(
                          top: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1.0),
                        ),
                      ),
                    ),
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
                        onTap: () => setState(() => _currentIndex = 0),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: Icons.people_outline_rounded,
                        activeIcon: Icons.people_rounded,
                        label: 'HUB',
                        isActive: _currentIndex == 1,
                        onTap: () => setState(() => _currentIndex = 1),
                      ),
                    ),
                    const SizedBox(width: 72), // Space for center button
                    Expanded(
                      child: _NavItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home_rounded,
                        label: 'FEED',
                        isActive: _currentIndex == 3,
                        onTap: () => setState(() => _currentIndex = 3),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: Icons.person_outline_rounded,
                        activeIcon: Icons.person_rounded,
                        label: 'PROFILE',
                        isActive: _currentIndex == 4,
                        onTap: () => setState(() => _currentIndex = 4),
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
                    onTap: () => setState(() => _currentIndex = 2),
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

  const _ReportNavButton({
    required this.isActive,
    required this.onTap,
  });

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
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: AppColors.yellow.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.warning_rounded,
          color: AppColors.black,
          size: 28,
        ),
      ),
    );
  }
}
