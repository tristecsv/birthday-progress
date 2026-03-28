import 'package:birthday_progress/widgets/circular_progress_view.dart';
import 'package:flutter/material.dart';

class CircularProgress extends StatefulWidget {
  final double progress;
  final int days;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? trackColor;
  final Duration animationDuration;
  final bool showPercent;
  final bool showDays;

  const CircularProgress({
    super.key,
    required this.progress,
    required this.days,
    this.size = 150.0,
    this.strokeWidth = 18.0,
    this.progressColor,
    this.trackColor,
    this.animationDuration = const Duration(milliseconds: 600),
    this.showPercent = true,
    this.showDays = true,
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
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final progress = _progressAnimation.value.clamp(0.0, 1.0);
        final percentage = (progress * 100).toInt();

        return CircularProgressView(
          progress: progress,
          percentage: percentage,
          days: widget.days,
          size: widget.size,
          strokeWidth: widget.strokeWidth,
          progressColor: widget.progressColor ?? cs.primary,
          trackColor: widget.trackColor ?? cs.surfaceContainerHighest,
          showPercent: widget.showPercent,
          showDays: widget.showDays,
        );
      },
    );
  }
}
