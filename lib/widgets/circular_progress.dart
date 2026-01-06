import 'package:birthday_progress/utils/constants.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircularProgress extends StatefulWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;
  final Duration animationDuration;

  const CircularProgress({
    super.key,
    required this.progress,
    this.size = 150.0,
    this.strokeWidth = 18.0,
    this.progressColor = AppConstants.progressRingColor,
    this.trackColor = AppConstants.progressTrackColor,
    this.animationDuration = AppConstants.progressAnimationDuration,
  });

  @override
  State<CircularProgress> createState() => _CircularProgressState();
}

class _CircularProgressState extends State<CircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _currentProgress = widget.progress;
    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant CircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animateProgressTo(widget.progress);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animateProgressTo(double newProgress) {
    _progressAnimation = Tween<double>(
      begin: _currentProgress,
      end: newProgress,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController
      ..reset()
      ..forward();

    _currentProgress = newProgress;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          final int percentage =
              (_progressAnimation.value.clamp(0.0, 1.0) * 100).toInt();

          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _ProgressRingPainter(
                    progress: _progressAnimation.value,
                    strokeWidth: widget.strokeWidth,
                    progressColor: widget.progressColor,
                    trackColor: widget.trackColor,
                  ),
                ),
                Positioned(
                  top: widget.size / 3,
                  child: Icon(Icons.cake_rounded, size: widget.size / 3),
                ),
                Text(
                  '$percentage',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: AppConstants.primaryTextColor,
                      ),
                ),
              ],
            ),
          );
        });
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;

  _ProgressRingPainter({
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

    // // ---------- PROGRESS ----------
    final clampedProgress = progress.clamp(0.0, 1.0);
    final progressSweep = totalSweep * clampedProgress;

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
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
