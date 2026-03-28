import 'package:birthday_progress/data/birthday_storage.dart';
import 'package:flutter/services.dart';

class WidgetUpdateService {
  static const _methodChannel =
      MethodChannel('com.example.birthday_progress/widget');

  static Future<void> updateWidget({int? day, int? month}) async {
    try {
      if (day == null || month == null) {
        final date = await BirthdayStorage.load();
        day = date.day;
        month = date.month;
      }
      await _methodChannel.invokeMethod('updateWidget', {
        'day': day,
        'month': month,
      });
    } catch (_) {}
  }
}
