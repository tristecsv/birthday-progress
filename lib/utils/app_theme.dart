import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF2F80ED),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2F80ED),
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Color(0xFF1F1F1F),
          onSurfaceVariant: Color(0xFF666666),
          outlineVariant: Color(0xFFE0E0E0),
          surfaceContainerHighest: Color(0xFFECECEC),
          surfaceContainer: Color(0xFFF5F5F5),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF1F1F1F)),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFF2F80ED),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2F80ED),
          onPrimary: Colors.white,
          surface: Color(0xFF121212),
          onSurface: Colors.white,
          onSurfaceVariant: Color(0xFFAAAAAA),
          outlineVariant: Color(0xFF333333),
          surfaceContainerHighest: Color(0xFF222222),
          surfaceContainer: Color(0xFF1E1E1E),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      );
}
