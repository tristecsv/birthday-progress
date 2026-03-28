import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScope extends InheritedNotifier<SettingsNotifier> {
  const SettingsScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static SettingsNotifier of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsScope>()!.notifier!;
}

class SettingsNotifier extends ChangeNotifier {
  static const _keyThemeMode = 'birthday_themeMode';
  static const _keyShowPercent = 'birthday_showPercent';
  static const _keyShowDays = 'birthday_showDays';

  Settings _settings = const Settings();
  SharedPreferences? _prefs;

  Settings get settings => _settings;
  set settings(Settings s) {
    _settings = s;
    notifyListeners();
    _save(s);
  }

  SettingsNotifier();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final index = _prefs!.getInt(_keyThemeMode);

    _settings = _settings.copyWith(
      themeMode: index != null ? ThemeMode.values[index] : null,
      showPercent: _prefs!.getBool(_keyShowPercent),
      showDays: _prefs!.getBool(_keyShowDays),
    );
    notifyListeners();
  }

  Future<void> _save(Settings s) async {
    _prefs ??= await SharedPreferences.getInstance();

    await Future.wait([
      _prefs!.setInt(_keyThemeMode, s.themeMode.index),
      _prefs!.setBool(_keyShowPercent, s.showPercent),
      _prefs!.setBool(_keyShowDays, s.showDays),
    ]);
  }
}

class Settings {
  final ThemeMode themeMode;
  final bool showPercent;
  final bool showDays;

  const Settings({
    this.themeMode = ThemeMode.system,
    this.showPercent = true,
    this.showDays = false,
  });

  bool isDark(BuildContext context) {
    if (themeMode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return themeMode == ThemeMode.dark;
  }

  Settings copyWith({
    ThemeMode? themeMode,
    bool? showPercent,
    bool? showDays,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      showPercent: showPercent ?? this.showPercent,
      showDays: showDays ?? this.showDays,
    );
  }
}
