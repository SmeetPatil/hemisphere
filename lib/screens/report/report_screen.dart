import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'report_form_screen.dart';
import 'sos_form_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/tab_entry_animator.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -30,
                  top: -45,
                  child: TabEntryAnimator(
                    tabIndex: 2,
                    delayMs: 50,
                    child: SvgPicture.asset(
                      'assets/images/report.svg',
                      width: 350,
                      height: 350,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TabEntryAnimator(
                              tabIndex: 2,
                              child: Text(
                                'Report',
                                style: AppTextStyles.displayLarge
                                    .copyWith(color: context.h.textPrimary),
                              ),
                            ),
                            const SizedBox(height: 4),
                            TabEntryAnimator(
                              tabIndex: 2,
                              delayMs: 40,
                              child: Text(
                                'Keep Your City Clean & Safe',
                                style: AppTextStyles.bodyMedium
                                    .copyWith(color: context.h.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // SOS Button
            Expanded(
              child: _ReportActionCard(
                title: 'Send\nSOS Signal',
                subtitle: 'Send an emergency SMS with live location directly to your registered contact.',
                icon: Icons.sos_rounded,
                backgroundColor: AppColors.red, // Make the SOS one red, maybe change accident to orange/violet? 
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SosFormScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Report Accident Button
            Expanded(
              child: _ReportActionCard(
                title: 'Report\nAccident / Construction',
                subtitle: 'Alert emergency services & neighbors about road accidents or hazards',
                icon: Icons.warning_rounded,
                backgroundColor: const Color(0xFFFFA07A), // Orange-ish to leave Red for SOS exclusively
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
                backgroundColor: AppColors.yellow,
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
            const SizedBox(height: 16),
          ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReportActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _ReportActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.black, width: 3),
          boxShadow: const [
            BoxShadow(
              color: AppColors.black,
              blurRadius: 0,
              offset: Offset(4, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.black, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.black,
                          blurRadius: 0,
                          offset: Offset(2, 2),
                        )
                      ],
                    ),
                    child: Icon(icon, color: AppColors.black, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title.replaceAll('\n', ' '), 
                      style: AppTextStyles.displayMedium.copyWith(color: AppColors.black, fontSize: 22),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TAP TO REPORT',
                      style: AppTextStyles.caption.copyWith(
                        color: backgroundColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, color: backgroundColor, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
