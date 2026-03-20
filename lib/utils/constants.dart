class AppConstants {
  AppConstants._();

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
