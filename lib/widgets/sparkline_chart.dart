import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../theme/app_colors.dart';

class SparklineChart extends StatelessWidget {
  const SparklineChart({
    super.key,
    required this.data,
    this.lineColor = AppColors.primary,
    this.fillColor,
    this.height = 140,
    this.strokeWidth = 3,
    this.label,
  });

  final List<double> data;
  final Color lineColor;
  final Color? fillColor;
  final double height;
  final double strokeWidth;
  final String? label;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(height: height);
    }

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(
          data: data,
          lineColor: lineColor,
          fillColor: fillColor ?? lineColor.withValues(alpha: 0.12),
          strokeWidth: strokeWidth,
        ),
        child: label == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    label!,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppColors.muted),
                  ),
                ),
              ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  final List<double> data;
  final Color lineColor;
  final Color fillColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final Path linePath = Path();
    final Path fillPath = Path();

    final double maxValue =
        data.reduce((double a, double b) => a > b ? a : b).clamp(1, double.infinity);
    final double minValue =
        data.reduce((double a, double b) => a < b ? a : b);
    final double span = (maxValue - minValue).abs() < 0.01
        ? 1
        : maxValue - minValue;

    for (int i = 0; i < data.length; i++) {
      final double x = data.length == 1
          ? size.width
          : (i / (data.length - 1)) * size.width;
      final double normalized = (data[i] - minValue) / span;
      final double y = size.height - (normalized * size.height);

      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

