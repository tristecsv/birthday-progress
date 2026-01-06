import 'package:flutter/services.dart';

class WidgetUpdateService {
  static const _methodChannel =
      MethodChannel('com.example.birthday_progress/widget');

  static Future<void> updateWidget() async {
    try {
      await _methodChannel.invokeMethod('updateWidget');
    } catch (_) {}
  }
}
