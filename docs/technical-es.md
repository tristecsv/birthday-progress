# Technical - Birthday Progress

## Estructura 

```
lib/
├── main.dart                         # Entry point Flutter
├── screens/home_screen.dart          # UI principal con DatePicker y CircularProgress
├── logic/
│   ├── birthday_calculator.dart      # Cálculo de progreso (Dart)
│   └── widget_update_service.dart    # MethodChannel para updateWidget
├── data/birthday_storage.dart        # Wrapper SharedPreferences
└── widgets/                          # Widgets reutilizables Flutter

android/app/src/main/kotlin/com/example/birthday_progress/
├── MainActivity.kt                   # FlutterActivity + MethodChannel handler
├── widgets/
│   ├── BirthdayWidgetProvider.kt     # AppWidgetProvider, scheduleAlarm, registros
│   └── BirthdayWidgetRender.kt       # Renderiza bitmap con Canvas (anillo circular)
├── logic/
│   ├── BirthdayCalculator.kt         # Cálculo de progreso (Kotlin)
│   └── TimeChangeSystemReceiver.kt   # BroadcastReceiver eventos sistema
├── worker/WidgetUpdateWorker.kt      # Worker periódico WorkManager
└── data/BirthdayStorage.kt           # Lee SharedPreferences compartidas
```

## Consideraciones de diseño

Aquí listamos las decisiones técnicas importantes y la razón detrás de cada una.

### Duplicar cálculo en Dart y Kotlin

**Qué:** La lógica de cálculo (elapsed / total) existe en ambas capas.

**Por qué:** El widget nativo debe calcular el progreso sin depender de la app en ejecución. Mantener la misma lógica en ambos runtimes garantiza coherencia visual y evita dependencias cruzadas en tiempo de ejecución.

**Consecuencia:** obliga a mantener pruebas o una especificación clara de la fórmula para evitar divergencias.

### SharedPreferences compartido

**Qué:** Un storage simple accesible desde Flutter y Kotlin.

**Por qué:** compatibilidad nativa simple, persistencia instantánea y sin necesidad de IPC complejo.

**Consecuencia:** usar un formato y claves estables (prefijo `flutter.*`) y documentar la estructura (ver sección Persistencia compartida).

### Renderizado en bitmap con Canvas

**Qué:** El anillo se dibuja en nativo a un Bitmap y se setea en RemoteViews.

**Por qué:** AppWidget limita Views y no admite renderizado directo de widgets Flutter; dibujar en Canvas es eficiente y portable. Además permite controlar anti-alias, textos y tamaños por densidad.

**Consecuencia:** necesita ajustar densidades y escalar correctamente para distintas pantallas/resoluciones.

### AlarmManager exacto + WorkManager fallback

**Qué:** Se usa `setExactAndAllowWhileIdle` para alarmas puntuales y WorkManager como fallback periódico de baja frecuencia.

**Por qué:** Las políticas de Doze y las restricciones de fabricante hacen que las alarmas exactas no sean siempre fiables; WorkManager proporciona una alternativa más garantizada en segundo plano.

**Consecuencia:** complejidad añadida en reprogramación y cuidado sobre el consumo de batería.

### BroadcastReceiver para eventos del sistema

**Qué:** Se escuchan cambios de hora, reinicio, timezone, etc.

**Por qué:** El widget debe reaccionar a estos eventos para mostrarse correcto tras cambios externos.

**Consecuencia:** el receiver debe ser ligero y preferiblemente delegar trabajo a un worker si necesita procesamiento pesado.

### MethodChannel para actualizaciones forzadas

**Qué:** Flutter invoca al nativo para forzar actualización del widget inmediatamente.

**Por qué:** UX: el usuario espera ver el widget reflejando cambios al instante.

**Consecuencia:** se debe validar que la llamada sea idempotente y sin bloqueo.

## Flujo

