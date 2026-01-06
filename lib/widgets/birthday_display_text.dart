import 'package:flutter/material.dart';
import 'package:birthday_progress/utils/constants.dart';

class BirthdayDisplayText extends StatelessWidget {
  final DateTime date;

  const BirthdayDisplayText({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDateInSpanish(date);

    return Column(
      children: [
        Text(
          'Próximo cumpleaños',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppConstants.secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          formattedDate,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppConstants.primaryTextColor,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
        ),
      ],
    );
  }

  String _formatDateInSpanish(DateTime date) {
    final day = date.day;
    final monthName = AppConstants.monthNamesSpanish[date.month - 1];
    final year = date.year;

    return '$day de $monthName $year';
  }
}
