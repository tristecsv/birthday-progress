import 'package:birthday_progress/screens/home_screen.dart';
import 'package:birthday_progress/state/settings_notifier.dart';
import 'package:birthday_progress/utils/utils.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsNotifier = SettingsNotifier();
  await settingsNotifier.init();

  runApp(MainApp(settingsNotifier: settingsNotifier));
}

class MainApp extends StatelessWidget {
  final SettingsNotifier settingsNotifier;
  const MainApp({super.key, required this.settingsNotifier});

  @override
  Widget build(BuildContext context) {
    return SettingsScope(
      notifier: settingsNotifier,
      child: Builder(builder: (context) {
        final notifier = SettingsScope.of(context);

        return MaterialApp(
          themeMode: notifier.settings.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          debugShowCheckedModeBanner: false,
          home: const HomeScreen(),
        );
      }),
    );
  }
}