```
┌─────────────────────────────────────────────────────────────────┐
│                      TRIGGERS DE ACTUALIZACIÓN                  │
└─────────────────────────────────────────────────────────────────┘
          │
          ├─ onUpdate() (AppWidgetProvider)
          ├─ onEnabled() (primer widget añadido)
          ├─ AlarmManager (cada 60s) → TimeChangeSystemReceiver
          ├─ WorkManager (cada 15 min) → WidgetUpdateWorker
          ├─ BroadcastReceiver (eventos sistema):
          │    ├─ TIME_TICK (cada minuto)
          │    ├─ TIME_CHANGED
          │    ├─ DATE_CHANGED
          │    ├─ TIMEZONE_CHANGED
          │    ├─ BOOT_COMPLETED
          │    └─ MY_PACKAGE_REPLACED
          └─ MethodChannel (desde Flutter) → MainActivity.updateAllWidgets()
          │
          ▼
┌─────────────────────────────────────────────────────────────────┐
│  RUTINA: updateWidget()                                         │
└─────────────────────────────────────────────────────────────────┘
          │
          ├─ 1. BirthdayStorage.load() → Calendar(day, month)
          ├─ 2. BirthdayCalculator(day, month).calculate() → progress: Double
          ├─ 3. BirthdayWidgetRender().render(progress) → Bitmap
          ├─ 4. RemoteViews(R.layout.birthday_widget)
          ├─ 5. setTextViewText(R.id.percentage_text, "$percentage")
          ├─ 6. setImageViewBitmap(R.id.progress_ring, progressBitmap)
          ├─ 7. setOnClickPendingIntent(R.id.widget_root, MainActivity)
          └─ 8. appWidgetManager.updateAppWidget(widgetId, views)
```

## Cálculo de progreso

El progreso se calcula de forma idéntica en Dart y Kotlin:

```
progress = (now - lastBirthday) / (nextBirthday - lastBirthday)
```

Donde:
- `lastBirthday`: Último cumpleaños que ya pasó (año actual o anterior)
- `nextBirthday`: Próximo cumpleaños (año actual si no ha pasado, o siguiente)
- `now`: Timestamp actual

El resultado se clampea a [0.0, 1.0] y se multiplica por 100 para obtener el porcentaje.

## Persistencia compartida

El plugin `shared_preferences` de Flutter guarda datos en `SharedPreferences` de Android con el nombre `FlutterSharedPreferences` y prefijo `flutter.` en las keys. El código Kotlin accede directamente a estas SharedPreferences para leer la fecha de cumpleaños sin necesidad de comunicación directa Flutter→Android.

**Keys:**
- `flutter.birthday_day`: Long (1–31)
- `flutter.birthday_month`: Long (1–12)

## Eventos y reprogramación

| Evento | Actualiza widget | Reprograma alarma | Implementado en |
|--------|------------------|-------------------|-----------------|
| `onUpdate()` / `onEnabled()` | ✅ | ✅ | BirthdayWidgetProvider |
| `onDisabled()` | ❌ | ❌ (cancela) | BirthdayWidgetProvider |
| AlarmManager (60s) | ✅ | ✅ | TimeChangeSystemReceiver (ACTION_WIDGET_UPDATE) |
| WorkManager (15 min) | ✅ | ❌ | WidgetUpdateWorker |
| `TIME_TICK` | ✅ | ❌ | TimeChangeSystemReceiver (registro dinámico) |
| `TIME_CHANGED` | ✅ | ❌ | TimeChangeSystemReceiver (manifest) |
| `DATE_CHANGED` | ✅ | ❌ | TimeChangeSystemReceiver (manifest) |
| `TIMEZONE_CHANGED` | ✅ | ❌ | TimeChangeSystemReceiver (manifest) |
| `BOOT_COMPLETED` | ✅ | ✅ | TimeChangeSystemReceiver (manifest) |
| `MY_PACKAGE_REPLACED` | ✅ | ✅ | TimeChangeSystemReceiver (manifest) |
| MethodChannel (Flutter) | ✅ | ❌ | MainActivity |

