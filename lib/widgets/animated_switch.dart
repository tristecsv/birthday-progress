import 'package:flutter/material.dart';

class AnimatedSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget Function(BuildContext context, bool isActive)? thumbBuilder;

  const AnimatedSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.thumbBuilder,
  });

  @override
  State<AnimatedSwitch> createState() => _AnimatedSwitchState();
}

class _AnimatedSwitchState extends State<AnimatedSwitch>
    with SingleTickerProviderStateMixin {
  static const double _width = 84;
  static const double _height = 42;
  static const double _thumbSize = 34;
  static const double _padding = 4;
  static const double _travelDistance = _width - (_padding * 2) - _thumbSize;

  late final AnimationController _controller;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: widget.value ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_dragging && oldWidget.value != widget.value) {
      _controller.animateTo(
        widget.value ? 1.0 : 0.0,
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    widget.onChanged(!widget.value);
  }

  void _handleDragStart(DragStartDetails details) {
    _dragging = true;
    _controller.stop();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = (details.primaryDelta ?? 0) / _travelDistance;
    _controller.value = (_controller.value + delta).clamp(0.0, 1.0);
  }

  void _handleDragEnd(DragEndDetails details) {
    _dragging = false;

    final velocity = details.primaryVelocity ?? 0;
    final bool target;

    if (velocity.abs() > 250) {
      target = velocity > 0;
    } else {
      target = _controller.value >= 0.5;
    }

    widget.onChanged(target);

    _controller.animateTo(
      target ? 1.0 : 0.0,
      curve: Curves.easeOutBack,
    );
  }

  Widget _defaultThumb(ColorScheme cs) {
    return Container(
      width: _thumbSize,
      height: _thumbSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cs.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggle,
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final isActive = t >= 0.5;

          final trackColor = Color.lerp(
            cs.surfaceContainerHighest,
            cs.primary.withOpacity(0.18),
            t,
          )!;

          final trackBorder = Color.lerp(
            cs.outlineVariant,
            cs.primary.withOpacity(0.65),
            t,
          )!;

          return Container(
            width: _width,
            height: _height,
            padding: const EdgeInsets.all(_padding),
            decoration: BoxDecoration(
              color: trackColor,
              borderRadius: BorderRadius.circular(_height / 2),
              border: Border.all(color: trackBorder),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.lerp(
                    Alignment.centerLeft,
                    Alignment.centerRight,
                    t,
                  )!,
                  child: Transform.scale(
                    scale: _dragging ? 1.04 : 1.0,
                    child: widget.thumbBuilder?.call(context, isActive) ??
                        _defaultThumb(cs),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
