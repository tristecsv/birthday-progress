> ⚠️ This text may contain translation errors. You can read the Spanish version here: [docs/technical-es.md](technical-es.md)

# Technical - Birthday Progress

## Structure

```
lib/
├── main.dart                         # Flutter entry point
├── screens/home_screen.dart          # Main UI with DatePicker and CircularProgress
├── logic/
│   ├── birthday_calculator.dart      # Progress calculation (Dart)
│   └── widget_update_service.dart    # MethodChannel for updateWidget
├── data/birthday_storage.dart        # SharedPreferences wrapper
└── widgets/                          # Reusable Flutter widgets

android/app/src/main/kotlin/com/example/birthday_progress/
├── MainActivity.kt                   # FlutterActivity + MethodChannel handler
├── widgets/
│   ├── BirthdayWidgetProvider.kt     # AppWidgetProvider, scheduleAlarm, registrations
│   └── BirthdayWidgetRender.kt       # Renders bitmap with Canvas (circular ring)
├── logic/
│   ├── BirthdayCalculator.kt         # Progress calculation (Kotlin)
│   └── TimeChangeSystemReceiver.kt   # BroadcastReceiver for system events
├── worker/WidgetUpdateWorker.kt      # Periodic WorkManager worker
└── data/BirthdayStorage.kt           # Reads shared SharedPreferences
```

## Design Considerations

Here we list the important technical decisions and the reasoning behind each one.

### Duplicate calculation in Dart and Kotlin

**What:** The calculation logic (elapsed / total) exists in both layers.

**Why:** The native widget must calculate progress without depending on the running app. Maintaining the same logic in both runtimes guarantees visual consistency and avoids cross-runtime dependencies.

**Consequence:** Forces maintaining tests or a clear specification of the formula to avoid divergences.

### Shared SharedPreferences

**What:** A simple storage accessible from both Flutter and Kotlin.

**Why:** Simple native compatibility, instant persistence, and no need for complex IPC.

**Consequence:** Use a stable format and keys (prefix `flutter.*`) and document the structure (see Shared Persistence section).

### Bitmap rendering with Canvas

**What:** The ring is drawn natively to a Bitmap and set in RemoteViews.

**Why:** AppWidget limits Views and doesn't support direct rendering of Flutter widgets; drawing on Canvas is efficient and portable. It also allows controlling anti-aliasing, text, and sizes by density.

**Consequence:** Needs to adjust densities and scale correctly for different screens/resolutions.

### Exact AlarmManager + WorkManager fallback

**What:** `setExactAndAllowWhileIdle` is used for precise alarms and WorkManager as a low-frequency periodic fallback.

**Why:** Doze policies and manufacturer restrictions make exact alarms not always reliable; WorkManager provides a more guaranteed background alternative.

**Consequence:** Added complexity in rescheduling and care about battery consumption.

### BroadcastReceiver for system events

**What:** Listens to time changes, reboot, timezone, etc.

**Why:** The widget must react to these events to display correctly after external changes.

**Consequence:** The receiver should be lightweight and preferably delegate work to a worker if heavy processing is needed.

### MethodChannel for forced updates

**What:** Flutter invokes native to force widget update immediately.

**Why:** UX: the user expects to see the widget reflecting changes instantly.

**Consequence:** Must validate that the call is idempotent and non-blocking.

## Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      UPDATE TRIGGERS                            │
└─────────────────────────────────────────────────────────────────┘
          │
          ├─ onUpdate() (AppWidgetProvider)
          ├─ onEnabled() (first widget added)
          ├─ AlarmManager (every 60s) → TimeChangeSystemReceiver
          ├─ WorkManager (every 15 min) → WidgetUpdateWorker
          ├─ BroadcastReceiver (system events):
          │    ├─ TIME_TICK (every minute)
          │    ├─ TIME_CHANGED
          │    ├─ DATE_CHANGED
          │    ├─ TIMEZONE_CHANGED
          │    ├─ BOOT_COMPLETED
          │    └─ MY_PACKAGE_REPLACED
          └─ MethodChannel (from Flutter) → MainActivity.updateAllWidgets()
          │
          ▼
┌─────────────────────────────────────────────────────────────────┐
│  ROUTINE: updateWidget()                                        │
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

## Progress Calculation

Progress is calculated identically in Dart and Kotlin:

```
progress = (now - lastBirthday) / (nextBirthday - lastBirthday)
```

