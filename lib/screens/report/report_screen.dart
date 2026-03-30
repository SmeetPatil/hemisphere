<<<<<<< HEAD
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'report_form_screen.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('Report', style: AppTextStyles.displayLarge.copyWith(color: context.h.textPrimary)),
            const SizedBox(height: 6),
            Text(
              'Help keep your neighborhood safe and clean',
              style: AppTextStyles.bodyMedium.copyWith(color: context.h.textSecondary),
            ),
            const SizedBox(height: 24),
            // Report Accident Button
            Expanded(
              child: _ReportActionCard(
                title: 'Report\nAccident',
                subtitle: 'Alert emergency services & neighbors about road accidents or hazards',
                icon: Icons.warning_rounded,
                iconColor: AppColors.red,
                gradient: [
                  AppColors.red.withValues(alpha: 0.2),
                  AppColors.red.withValues(alpha: 0.05),
                ],
                borderColor: AppColors.red.withValues(alpha: 0.3),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ReportFormScreen(
                        reportType: ReportType.accident,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Report Waste Button
            Expanded(
              child: _ReportActionCard(
                title: 'Report\nWaste',
                subtitle: 'Flag overflowing bins, illegal dumps & unclean areas for cleanup',
                icon: Icons.delete_sweep_rounded,
                iconColor: AppColors.yellow,
                gradient: [
                  AppColors.yellow.withValues(alpha: 0.15),
                  AppColors.yellow.withValues(alpha: 0.03),
                ],
                borderColor: AppColors.yellow.withValues(alpha: 0.3),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ReportFormScreen(
                        reportType: ReportType.waste,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Recent reports indicator
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.h.card,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: context.h.cardShadow, blurRadius: 4, offset: const Offset(0, 1)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.check_circle_outline_rounded,
                        color: AppColors.green, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your reports are making a difference!',
                            style: AppTextStyles.labelLarge.copyWith(fontSize: 13)),
                        const SizedBox(height: 2),
                        Text('3 of your reports resolved this week',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ReportActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final List<Color> gradient;
  final Color borderColor;
  final VoidCallback onTap;

  const _ReportActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.gradient,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const Spacer(),
              Text(title, style: AppTextStyles.displayMedium.copyWith(color: context.h.textPrimary)),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.h.textSecondary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'TAP TO REPORT',
                    style: AppTextStyles.caption.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, color: iconColor, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
=======
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'report_form_screen.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('Report', style: AppTextStyles.displayLarge.copyWith(color: context.h.textPrimary)),
            const SizedBox(height: 6),
            Text(
              'Help keep your neighborhood safe and clean',
              style: AppTextStyles.bodyMedium.copyWith(color: context.h.textSecondary),
            ),
            const SizedBox(height: 24),
            // Report Accident Button
            Expanded(
              child: _ReportActionCard(
                title: 'Report\nAccident',
                subtitle: 'Alert emergency services & neighbors about road accidents or hazards',
                icon: Icons.warning_rounded,
                iconColor: AppColors.red,
                gradient: [
                  AppColors.red.withValues(alpha: 0.2),
                  AppColors.red.withValues(alpha: 0.05),
                ],
                borderColor: AppColors.red.withValues(alpha: 0.3),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ReportFormScreen(
                        reportType: ReportType.accident,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Report Waste Button
            Expanded(
              child: _ReportActionCard(
                title: 'Report\nWaste',
                subtitle: 'Flag overflowing bins, illegal dumps & unclean areas for cleanup',
                icon: Icons.delete_sweep_rounded,
                iconColor: AppColors.yellow,
                gradient: [
                  AppColors.yellow.withValues(alpha: 0.15),
                  AppColors.yellow.withValues(alpha: 0.03),
                ],
                borderColor: AppColors.yellow.withValues(alpha: 0.3),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ReportFormScreen(
                        reportType: ReportType.waste,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Recent reports indicator
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.h.card,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: context.h.cardShadow, blurRadius: 4, offset: const Offset(0, 1)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.check_circle_outline_rounded,
                        color: AppColors.green, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your reports are making a difference!',
                            style: AppTextStyles.labelLarge.copyWith(fontSize: 13)),
                        const SizedBox(height: 2),
                        Text('3 of your reports resolved this week',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ReportActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final List<Color> gradient;
  final Color borderColor;
  final VoidCallback onTap;

  const _ReportActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.gradient,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const Spacer(),
              Text(title, style: AppTextStyles.displayMedium.copyWith(color: context.h.textPrimary)),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.h.textSecondary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'TAP TO REPORT',
                    style: AppTextStyles.caption.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, color: iconColor, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
>>>>>>> 345e37f98aab254ec09547299a58d8adbac3233b
