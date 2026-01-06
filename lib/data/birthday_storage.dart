import 'package:shared_preferences/shared_preferences.dart';

class BirthdayStorage {
  static const _keyDay = 'birthday_day';
  static const _keyMonth = 'birthday_month';

  static Future<void> save(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDay, date.day);
    await prefs.setInt(_keyMonth, date.month);
  }

  static Future<DateTime?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final month = prefs.getInt(_keyMonth) ?? 1;
    final day = prefs.getInt(_keyDay) ?? 1;
    return DateTime(2000, month, day);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDay);
    await prefs.remove(_keyMonth);
  }
}
