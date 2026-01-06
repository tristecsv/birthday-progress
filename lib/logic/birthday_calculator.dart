class BirthdayCalculator {
  int day;
  int month;

  BirthdayCalculator({
    required this.day,
    required this.month,
  })  : assert(day >= 1 && day <= 31, 'El día debe estar entre 1 y 31'),
        assert(month >= 1 && month <= 12, 'El mes debe estar entre 1 y 12');

  DateTime get nextBirthday {
    final now = DateTime.now();
    DateTime birthdayThisYear = DateTime(now.year, month, day);

    if (birthdayThisYear.isBefore(now)) {
      return DateTime(now.year + 1, month, day);
    }

    return birthdayThisYear;
  }

  DateTime get lastBirthday {
    final next = nextBirthday;
    return DateTime(next.year - 1, month, day);
  }

  double get progress {
    final now = DateTime.now();
    final start = lastBirthday;
    final end = nextBirthday;

    final total = end.difference(start).inMilliseconds;
    final elapsed = now.difference(start).inMilliseconds;

    if (total <= 0) return 0.0;

    return (elapsed / total).clamp(0.0, 1.0);
  }
}
