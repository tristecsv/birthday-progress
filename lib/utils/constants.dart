import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // ============================================================================
  // COLORES
  // ============================================================================

  /// Color primario de texto (casi negro).
  static const Color primaryTextColor = Color(0xFF1F1F1F);

  /// Color secundario de texto (gris).
  static const Color secondaryTextColor = Color(0xFF666666);

  /// Color de fondo de los dropdowns.
  static const Color dropdownBackgroundColor = Color(0xFFF5F5F5);

  /// Color del borde de los dropdowns.
  static const Color dropdownBorderColor = Color(0xFFE0E0E0);

  /// Color de la pista del anillo de progreso.
  static const Color progressTrackColor = Color(0xFFECECEC);

  /// Color del anillo de progreso activo.
  static const Color progressRingColor = Color(0xFF2F80ED);

  // ============================================================================
  // TEXTOS
  // ============================================================================

  /// Nombres de los meses en español (índice 0 = enero, 11 = diciembre).
  static const List<String> monthNamesSpanish = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  /// Nombres de los meses en español capitalizados.
  static const List<String> monthNamesSpanishCapitalized = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  // ============================================================================
  // ANIMACIONES
  // ============================================================================

  /// Duración de la animación del progreso del anillo.
  static const Duration progressAnimationDuration = Duration(milliseconds: 600);

  // ============================================================================
  // DIMENSIONES
  // ============================================================================

  /// Tamaño por defecto del anillo de progreso.
  static const double defaultProgressRingSize = 150.0;

  /// Grosor por defecto del trazo del anillo.
  static const double defaultStrokeWidth = 8.0;

  /// Radio de borde de los dropdowns.
  static const double dropdownBorderRadius = 12.0;
}
