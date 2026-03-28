import 'package:birthday_progress/logic/widget_update_service.dart';
import 'package:birthday_progress/state/settings_notifier.dart';
import 'package:birthday_progress/widgets/animated_switch.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  OverlayEntry? _overlayEntry;

  void _openMenu() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeMenu,
              behavior: HitTestBehavior.translucent,
            ),
          ),
          const Positioned(
            top: kToolbarHeight + 20,
            right: 5,
            child: _SettingsCard(),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _closeMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: IconButton(
            tooltip: 'Ajustes',
            icon: Icon(Icons.tune_rounded, color: onSurfaceVariant),
            onPressed: _openMenu,
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final notifier = SettingsScope.of(context);
    final settings = notifier.settings;
    final isDark = settings.isDark(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.45)),
        ),
        child: Column(
          children: [
            _RowItem(
              label: 'Tema oscuro',
              child: AnimatedSwitch(
                value: isDark,
                onChanged: (v) async {
                  notifier.settings = settings.copyWith(
                    themeMode: v ? ThemeMode.dark : ThemeMode.light,
                  );
                  await WidgetUpdateService.updateWidget();
                },
                thumbBuilder: (_, active) => _CustomThumb(active, cs),
              ),
            ),
            const SizedBox(height: 12),
            _RowItem(
              label: 'Mostrar %',
              child: AnimatedSwitch(
                value: settings.showPercent,
                onChanged: (v) async {
                  notifier.settings = settings.copyWith(showPercent: v);
                  await WidgetUpdateService.updateWidget();
                },
              ),
            ),
            const SizedBox(height: 12),
            _RowItem(
              label: 'Mostrar días',
              child: AnimatedSwitch(
                value: settings.showDays,
                onChanged: (v) async {
                  notifier.settings = settings.copyWith(showDays: v);
                  await WidgetUpdateService.updateWidget();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final String label;
  final Widget child;

  const _RowItem({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: cs.onSurface, fontSize: 14),
        ),
        child,
      ],
    );
  }
}

class _CustomThumb extends StatelessWidget {
  final bool active;
  final ColorScheme cs;
  const _CustomThumb(this.active, this.cs);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cs.primary,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween(begin: 0.8, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        child: Icon(
          active ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          key: ValueKey(active),
          color: cs.onPrimary,
          size: 18,
        ),
      ),
    );
  }
}
