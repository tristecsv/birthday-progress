import 'package:birthday_progress/widgets/progress_ring_painter.dart';
import 'package:flutter/material.dart';

class CircularProgressView extends StatelessWidget {
  final double progress;
  final int percentage;
  final int days;
  final double size;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;
  final bool showPercent;
  final bool showDays;

  const CircularProgressView({
    super.key,
    required this.progress,
    required this.percentage,
    required this.days,
    required this.size,
    required this.strokeWidth,
    required this.progressColor,
    required this.trackColor,
    required this.showPercent,
    required this.showDays,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final percentBottom = size / 6;
    final daysBottom = showPercent ? 0.0 : size / 6;

    final percentText = showDays ? '$percentage%' : '$percentage';

    return SizedBox(
      width: size,
      height: size + 20,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: ProgressRingPainter(
              progress: progress,
              strokeWidth: strokeWidth,
              progressColor: progressColor,
              trackColor: trackColor,
            ),
          ),
          Positioned(
            top: size / 3,
            child: Icon(Icons.cake_rounded, size: size / 3),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            bottom: showPercent
                ? (showDays ? percentBottom : percentBottom - 10)
                : percentBottom + 10,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: showPercent ? 1 : 0,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutBack,
                style: (!showDays)
                    ? theme.textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: theme.colorScheme.onSurface,
                      )
                    : theme.textTheme.bodyMedium!.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        fontSize: 22,
                      ),
                child: Text(percentText),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            bottom: daysBottom,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: showDays ? 1 : 0,
              child: Text(
                '$days días',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