Where:
- `lastBirthday`: Last birthday that already passed (current year or previous)
- `nextBirthday`: Next birthday (current year if it hasn't passed, or next year)
- `now`: Current timestamp

The result is clamped to [0.0, 1.0] and multiplied by 100 to obtain the percentage.

## Shared Persistence

The Flutter `shared_preferences` plugin saves data in Android's `SharedPreferences` with the name `FlutterSharedPreferences` and prefix `flutter.` in the keys. The Kotlin code accesses these SharedPreferences directly to read the birthday date without needing direct Flutter→Android communication.

**Keys:**
- `flutter.birthday_day`: Long (1–31)
- `flutter.birthday_month`: Long (1–12)

## Events and Rescheduling

| Event | Updates widget | Reschedules alarm | Implemented in |
|-------|----------------|-------------------|----------------|
| `onUpdate()` / `onEnabled()` | ✅ | ✅ | BirthdayWidgetProvider |
| `onDisabled()` | ❌ | ❌ (cancels) | BirthdayWidgetProvider |
| AlarmManager (60s) | ✅ | ✅ | TimeChangeSystemReceiver (ACTION_WIDGET_UPDATE) |
| WorkManager (15 min) | ✅ | ❌ | WidgetUpdateWorker |
| `TIME_TICK` | ✅ | ❌ | TimeChangeSystemReceiver (dynamic registration) |
| `TIME_CHANGED` | ✅ | ❌ | TimeChangeSystemReceiver (manifest) |
| `DATE_CHANGED` | ✅ | ❌ | TimeChangeSystemReceiver (manifest) |
| `TIMEZONE_CHANGED` | ✅ | ❌ | TimeChangeSystemReceiver (manifest) |
| `BOOT_COMPLETED` | ✅ | ✅ | TimeChangeSystemReceiver (manifest) |
| `MY_PACKAGE_REPLACED` | ✅ | ✅ | TimeChangeSystemReceiver (manifest) |
| MethodChannel (Flutter) | ✅ | ❌ | MainActivity |

**Intentional redundancy:** The project uses 3 simultaneous update mechanisms (AlarmManager, WorkManager, BroadcastReceivers) to ensure the widget updates even if one mechanism fails (due to battery restrictions, Doze mode, etc.).

## Technical Debt

### Does not consider short months or leap years

**Problem:** The date picker allows selecting invalid combinations like February 31st, February 30th, or February 29th in non-leap years.

**Location:**
- `/lib/widgets/birthday_date_picker.dart`: Generates days from 1 to 31 without validating the selected month
- `/lib/logic/birthday_calculator.dart`: Only validates range 1–31 and 1–12, doesn't validate invalid dates
- `/android/app/src/main/kotlin/com/example/birthday_progress/logic/BirthdayCalculator.kt`: Same weak validation

**Consequences:**
- If the user selects "February 31st", `DateTime(year, 2, 31)` in Dart automatically adjusts to "March 3rd" (overflow)
- `Calendar` in Kotlin does the same: the date overflows to the next month
- The user believes they configured "February 31st" but the calculation uses "March 3rd"
- The widget shows incorrect progress because the actual date doesn't match the user's intention

**Solution:** Dynamically adjust the picker to show only valid days (28/29 for February, 30 for April/June/September/November) and validate allowed days according to the selected month before saving

## Lack of tests

**Problem:** There are no unit or integration tests in the project; without tests, it's difficult to detect regressions when modifying code.

**Solution:**

**Unit tests:**
- `BirthdayCalculator.calculate()` (Dart and Kotlin): Edge cases (birthday today, yesterday, tomorrow, leap year, year change)
- `BirthdayCalculator.nextBirthday` / `lastBirthday`: Validate correct calculation at different times of the year
- `BirthdayStorage.save()` / `load()`: Validate persistence and recovery of dates
- `BirthdayWidgetRender.render()`: Validate that the bitmap is generated with correct dimensions and expected colors

**Integration tests:**
- MethodChannel Flutter↔Android: Verify that `updateWidget()` is invoked correctly
- Shared persistence: Verify that Dart and Kotlin read/write the same SharedPreferences
- Dual calculation: Verify that Dart and Kotlin produce the same `progress` for the same date

## Unhandled exceptions

**Problem:** Multiple `try-catch` blocks capture exceptions without notification.

**Locations:**
- `/android/app/src/main/kotlin/com/example/birthday_progress/widgets/BirthdayWidgetProvider.kt`
- `/lib/logic/widget_update_service.dart`

**Consequences:**
- If dynamic receiver registration fails, the widget doesn't update with `TIME_TICK` and there's no way to diagnose it
- If MethodChannel fails, the Flutter app doesn't inform the user that the widget wasn't updated

**Solution:** Notify the user of the error.

## Fixed-size bitmap without multi-density support

**Problem:** `BirthdayWidgetRender.render()` generates a 300x300 px bitmap independent of the device's screen density.

**Location:** `/android/app/src/main/kotlin/com/example/birthday_progress/widgets/BirthdayWidgetRender.kt`

**Consequences:**
- On high-density screens (xxhdpi, xxxhdpi), the bitmap looks blurry when scaled
- On low-density screens (mdpi), the bitmap wastes memory

**Solution:** Calculate bitmap size according to `context.resources.displayMetrics.density` and widget size, or generate multiple bitmaps for different densities.