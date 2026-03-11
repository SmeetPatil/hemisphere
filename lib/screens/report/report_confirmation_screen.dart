import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'report_form_screen.dart';

class ReportConfirmationScreen extends StatefulWidget {
  final ReportType reportType;
  final double latitude;
  final double longitude;

  const ReportConfirmationScreen({
    super.key,
    required this.reportType,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<ReportConfirmationScreen> createState() =>
      _ReportConfirmationScreenState();
}

class _ReportConfirmationScreenState extends State<ReportConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool get isAccident => widget.reportType == ReportType.accident;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Animated icon
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: (isAccident ? AppColors.red : AppColors.green)
                        .withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: isAccident ? AppColors.red : AppColors.green,
                    size: 72,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'Report Submitted!',
                      style: AppTextStyles.displayLarge.copyWith(color: context.h.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isAccident
                          ? 'Your accident report has been routed to:'
                          : 'Your waste report has been routed to:',
                      style: AppTextStyles.bodyMedium.copyWith(color: context.h.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Routing info cards
                    ...isAccident
                        ? [
                            _RoutingCard(
                              icon: Icons.local_hospital_rounded,
                              title: 'Nearest Hospital',
                              subtitle: 'Emergency response team alerted',
                              color: AppColors.red,
                            ),
                            const SizedBox(height: 10),
                            _RoutingCard(
                              icon: Icons.local_police_rounded,
                              title: 'Traffic Police',
                              subtitle: 'Patrol unit notified for area management',
                              color: AppColors.yellow,
                            ),
                            const SizedBox(height: 10),
                            _RoutingCard(
                              icon: Icons.people_rounded,
                              title: 'Nearby Residents',
                              subtitle: 'Alert pushed to neighbors within 1 km',
                              color: const Color(0xFF2196F3),
                            ),
                          ]
                        : [
                            _RoutingCard(
                              icon: Icons.cleaning_services_rounded,
                              title: 'Municipal Cleaning Staff',
                              subtitle: 'Assigned for immediate cleanup action',
                              color: AppColors.yellow,
                            ),
                            const SizedBox(height: 10),
                            _RoutingCard(
                              icon: Icons.admin_panel_settings_rounded,
                              title: 'Ward Officer',
                              subtitle: 'Civic authority notified for oversight',
                              color: AppColors.green,
                            ),
                          ],
                    const SizedBox(height: 24),
                    // Location
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: context.h.card,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on,
                              color: AppColors.grey400, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.latitude.toStringAsFixed(6)}, ${widget.longitude.toStringAsFixed(6)}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Report ID: #HEM${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                      style: AppTextStyles.caption.copyWith(color: context.h.textCaption),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              // Done button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Done'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Track Status'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _RoutingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelLarge.copyWith(fontSize: 13, color: context.h.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption.copyWith(color: context.h.textCaption)),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: AppColors.green, size: 20),
        ],
      ),
    );
  }
}
