import 'package:flutter_test/flutter_test.dart';
import 'package:birthday_progress/logic/birthday_calculator.dart';

void main() {
  BirthdayCalculator calc(int day, int month) =>
      BirthdayCalculator(day: day, month: month);

  double progressOn(BirthdayCalculator c, DateTime date) =>
      c.snapshotAt(date).progress;

  group('validateInputs', () {
    test('acepta fechas válidas', () {
      expect(() => calc(1, 1), returnsNormally);
      expect(() => calc(31, 1), returnsNormally);
      expect(() => calc(28, 2), returnsNormally);
      expect(() => calc(29, 2), returnsNormally);
      expect(() => calc(30, 4), returnsNormally);
      expect(() => calc(31, 12), returnsNormally);
    });

    test('lanza ArgumentError con mes inválido', () {
      expect(() => calc(1, 0), throwsArgumentError);
      expect(() => calc(1, 13), throwsArgumentError);
    });

    test('lanza ArgumentError con día inválido para el mes', () {
      expect(() => calc(0, 1), throwsArgumentError);
      expect(() => calc(32, 1), throwsArgumentError);
      expect(() => calc(30, 2), throwsArgumentError);
      expect(() => calc(31, 4), throwsArgumentError);
    });
  });

  group('nextBirthday', () {
    test('retorna cumpleaños de este año si aún no pasó', () {
      final c = calc(15, 6);
      final snap = c.snapshotAt(DateTime(2024, 6, 14));
      expect(snap.nextBirthday, DateTime(2024, 6, 15));
    });

    test('retorna cumpleaños del próximo año si hoy es su cumpleaños', () {
      final c = calc(15, 6);
      final snap = c.snapshotAt(DateTime(2024, 6, 15));
      expect(snap.nextBirthday, DateTime(2025, 6, 15));
    });

    test('retorna cumpleaños del próximo año si ya pasó', () {
      final c = calc(15, 6);
      final snap = c.snapshotAt(DateTime(2024, 6, 16));
      expect(snap.nextBirthday, DateTime(2025, 6, 15));
    });
  });

  group('daysUntilNextBirthday', () {
    test('1 día antes → 1', () {
      final snap = calc(15, 6).snapshotAt(DateTime(2024, 6, 14));
      expect(snap.daysUntilNextBirthday, 1);
    });

    test('día del cumpleaños → 365 días en ciclo normal', () {
      final snap = calc(15, 6).snapshotAt(DateTime(2024, 6, 15));
      expect(snap.daysUntilNextBirthday, 365);
    });

    test('día del cumpleaños → 366 días con año bisiesto en el ciclo', () {
      final snap = calc(15, 6).snapshotAt(DateTime(2023, 6, 15));
      expect(snap.daysUntilNextBirthday, 366);
    });

    test('daysUntilNextBirthday es consistente con nextBirthday', () {
      final c = calc(15, 6);

      for (int i = 0; i < 365; i++) {
        final date = DateTime(2024, 1, 1).add(Duration(days: i));
        final snap = c.snapshotAt(date);

        final expected = snap.nextBirthday
            .difference(DateTime(date.year, date.month, date.day))
            .inDays;

        expect(snap.daysUntilNextBirthday, expected, reason: 'falló en $date');
      }
    });
  });

  group('progress', () {
    test('1 día antes → ~0.99 (≥ 0.99)', () {
      final p = progressOn(calc(15, 6), DateTime(2024, 6, 14));
      expect(p, greaterThanOrEqualTo(0.99));
      expect(p, lessThan(1.0));
    });

    test('día del cumpleaños → 0.0', () {
      final p = progressOn(calc(15, 6), DateTime(2024, 6, 15));
      expect(p, 0.0);
    });

    test('progreso está entre 0.0 y 1.0 en cualquier punto del ciclo', () {
      final c = calc(15, 6);
      for (int offset = 0; offset < 365; offset++) {
        final date = DateTime(2024, 1, 1).add(Duration(days: offset));
        final p = progressOn(c, date);
        expect(
          p,
          inInclusiveRange(0.0, 1.0),
          reason: 'falló en $date (offset $offset)',
        );
      }
    });

    test('progreso es monotónicamente creciente entre cumpleaños', () {
      final c = calc(15, 6);
      final start = DateTime(2024, 6, 14);

      for (int i = 0; i < 364; i++) {
        final today = start.add(Duration(days: i));
        final tomorrow = start.add(Duration(days: i + 1));
        final todaySnap = c.snapshotAt(today);
        final tomorrowSnap = c.snapshotAt(tomorrow);

        final crossedCycle =
            tomorrowSnap.nextBirthday != todaySnap.nextBirthday;

        if (crossedCycle) {
          expect(
            tomorrowSnap.progress,
            0.0,
            reason: 'al cruzar ciclo el progreso debe reiniciarse en $tomorrow',
          );
        } else {
          expect(
            tomorrowSnap.progress,
            greaterThanOrEqualTo(todaySnap.progress),
            reason: 'progreso retrocedió entre $today y $tomorrow',
          );
        }
      }
    });
  });

  group('leap year - Feb 29 birthday', () {
    final leapCalc = calc(29, 2);

    test('en año bisiesto → nextBirthday es 29 feb', () {
      final snap = leapCalc.snapshotAt(DateTime(2024, 2, 28));
      expect(snap.nextBirthday, DateTime(2024, 2, 29));
    });

    test('en año no bisiesto → nextBirthday cae en 28 feb', () {
      final snap = leapCalc.snapshotAt(DateTime(2025, 2, 27));
      expect(snap.nextBirthday, DateTime(2025, 2, 28));
    });

    test('día del cumpleaños en año bisiesto → progress 0.0', () {
      final p = progressOn(leapCalc, DateTime(2024, 2, 29));
      expect(p, 0.0);
    });

    test('día del cumpleaños en año no bisiesto (28 feb) → progress 0.0', () {
      final p = progressOn(leapCalc, DateTime(2025, 2, 28));
      expect(p, 0.0);
    });

    test('progreso sigue siendo válido en ciclo con año no bisiesto', () {
      for (int offset = 0; offset < 365; offset++) {
        final date = DateTime(2025, 1, 1).add(Duration(days: offset));
        final p = progressOn(leapCalc, date);
        expect(p, inInclusiveRange(0.0, 1.0), reason: 'falló en $date');
      }
    });
  });

  group('birthday en límites de año', () {
    test('1 ene: 1 día antes (31 dic) → 1 día', () {
      final snap = calc(1, 1).snapshotAt(DateTime(2024, 12, 31));
      expect(snap.daysUntilNextBirthday, 1);
      expect(snap.nextBirthday, DateTime(2025, 1, 1));
    });

    test('1 ene: día del cumpleaños → next es año siguiente', () {
      final snap = calc(1, 1).snapshotAt(DateTime(2025, 1, 1));
      expect(snap.nextBirthday, DateTime(2026, 1, 1));
    });
  });

  group('BirthdaySnapshot ==', () {
    test('dos snapshots con los mismos valores son iguales', () {
      final a = calc(15, 6).snapshotAt(DateTime(2024, 6, 14));
      final b = calc(15, 6).snapshotAt(DateTime(2024, 6, 14));
      expect(a, equals(b));
    });

    test('snapshots distintos no son iguales', () {
      final a = calc(15, 6).snapshotAt(DateTime(2024, 6, 14));
      final b = calc(15, 6).snapshotAt(DateTime(2024, 6, 13));
      expect(a, isNot(equals(b)));
    });

    test('hashCode es consistente con ==', () {
      final a = calc(15, 6).snapshotAt(DateTime(2024, 6, 14));
      final b = calc(15, 6).snapshotAt(DateTime(2024, 6, 14));
      expect(a.hashCode, b.hashCode);
    });
  });
}
