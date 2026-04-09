import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hemisphere/theme/app_theme.dart';

class EmissionResultScreen extends StatefulWidget {
  final double emissionKg;
  final double emissionKgOriginal;
  final double emissionKgHeuristic;
  final double emissionKgNew;

  const EmissionResultScreen({
    Key? key, 
    required this.emissionKg,
    required this.emissionKgOriginal,
    required this.emissionKgHeuristic,
    required this.emissionKgNew,
  }) : super(key: key);

  @override
  State<EmissionResultScreen> createState() => _EmissionResultScreenState();
}

class _EmissionResultScreenState extends State<EmissionResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // Let's define the thresholds for Green, Yellow, and Red
  // For daily typical vehicle emissions:
  // < 10 kg -> Green
  // 10 - 30 kg -> Yellow
  // > 30 kg -> Red

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    double targetValue = 0.0;
    if (widget.emissionKg <= 10.0) {
      targetValue = (widget.emissionKg / 10.0) * 0.333;
    } else if (widget.emissionKg <= 30.0) {
      targetValue = 0.333 + ((widget.emissionKg - 10.0) / 20.0) * 0.333;
    } else {
      double maxRed = max(90.0, widget.emissionKg * 1.5);
      targetValue = 0.666 + ((widget.emissionKg - 30.0) / (maxRed - 30.0)) * 0.334;
    }
    
    if (targetValue > 1.0) targetValue = 1.0;

    _animation = Tween<double>(begin: 0.0, end: targetValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getCategoryColor() {
    if (widget.emissionKg <= 10.0) return AppColors.green;
    if (widget.emissionKg <= 30.0) return AppColors.yellow;
    return AppColors.red;
  }

  String _getCategoryText() {
    if (widget.emissionKg <= 10.0) return 'Safe';
    if (widget.emissionKg <= 30.0) return 'Moderate';
    return 'Dangerous';
  }

  String _getContextualText() {
    if (widget.emissionKg <= 10.0) {
      return 'Great job! Your carbon footprint is relatively low.';
    } else if (widget.emissionKg <= 30.0) {
      return 'You are within the average range. Consider carpooling or public transit when possible to lower emissions further.';
    } else {
      return 'Your emissions are high. Corrective measures: try optimizing your routes, reducing idle time, maintaining proper tire pressure, or switching to eco-friendly transport modes.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor();
    return Scaffold(
      backgroundColor: context.h.background,
      appBar: AppBar(
        title: const Text('Emission Result'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    children: [
                      const Spacer(),
            // Meter
            SizedBox(
              height: 250,
              width: double.infinity,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: MeterPainter(_animation.value),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Value
            Text(
              '${widget.emissionKg.toStringAsFixed(2)} kg CO2',
              style: AppTextStyles.displayMedium.copyWith(color: catColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Average Result',
              style: AppTextStyles.labelLarge.copyWith(color: context.h.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildModelColumn('Base Value', widget.emissionKgOriginal, context.h.textSecondary),
                Container(height: 40, width: 1, color: context.h.divider),
                _buildModelColumn('Heuristic Value', widget.emissionKgHeuristic, context.h.textSecondary),
                Container(height: 40, width: 1, color: context.h.divider),
                _buildModelColumn('Upper Limit', widget.emissionKgNew, context.h.textSecondary),
              ],
            ),
            const SizedBox(height: 16),
            // Category
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: catColor),
              ),
              child: Text(
                _getCategoryText().toUpperCase(),
                style: AppTextStyles.labelLarge.copyWith(color: catColor, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
            // Contextual Text
            Text(
              _getContextualText(),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(color: context.h.textPrimary, height: 1.5),
            ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true); // Pop out back to logs/profile
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: Text(
                          'Done',
                          style: AppTextStyles.buttonMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
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

  Widget _buildModelColumn(String label, double value, Color textColor) {
    return Expanded(
      child: Column(
        children: [
          Text(label, textAlign: TextAlign.center, style: AppTextStyles.labelMedium.copyWith(color: textColor)),
          const SizedBox(height: 4),
          Text('${value.toStringAsFixed(2)} kg', textAlign: TextAlign.center, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: context.h.textPrimary)),
        ],
      ),
    );
  }
}

class MeterPainter extends CustomPainter {
  final double percentage; // 0.0 to 1.0

  MeterPainter(this.percentage);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = min(size.width / 2, size.height) - 10;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw Green Arc
    paint.color = AppColors.green;
    canvas.drawArc(rect, pi, pi / 3, false, paint);

    // Draw Yellow Arc
    paint.color = AppColors.yellow;
    canvas.drawArc(rect, pi + pi / 3, pi / 3, false, paint);

    // Draw Red Arc
    paint.color = AppColors.red;
    canvas.drawArc(rect, pi + 2 * pi / 3, pi / 3, false, paint);

    // Draw Needle
    final needleAngle = pi + (percentage * pi);
    final needleLength = radius - 10;

    final needleEndX = center.dx + needleLength * cos(needleAngle);
    final needleEndY = center.dy + needleLength * sin(needleAngle);

    final needlePaint = Paint()
      ..color = AppColors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, Offset(needleEndX, needleEndY), needlePaint);

    // Draw center dot
    final centerDotPaint = Paint()..color = AppColors.white;
    canvas.drawCircle(center, 10, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant MeterPainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}
