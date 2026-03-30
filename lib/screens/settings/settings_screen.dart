<<<<<<< HEAD
import 'package:flutter/material.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.h;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.headlineMedium.copyWith(color: colors.textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: AppTextStyles.headlineSmall.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeProvider.instance,
              builder: (context, themeMode, _) {
                return Container(
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colors.cardShadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _ThemeOption(
                        icon: Icons.dark_mode_rounded,
                        title: 'Dark',
                        subtitle: 'Dark backgrounds, light text',
                        isSelected: themeMode == ThemeMode.dark,
                        onTap: () =>
                            ThemeProvider.instance.setThemeMode(ThemeMode.dark),
                        colors: colors,
                      ),
                      Divider(height: 1, color: colors.divider, indent: 56),
                      _ThemeOption(
                        icon: Icons.light_mode_rounded,
                        title: 'Light',
                        subtitle: 'Light backgrounds, dark text',
                        isSelected: themeMode == ThemeMode.light,
                        onTap: () =>
                            ThemeProvider.instance.setThemeMode(ThemeMode.light),
                        colors: colors,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final HemisphereColors colors;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.yellow : colors.iconSubtle, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: colors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(color: colors.textCaption),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.yellow, size: 22)
            else
              Icon(Icons.circle_outlined, color: colors.divider, size: 22),
          ],
        ),
      ),
    );
  }
}
=======
import 'package:flutter/material.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.h;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.headlineMedium.copyWith(color: colors.textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: AppTextStyles.headlineSmall.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeProvider.instance,
              builder: (context, themeMode, _) {
                return Container(
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colors.cardShadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _ThemeOption(
                        icon: Icons.dark_mode_rounded,
                        title: 'Dark',
                        subtitle: 'Dark backgrounds, light text',
                        isSelected: themeMode == ThemeMode.dark,
                        onTap: () =>
                            ThemeProvider.instance.setThemeMode(ThemeMode.dark),
                        colors: colors,
                      ),
                      Divider(height: 1, color: colors.divider, indent: 56),
                      _ThemeOption(
                        icon: Icons.light_mode_rounded,
                        title: 'Light',
                        subtitle: 'Light backgrounds, dark text',
                        isSelected: themeMode == ThemeMode.light,
                        onTap: () =>
                            ThemeProvider.instance.setThemeMode(ThemeMode.light),
                        colors: colors,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final HemisphereColors colors;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.yellow : colors.iconSubtle, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: colors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(color: colors.textCaption),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.yellow, size: 22)
            else
              Icon(Icons.circle_outlined, color: colors.divider, size: 22),
          ],
        ),
      ),
    );
  }
}
>>>>>>> 345e37f98aab254ec09547299a58d8adbac3233b