**Redundancia intencional:** El proyecto usa 3 mecanismos de actualización simultáneos (AlarmManager, WorkManager, BroadcastReceivers) para garantizar que el widget se actualice incluso si uno de los mecanismos falla (por restricciones de batería, Doze mode, etc.).

## Deuda técnica

### No considera meses cortos ni años bisiestos

**Problema:** El picker de fechas permite seleccionar combinaciones inválidas como 31 de febrero, 30 de febrero, o 29 de febrero en años no bisiestos.

**Ubicación:**
- `/lib/widgets/birthday_date_picker.dart`: Genera días del 1 al 31 sin validar el mes seleccionado
- `/lib/logic/birthday_calculator.dart`: Solo valida rango 1–31 y 1–12, no valida fechas inválidas
- `/android/app/src/main/kotlin/com/example/birthday_progress/logic/BirthdayCalculator.kt`: Misma validación débil

**Consecuencias:**
- Si el usuario selecciona "31 de febrero", `DateTime(year, 2, 31)` en Dart ajusta automáticamente a "3 de marzo" (overflow)
- `Calendar` en Kotlin hace lo mismo: la fecha se desborda al siguiente mes
- El usuario cree que configuró "31 de febrero" pero el cálculo usa "3 de marzo"
- El widget muestra progreso incorrecto porque la fecha real no coincide con la intención del usuario


**Solución:** Ajustar el picker dinámicamente para mostrar solo días válidos (28/29 para febrero, 30 para abril/junio/septiembre/noviembre) y validar días permitidos según el mes seleccionado antes de guardar

## Falta de tests

**Problema:** No existen tests unitarios ni de integración en el proyecto, sin tests, es dificil detectar regresiones al modificar el código.

**Solución:**

**Tests unitarios:**
- `BirthdayCalculator.calculate()` (Dart y Kotlin): Casos borde (cumpleaños hoy, ayer, mañana, año bisiesto, cambio de año)
- `BirthdayCalculator.nextBirthday` / `lastBirthday`: Validar cálculo correcto en diferentes épocas del año
- `BirthdayStorage.save()` / `load()`: Validar persistencia y recuperación de fechas
- `BirthdayWidgetRender.render()`: Validar que el bitmap se genera con dimensiones correctas y colores esperados

**Tests de integración:**
- MethodChannel Flutter↔Android: Verificar que `updateWidget()` se invoca correctamente
- Persistencia compartida: Verificar que Dart y Kotlin leen/escriben las mismas SharedPreferences
- Cálculo dual: Verificar que Dart y Kotlin producen el mismo `progress` para la misma fecha

## Excepciones no manejadas

**Problema:** Múltiples bloques `try-catch` capturan excepciones sin notificación.

**Ubicaciones:**
- `/android/app/src/main/kotlin/com/example/birthday_progress/widgets/BirthdayWidgetProvider.kt`
- `/lib/logic/widget_update_service.dart`

**Consecuencias:**
- Si falla el registro del receiver dinámico, el widget no se actualiza con `TIME_TICK` y no hay forma de diagnosticarlo
- Si falla el MethodChannel, la app Flutter no informa al usuario que el widget no se actualizó

**Solución:** Notificar al usuario del error.

## Bitmap de tamaño fijo sin soporte para múltiples densidades

**Problema:** `BirthdayWidgetRender.render()` genera un bitmap de 300x300 px independiente de la densidad de pantalla del dispositivo.

**Ubicación:** `/android/app/src/main/kotlin/com/example/birthday_progress/widgets/BirthdayWidgetRender.kt`

**Consecuencias:**
- En pantallas de alta densidad (xxhdpi, xxxhdpi), el bitmap se ve borroso al escalarse
- En pantallas de baja densidad (mdpi), el bitmap desperdicia memoria

**Solución:** Calcular el tamaño del bitmap según `context.resources.displayMetrics.density` y el tamaño del widget, o generar múltiples bitmaps para diferentes densidades.
