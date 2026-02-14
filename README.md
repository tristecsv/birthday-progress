> ⚠️ This text may contain translation errors. You can read the Spanish version here: [docs/README-es.md](docs/README-es.md)

# Birthday Progress 🎂

Android application developed in **Flutter + Kotlin** that shows the progress from your last birthday to your next birthday through an **AppWidget** which renders a circular progress chart.

---

## 🚀 Overview 

Birthday Progress implements a **native Android AppWidget** reliably updated in the background, synchronized with Flutter through MethodChannel and shared storage.

Includes:

- Native widget with custom rendering using **Canvas**
- Flutter ↔ Kotlin communication
- Shared persistence between layers
- Resilient updates after reboots and system changes
- Handling of modern Android power restrictions

---

## 🎥 Demo

| App UI | Place Widget |
|--------|--------------|
| ![App usage](docs/demo/app_update.gif) | ![Select widget](docs/demo/select_widget.gif) |

| App → Widget Sync | Background Update |
|-------------------|------------------|
| ![App forces widget update](docs/demo/app_update_widget.gif) | ![Background service update](docs/demo/service_update_widget.gif) |

---

## ✨ Visible features

- Birthday day and month selection from Flutter UI
- Automatic progress calculation between previous and next birthday
- Home screen widget with circular progress indicator
- Automatic synchronization between app and widget
- Automatic updates even after device reboot

---

## 🧠 Technical highlights

- **AppWidget**
  - Progress rendering using **bitmap and canvas**
  - No external UI libraries

- **Flutter + Android integration**
  - MethodChannel for direct Flutter → Kotlin communication
  - Forced widget update from the app

- **Robust background updating**
  - `AlarmManager` with `setExactAndAllowWhileIdle` every 60s
  - Periodic `WorkManager` every 15 min as fallback
  - System event reception:
    - TIME_TICK
    - TIME_CHANGED
    - DATE_CHANGED
    - TIMEZONE_CHANGED
    - BOOT_COMPLETED
    - MY_PACKAGE_REPLACED

- **Shared persistence**
  - SharedPreferences accessible from Flutter and Kotlin
  - Compatible keys (`flutter.*`)

- **Dual architecture**
  - Calculation logic implemented in:
    - Dart (Flutter UI)
    - Kotlin (Native widget)

---

## 🎯 What this project demonstrates

This project demonstrates transferable skills for professional mobile development:

- Flutter integration with native Android components
- Hybrid multiplatform feature design
- Background execution handling and battery restrictions
- Implementation of resilient Android widgets
- Optimized native graphic rendering
- State synchronization between different runtimes

---

## 🏗 Architecture

The project separates responsibilities between Flutter (UI + user logic) and native Android (AppWidget + background update).

➡️ See full architecture documentation:  
[docs/technical.md](docs/technical.md)

---

## ⚙️ Quick installation

### Requirements

- Flutter SDK
- Android SDK
- Android device or emulator

### Clone and run

```bash
git clone <URL_DEL_REPO>
cd birthday_progress

flutter pub get
flutter run
```