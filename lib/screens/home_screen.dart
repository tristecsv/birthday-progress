import 'dart:async';

import 'package:birthday_progress/data/birthday_storage.dart';
import 'package:birthday_progress/logic/birthday_calculator.dart';
import 'package:birthday_progress/logic/widget_update_service.dart';
import 'package:birthday_progress/state/settings_notifier.dart';
import 'package:birthday_progress/widgets/birthday_date_picker.dart';
import 'package:birthday_progress/widgets/birthday_display_text.dart';
import 'package:birthday_progress/widgets/circular_progress.dart';
import 'package:birthday_progress/widgets/home_appbar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BirthdayCalculator _core = BirthdayCalculator(day: 1, month: 1);
  BirthdaySnapshot? _snapshot;
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    _loadSavedBirthday();
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSavedBirthday() async {
    final savedDate = await BirthdayStorage.load();
    _core = BirthdayCalculator(
      day: savedDate.day,
      month: savedDate.month,
    );
    await WidgetUpdateService.updateWidget(
      day: savedDate.day,
      month: savedDate.month,
    );
    _refreshSnapshot();
    _scheduleMidnightRefresh();
  }

  void _refreshSnapshot() {
    final snapshot = _core.snapshotAt(DateTime.now());
    if (mounted) setState(() => _snapshot = snapshot);
  }

  Future<void> _onDateChanged({int? day, int? month}) async {
    final newDay = day ?? _core.day;
    final newMonth = month ?? _core.month;

    _core = BirthdayCalculator(day: newDay, month: newMonth);

    await BirthdayStorage.save(DateTime(2000, newMonth, newDay));
    await WidgetUpdateService.updateWidget(day: newDay, month: newMonth);

    _refreshSnapshot();
    _scheduleMidnightRefresh();
  }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final untilMidnight = tomorrow.difference(now);

    _midnightTimer = Timer(untilMidnight, () {
      _refreshSnapshot();
      _scheduleMidnightRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context).settings;
    final snapshot = _snapshot;

    return SafeArea(
      child: Scaffold(
        appBar: const HomeAppBar(),
        body: snapshot == null
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BirthdayDisplayText(date: snapshot.nextBirthday),
                    const SizedBox(height: 30),
                    CircularProgress(
                      progress: snapshot.progress,
                      days: snapshot.daysUntilNextBirthday,
                      showPercent: settings.showPercent,
                      showDays: settings.showDays,
                    ),
                    const SizedBox(height: 70),
                    BirthdayDatePicker(
                      selectedDay: _core.day,
                      selectedMonth: _core.month,
                      onDayChanged: (day) => _onDateChanged(day: day),
                      onMonthChanged: (month) => _onDateChanged(month: month),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
