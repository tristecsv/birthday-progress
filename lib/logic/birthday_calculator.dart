class BirthdayCalculator {
  final int day;
  final int month;

  BirthdayCalculator({
    required this.day,
    required this.month,
  }) {
    _validateInputs();
  }

  BirthdaySnapshot snapshotAt(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);

    final birthdayThisYear = _birthdayInYear(today.year);
    final nextBirthday = birthdayThisYear.isAfter(today)
        ? birthdayThisYear
        : _birthdayInYear(today.year + 1);
    final previousBirthday = _birthdayInYear(nextBirthday.year - 1);

    final daysUntilNextBirthday = nextBirthday.difference(today).inDays;

    final cycleDays = nextBirthday.difference(previousBirthday).inDays;
    final progress = cycleDays <= 0
        ? 0.0
        : (1 - daysUntilNextBirthday / cycleDays).clamp(0.0, 1.0);

    return BirthdaySnapshot(
      nextBirthday: nextBirthday,
      daysUntilNextBirthday: daysUntilNextBirthday,
      progress: progress,
    );
  }

  DateTime _birthdayInYear(int year) {
    if (month == 2 && day == 29 && !_isLeapYear(year)) {
      return DateTime(year, 2, 28);
    }

    return DateTime(year, month, day);
  }

  static bool _isLeapYear(int year) =>
      (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

  void _validateInputs() {
    if (month < 1 || month > 12) {
      throw ArgumentError('Mes inválido: $month');
    }

    const maxDays = [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (day < 1 || day > maxDays[month]) {
      throw ArgumentError('Día inválido: $day/$month');
    }
  }
}

class BirthdaySnapshot {
  final DateTime nextBirthday;
  final int daysUntilNextBirthday;
  final double progress;

  const BirthdaySnapshot({
    required this.nextBirthday,
    required this.daysUntilNextBirthday,
    required this.progress,
  });

  @override
  bool operator ==(Object other) =>
      other is BirthdaySnapshot &&
      nextBirthday == other.nextBirthday &&
      daysUntilNextBirthday == other.daysUntilNextBirthday &&
      progress == other.progress;

  @override
  int get hashCode =>
      Object.hash(nextBirthday, daysUntilNextBirthday, progress);
}
