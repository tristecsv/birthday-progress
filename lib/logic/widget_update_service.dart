import 'package:flutter/services.dart';

class WidgetUpdateService {
  static const _methodChannel =
      MethodChannel('com.example.birthday_progress/widget');

  static Future<void> updateWidget(int day, int month) async {
    try {
      await _methodChannel.invokeMethod('updateWidget', {
        'day': day,
        'month': month,
      });
    } catch (_) {}
  }
}
