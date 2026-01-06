import 'package:birthday_progress/logic/widget_update_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:birthday_progress/widgets/birthday_display_text.dart';
import 'package:birthday_progress/data/birthday_storage.dart';
import 'package:birthday_progress/logic/birthday_calculator.dart';
import 'package:birthday_progress/widgets/birthday_date_picker.dart';
import 'package:birthday_progress/widgets/circular_progress.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late BirthdayCalculator _calculator;
  Timer? _updateTimer;
  double _targetProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _calculator = BirthdayCalculator(day: 1, month: 1);
    _loadSavedBirthDay();
  }

  void _loadSavedBirthDay() async {
    final savedDate = await BirthdayStorage.load();
    if (savedDate != null) {
      _calculator = BirthdayCalculator(
        day: savedDate.day,
        month: savedDate.month,
      );
    }

    if (mounted) {
      setState(() => _targetProgress = _calculator.progress);
    }
  }

  void _onDateChanged({int? day, int? month}) async {
    setState(() {
      _calculator = BirthdayCalculator(
        day: day ?? _calculator.day,
        month: month ?? _calculator.month,
      );
    });

    final date = DateTime(2000, _calculator.month, _calculator.day);
    await BirthdayStorage.save(date);
    await WidgetUpdateService.updateWidget();

    if (mounted) {
      setState(() => _targetProgress = _calculator.progress);
      _startUpdateTimer();
    }
  }

  void _startUpdateTimer() {
    _updateTimer?.cancel();

    _updateTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) async {
        if (mounted) _onDateChanged();
      },
    );
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BirthdayDisplayText(date: _calculator.nextBirthday),
            const SizedBox(height: 30),
            CircularProgress(progress: _targetProgress),
            const SizedBox(height: 70),
            BirthdayDatePicker(
              selectedDay: _calculator.day,
              selectedMonth: _calculator.month,
              onDayChanged: (day) => _onDateChanged(day: day),
              onMonthChanged: (month) => _onDateChanged(month: month),
            ),
          ],
        ),
      ),
    );
  }
}
