<<<<<<< HEAD
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.h;
    final isDark = context.isDark;

    return Column(
      children: [
        // ── PROFILE HEADER ──
        Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.black,
                      AppColors.grey900,
                      AppColors.yellow.withValues(alpha: 0.06),
                    ]
                  : [
                      const Color(0xFFF8F7F2),
                      const Color(0xFFF0EDE4),
                      AppColors.yellow.withValues(alpha: 0.08),
                    ],
              stops: const [0.0, 0.6, 1.0],
            ),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          child: Stack(
            children: [
              // Decorative circle accents
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.yellow.withValues(alpha: isDark ? 0.04 : 0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: -20,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.yellow.withValues(alpha: isDark ? 0.03 : 0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Profile',
                          style: AppTextStyles.displayLarge.copyWith(
                            color:
                                isDark ? AppColors.white : AppColors.grey900,
                            
                          ),
                        ),
                        Row(
                          children: [
                            _HeaderIconButton(
                              icon: Icons.share_outlined,
                              isDark: isDark,
                              onTap: () {},
                            ),
                            const SizedBox(width: 8),
                            _HeaderIconButton(
                              icon: Icons.settings_outlined,
                              isDark: isDark,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Profile info – centered layout
                    Center(
                      child: Column(
                        children: [
                          // Avatar with ring + badge
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              // Outer glow ring
                              Container(
                                width: 108,
                                height: 108,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: AppColors.yellow
                                        .withValues(alpha: 0.25),
                                    width: 4,
                                  ),
                                ),
                              ),
                              // Inner avatar
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppColors.yellow, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.yellow
                                          .withValues(alpha: 0.2),
                                      blurRadius: 18,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: isDark
                                            ? [
                                                AppColors.grey700,
                                                AppColors.grey800
                                              ]
                                            : [
                                                AppColors.grey200,
                                                const Color(0xFFD0D0D0)
                                              ],
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'SP',
                                        style: AppTextStyles.displayMedium
                                            .copyWith(
                                          color: isDark
                                              ? AppColors.white
                                              : AppColors.grey900,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 32,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Verified badge
                              Positioned(
                                bottom: -8,
                                right: -8,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.yellow,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark
                                          ? AppColors.black
                                          : const Color(0xFFF8F7F2),
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.yellow
                                            .withValues(alpha: 0.3),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.check_rounded,
                                      color: AppColors.black, size: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          // Name
                          Text(
                            'Soham Pawar',
                            style: AppTextStyles.headlineLarge.copyWith(
                              color: isDark
                                  ? AppColors.white
                                  : AppColors.grey900,
                              fontWeight: FontWeight.w800,
                              fontSize: 26,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Location
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on_outlined,
                                  color: isDark
                                      ? AppColors.grey300
                                      : AppColors.grey600,
                                  size: 15),
                              const SizedBox(width: 4),
                              Text(
                                'Koramangala, Bangalore',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark
                                      ? AppColors.grey300
                                      : AppColors.grey600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Badge chips row
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _BadgeChip(
                                icon: Icons.military_tech_rounded,
                                label: 'SUPER NEIGHBOR',
                                color: AppColors.yellow,
                                isDark: isDark,
                              ),
                              const SizedBox(width: 8),
                              _BadgeChip(
                                icon: Icons.calendar_today_rounded,
                                label: 'SINCE 2024',
                                color: isDark
                                    ? AppColors.grey300
                                    : AppColors.grey600,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── SCROLLABLE CONTENT ──
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Stats row ──
                Row(
                  children: [
                    _StatCard(
                      icon: Icons.flag_rounded,
                      value: '12',
                      label: 'Reports\nResolved',
                      backgroundColor:
                          isDark ? AppColors.grey900 : const Color(0xFF2D2D2D),
                      textColor: AppColors.yellow,
                      borderColor:
                          isDark ? AppColors.grey700 : const Color(0xFF3D3D3D),
                      iconBgColor: AppColors.yellow.withValues(alpha: 0.15),
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      icon: Icons.volunteer_activism_rounded,
                      value: '4',
                      label: 'Resources\nShared',
                      backgroundColor: colors.card,
                      textColor: colors.textPrimary,
                      borderColor: colors.divider,
                      iconBgColor: isDark
                          ? AppColors.grey700
                          : AppColors.grey200,
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      icon: Icons.bolt_rounded,
                      value: '156',
                      label: 'Impact\nScore',
                      backgroundColor: AppColors.yellow,
                      textColor: AppColors.black,
                      borderColor: AppColors.yellow,
                      iconBgColor: AppColors.black.withValues(alpha: 0.1),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Community Level Progress ──
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.yellow.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: colors.cardShadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.yellow.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.trending_up_rounded,
                                color: AppColors.yellow, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Community Level',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: colors.textPrimary,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Level 5 — Active Contributor',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.yellow,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '72%',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.yellow,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(
                          children: [
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.grey800
                                    : AppColors.grey200,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: 0.72,
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFD600),
                                      Color(0xFFFFC107),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.yellow
                                          .withValues(alpha: 0.4),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '28 more points to reach Level 6',
                        style: AppTextStyles.caption.copyWith(
                          color: colors.textCaption,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Recent Activity ──
                Text(
                  'Recent Activity',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                          color: colors.cardShadow,
                          blurRadius: 6,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    children: [
                      _ActivityTile(
                        icon: Icons.report_outlined,
                        iconColor: AppColors.red,
                        title: 'Reported a pothole on 5th Cross',
                        time: '2 hours ago',
                        isDark: isDark,
                      ),
                      Divider(
                          height: 1, color: colors.divider, indent: 60),
                      _ActivityTile(
                        icon: Icons.handshake_outlined,
                        iconColor: AppColors.green,
                        title: 'Shared power drill with neighbor',
                        time: 'Yesterday',
                        isDark: isDark,
                      ),
                      Divider(
                          height: 1, color: colors.divider, indent: 60),
                      _ActivityTile(
                        icon: Icons.event_outlined,
                        iconColor: const Color(0xFF42A5F5),
                        title: 'Joined community cleanup drive',
                        time: '3 days ago',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Menu items ──
                Text(
                  'Settings',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                          color: colors.cardShadow,
                          blurRadius: 6,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    children: [
                      _ProfileMenuItem(
                        icon: Icons.favorite_outline_rounded,
                        iconColor: AppColors.red,
                        title: 'My Contributions',
                        subtitle: '12 reports, 4 resources',
                        onTap: () {},
                      ),
                      Divider(
                          height: 1, color: colors.divider, indent: 60),
                      _ProfileMenuItem(
                        icon: Icons.military_tech_outlined,
                        iconColor: AppColors.yellow,
                        title: 'Badges & Achievements',
                        subtitle: '3 badges earned',
                        onTap: () {},
                      ),
                      Divider(
                          height: 1, color: colors.divider, indent: 60),
                      _ProfileMenuItem(
                        icon: Icons.location_on_outlined,
                        iconColor: const Color(0xFF42A5F5),
                        title: 'Saved Locations',
                        subtitle: '2 saved places',
                        onTap: () {},
                      ),
                      Divider(
                          height: 1, color: colors.divider, indent: 60),
                      _ProfileMenuItem(
                        icon: Icons.notifications_outlined,
                        iconColor: AppColors.green,
                        title: 'Notifications',
                        subtitle: 'Manage alerts',
                        onTap: () {},
                      ),
                      Divider(
                          height: 1, color: colors.divider, indent: 60),
                      _ProfileMenuItem(
                        icon: Icons.shield_outlined,
                        iconColor: const Color(0xFF7E57C2),
                        title: 'Privacy & Security',
                        subtitle: 'Account settings',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Appearance toggle ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                          color: colors.cardShadow,
                          blurRadius: 6,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors.menuIconBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          context.isDark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: AppColors.yellow,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Appearance',
                                style: AppTextStyles.labelLarge.copyWith(
                                    fontSize: 15,
                                    color: colors.textPrimary)),
                            const SizedBox(height: 2),
                            Text(
                              context.isDark ? 'Dark mode' : 'Light mode',
                              style: AppTextStyles.caption
                                  .copyWith(color: colors.textCaption),
                            ),
                          ],
                        ),
                      ),
                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: ThemeProvider.instance,
                        builder: (context, mode, child) {
                          return Switch(
                            value: mode == ThemeMode.dark,
                            onChanged: (v) =>
                                ThemeProvider.instance.toggleTheme(),
                            activeThumbColor: AppColors.yellow,
                            activeTrackColor:
                                AppColors.yellow.withValues(alpha: 0.3),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Sign out button ──
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.logout_rounded,
                        size: 18,
                        color: isDark ? AppColors.grey300 : AppColors.grey600),
                    label: Text(
                      'Sign Out',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isDark ? AppColors.grey300 : AppColors.grey600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(
                        color: isDark ? AppColors.grey700 : AppColors.grey300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Hemisphere v1.0.0',
                    style: AppTextStyles.caption
                        .copyWith(color: colors.textCaption),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Header Icon Button ──
class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.grey800.withValues(alpha: 0.6)
              : AppColors.white.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark
                ? AppColors.grey700.withValues(alpha: 0.5)
                : AppColors.grey300.withValues(alpha: 0.5),
          ),
        ),
        child: Icon(icon,
            color: isDark ? AppColors.grey300 : AppColors.grey600, size: 20),
      ),
    );
  }
}

// ── Badge Chip ──
class _BadgeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  const _BadgeChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.grey800.withValues(alpha: 0.7)
            : AppColors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ──
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final Color iconBgColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: textColor, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: AppTextStyles.displayMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w800,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: textColor.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Activity Tile ──
class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String time;
  final bool isDark;

  const _ActivityTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.time,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.h;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: AppTextStyles.caption.copyWith(
                    color: colors.textCaption,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile Menu Item ──
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.h;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 15,
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: colors.textCaption,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: colors.navInactive, size: 22),
          ],
        ),
      ),
    );
  }
}
=======
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.h;
    final isDark = context.isDark;

    return Column(
      children: [
        // ── PROFILE HEADER ──
        Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.black,
                      AppColors.grey900,
                      AppColors.yellow.withValues(alpha: 0.06),
                    ]
                  : [
                      const Color(0xFFF8F7F2),
                      const Color(0xFFF0EDE4),
                      AppColors.yellow.withValues(alpha: 0.08),
                    ],
              stops: const [0.0, 0.6, 1.0],
            ),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          child: Stack(
            children: [
              // Decorative circle accents
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.yellow.withValues(alpha: isDark ? 0.04 : 0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: -20,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.yellow.withValues(alpha: isDark ? 0.03 : 0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Profile',
                          style: AppTextStyles.displayLarge.copyWith(
                            color:
                                isDark ? AppColors.white : AppColors.grey900,
                            
                          ),
                        ),
                        Row(
                          children: [
                            _HeaderIconButton(
                              icon: Icons.share_outlined,
                              isDark: isDark,
                              onTap: () {},
                            ),
                            const SizedBox(width: 8),
                            _HeaderIconButton(
                              icon: Icons.settings_outlined,
                              isDark: isDark,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Profile info – centered layout
                    Center(
                      child: Column(
                        children: [
                          // Avatar with ring + badge
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              // Outer glow ring
                              Container(
                                width: 108,
                                height: 108,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: AppColors.yellow
                                        .withValues(alpha: 0.25),
                                    width: 4,
                                  ),
                                ),
                              ),
                              // Inner avatar
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppColors.yellow, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.yellow
                                          .withValues(alpha: 0.2),
                                      blurRadius: 18,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: isDark
                                            ? [
                                                AppColors.grey700,
                                                AppColors.grey800
                                              ]
                                            : [
                                                AppColors.grey200,
                                                const Color(0xFFD0D0D0)
                                              ],
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'SP',
                                        style: AppTextStyles.displayMedium
                                            .copyWith(
                                          color: isDark
                                              ? AppColors.white
                                              : AppColors.grey900,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 32,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Verified badge
                              Positioned(
                                bottom: -8,
                                right: -8,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.yellow,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark
                                          ? AppColors.black
                                          : const Color(0xFFF8F7F2),
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.yellow
                                            .withValues(alpha: 0.3),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.check_rounded,
                                      color: AppColors.black, size: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          // Name
                          Text(
                            'Soham Pawar',
                            style: AppTextStyles.headlineLarge.copyWith(
                              color: isDark
                                  ? AppColors.white
                                  : AppColors.grey900,
                              fontWeight: FontWeight.w800,
                              fontSize: 26,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Location
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on_outlined,
                                  color: isDark
                                      ? AppColors.grey300
                                      : AppColors.grey600,
                                  size: 15),
                              const SizedBox(width: 4),
                              Text(
                                'Koramangala, Bangalore',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark
                                      ? AppColors.grey300
                                      : AppColors.grey600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Badge chips row
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _BadgeChip(
                                icon: Icons.military_tech_rounded,
                                label: 'SUPER NEIGHBOR',
                                color: AppColors.yellow,
                                isDark: isDark,
                              ),
                              const SizedBox(width: 8),
                              _BadgeChip(
                                icon: Icons.calendar_today_rounded,
                                label: 'SINCE 2024',
                                color: isDark
                                    ? AppColors.grey300
                                    : AppColors.grey600,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── SCROLLABLE CONTENT ──
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Stats row ──
                Row(
                  children: [
                    _StatCard(
                      icon: Icons.flag_rounded,
                      value: '12',
                      label: 'Reports\nResolved',
                      backgroundColor:
                          isDark ? AppColors.grey900 : const Color(0xFF2D2D2D),
                      textColor: AppColors.yellow,
                      borderColor:
                          isDark ? AppColors.grey700 : const Color(0xFF3D3D3D),
                      iconBgColor: AppColors.yellow.withValues(alpha: 0.15),
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      icon: Icons.volunteer_activism_rounded,
                      value: '4',
                      label: 'Resources\nShared',
                      backgroundColor: colors.card,
                      textColor: colors.textPrimary,
                      borderColor: colors.divider,
                      iconBgColor: isDark
                          ? AppColors.grey700
                          : AppColors.grey200,
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      icon: Icons.bolt_rounded,
                      value: '156',
                      label: 'Impact\nScore',
                      backgroundColor: AppColors.yellow,
                      textColor: AppColors.black,
                      borderColor: AppColors.yellow,
                      iconBgColor: AppColors.black.withValues(alpha: 0.1),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Community Level Progress ──
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.yellow.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: colors.cardShadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.yellow.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.trending_up_rounded,
                                color: AppColors.yellow, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Community Level',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: colors.textPrimary,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Level 5 — Active Contributor',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.yellow,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '72%',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.yellow,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(
                          children: [
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.grey800
                                    : AppColors.grey200,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: 0.72,
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFD600),
                                      Color(0xFFFFC107),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.yellow
                                          .withValues(alpha: 0.4),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '28 more points to reach Level 6',
                        style: AppTextStyles.caption.copyWith(
                          color: colors.textCaption,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Recent Activity ──
                Text(
                  'Recent Activity',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                          color: colors.cardShadow,
                          blurRadius: 6,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    children: [
                      _ActivityTile(
                        icon: Icons.report_outlined,
                        iconColor: AppColors.red,
                        title: 'Reported a pothole on 5th Cross',
                        time: '2 hours ago',
                        isDark: isDark,
                      ),
                      Divider(
                          height: 1, color: colors.divider, indent: 60),
                      _ActivityTile(
                        icon: Icons.handshake_outlined,
                        iconColor: AppColors.green,
                        title: 'Shared power drill with neighbor',
                        time: 'Yesterday',
                        isDark: isDark,
                      ),
                      Divider(
                          height: 1, color: colors.divider, indent: 60),
                      _ActivityTile(
                        icon: Icons.event_outlined,
                        iconColor: const Color(0xFF42A5F5),
                        title: 'Joined community cleanup drive',
                        time: '3 days ago',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Menu items ──
                Text(
                  'Settings',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                          color: colors.cardShadow,
                          blurRadius: 6,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    children: [
                      _ProfileMenuItem(
                        icon: Icons.favorite_outline_rounded,
                        iconColor: AppColors.red,
                        title: 'My Contributions',
                        subtitle: '12 reports, 4 resources',
                        onTap: () {},
                      ),
                      Divider(
                          height: 1, color: colors.divider, indent: 60),
                      _ProfileMenuItem(
                        icon: Icons.military_tech_outlined,
                        iconColor: AppColors.yellow,
                        title: 'Badges & Achievements',
                        subtitle: '3 badges earned',
                        onTap: () {},
                      ),
                      Divider(
                          height: 1, color: colors.divider, indent: 60),
                      _ProfileMenuItem(
                        icon: Icons.location_on_outlined,
                        iconColor: const Color(0xFF42A5F5),
                        title: 'Saved Locations',
                        subtitle: '2 saved places',
                        onTap: () {},
                      ),
                      Divider(
                          height: 1, color: colors.divider, indent: 60),
                      _ProfileMenuItem(
                        icon: Icons.notifications_outlined,
                        iconColor: AppColors.green,
                        title: 'Notifications',
                        subtitle: 'Manage alerts',
                        onTap: () {},
                      ),
                      Divider(
                          height: 1, color: colors.divider, indent: 60),
                      _ProfileMenuItem(
                        icon: Icons.shield_outlined,
                        iconColor: const Color(0xFF7E57C2),
                        title: 'Privacy & Security',
                        subtitle: 'Account settings',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Appearance toggle ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                          color: colors.cardShadow,
                          blurRadius: 6,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors.menuIconBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          context.isDark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: AppColors.yellow,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Appearance',
                                style: AppTextStyles.labelLarge.copyWith(
                                    fontSize: 15,
                                    color: colors.textPrimary)),
                            const SizedBox(height: 2),
                            Text(
                              context.isDark ? 'Dark mode' : 'Light mode',
                              style: AppTextStyles.caption
                                  .copyWith(color: colors.textCaption),
                            ),
                          ],
                        ),
                      ),
                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: ThemeProvider.instance,
                        builder: (context, mode, child) {
                          return Switch(
                            value: mode == ThemeMode.dark,
                            onChanged: (v) =>
                                ThemeProvider.instance.toggleTheme(),
                            activeThumbColor: AppColors.yellow,
                            activeTrackColor:
                                AppColors.yellow.withValues(alpha: 0.3),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Sign out button ──
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.logout_rounded,
                        size: 18,
                        color: isDark ? AppColors.grey300 : AppColors.grey600),
                    label: Text(
                      'Sign Out',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isDark ? AppColors.grey300 : AppColors.grey600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(
                        color: isDark ? AppColors.grey700 : AppColors.grey300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Hemisphere v1.0.0',
                    style: AppTextStyles.caption
                        .copyWith(color: colors.textCaption),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Header Icon Button ──
class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.grey800.withValues(alpha: 0.6)
              : AppColors.white.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark
                ? AppColors.grey700.withValues(alpha: 0.5)
                : AppColors.grey300.withValues(alpha: 0.5),
          ),
        ),
        child: Icon(icon,
            color: isDark ? AppColors.grey300 : AppColors.grey600, size: 20),
      ),
    );
  }
}

// ── Badge Chip ──
class _BadgeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  const _BadgeChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.grey800.withValues(alpha: 0.7)
            : AppColors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ──
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final Color iconBgColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: textColor, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: AppTextStyles.displayMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w800,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: textColor.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Activity Tile ──
class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String time;
  final bool isDark;

  const _ActivityTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.time,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.h;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: AppTextStyles.caption.copyWith(
                    color: colors.textCaption,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile Menu Item ──
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.h;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 15,
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: colors.textCaption,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: colors.navInactive, size: 22),
          ],
        ),
      ),
    );
  }
}
>>>>>>> 345e37f98aab254ec09547299a58d8adbac3233b
