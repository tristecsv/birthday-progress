import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;

  ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.trackColor,
  });

  static const paintingStyle = PaintingStyle.stroke;
  static const strokeCap = StrokeCap.round;

  static const startAngle = 150 * math.pi / 180;
  static const totalSweep = 240 * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // ---------- TRACK ----------
    final trackPaint = Paint()
      ..color = trackColor
      ..style = paintingStyle
      ..strokeWidth = strokeWidth
      ..strokeCap = strokeCap;

    canvas.drawArc(
      rect,
      startAngle,
      totalSweep,
      false,
      trackPaint,
    );

    // ---------- PROGRESS ----------
    final progressSweep = totalSweep * progress;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = paintingStyle
      ..strokeWidth = strokeWidth
      ..strokeCap = strokeCap;

    canvas.drawArc(
      rect,
      startAngle,
      progressSweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
