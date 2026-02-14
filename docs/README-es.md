# Birthday Progress 🎂

Aplicación Android desarrollada en **Flutter + Kotlin** que muestra el progreso desde tu último cumpleaños hasta el siguiente cumpleaños mediante un **AppWidget** el cual renderiza una gráfica de progreso circular.

---

## 🚀 Overview 

Birthday Progress implementa un **AppWidget nativo Android** actualizado de forma confiable en segundo plano, sincronizado con Flutter mediante MethodChannel y almacenamiento compartido.

Incluye:

- Widget nativo con renderizado custom usando **Canvas**
- Comunicación Flutter ↔ Kotlin
- Persistencia compartida entre capas
- Actualización resiliente ante reinicios y cambios de sistema
- Manejo de restricciones modernas de energía en Android

---

## 🎥 Demo

| App UI | Colocar Widget |
|--------|----------------|
| ![App usage](demo/app_update.gif) | ![Select widget](demo/select_widget.gif) |

| App → Widget Sync | Background Update |
|-------------------|------------------|
| ![App forces widget update](demo/app_update_widget.gif) | ![Background service update](demo/service_update_widget.gif) |

---

## ✨ Funcionalidades visibles

- Selección de día y mes de cumpleaños desde UI Flutter
- Cálculo automático del progreso entre cumpleaños anterior y próximo
- Widget en pantalla de inicio con indicador circular de progreso
- Sincronización automática entre app y widget
- Actualización automática incluso tras reinicio del dispositivo

---

## 🧠 Highlights técnicos

- **AppWidget**
  - Renderizado de progreso con **bitmap y canvas**
  - Sin librerías externas de UI

- **Integración Flutter + Android**
  - MethodChannel para comunicación directa Flutter → Kotlin
  - Actualización forzada del widget desde la app

- **Actualización robusta en background**
  - `AlarmManager` con `setExactAndAllowWhileIdle` cada 60s
  - `WorkManager` periódico cada 15 min como fallback
  - Recepción de eventos del sistema:
    - TIME_TICK
    - TIME_CHANGED
    - DATE_CHANGED
    - TIMEZONE_CHANGED
    - BOOT_COMPLETED
    - MY_PACKAGE_REPLACED

- **Persistencia compartida**
  - SharedPreferences accesible desde Flutter y Kotlin
  - Claves compatibles (`flutter.*`)

- **Arquitectura dual**
  - Lógica de cálculo implementada en:
    - Dart (Flutter UI)
    - Kotlin (Widget nativo)

---

## 🎯 Qué demuestra este proyecto

Este proyecto evidencia competencias transferibles a desarrollo mobile profesional:

- Integración Flutter con componentes nativos Android
- Diseño de features híbridas multiplataforma
- Manejo de background execution y restricciones de batería
- Implementación de widgets Android resilientes
- Renderizado gráfico nativo optimizado
- Sincronización de estado entre runtimes distintos

---

## 🏗 Arquitectura

El proyecto separa responsabilidades entre Flutter (UI + lógica de usuario) y Android nativo (AppWidget + background update).

➡️ Ver documentación completa de arquitectura:  
[docs/technical.md](docs/technical.md)

---

## ⚙️ Instalación rápida

### Requisitos

- Flutter SDK
- Android SDK
- Dispositivo o emulador Android

### Clonar y ejecutar

```bash
git clone <URL_DEL_REPO>
cd birthday_progress

flutter pub get
flutter run
```