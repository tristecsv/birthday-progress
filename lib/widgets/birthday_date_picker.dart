import 'package:flutter/material.dart';
import 'package:birthday_progress/utils/constants.dart';

class BirthdayDatePicker extends StatelessWidget {
  final int selectedDay;
  final int selectedMonth;
  final ValueChanged<int> onDayChanged;
  final ValueChanged<int> onMonthChanged;

  const BirthdayDatePicker({
    super.key,
    required this.selectedDay,
    required this.selectedMonth,
    required this.onDayChanged,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _DateDropdown(
          label: 'Día',
          value: selectedDay,
          items: List.generate(31, (i) => i + 1),
          onChanged: onDayChanged,
        ),
        const SizedBox(width: 16),
        _DateDropdown(
          label: 'Mes',
          value: selectedMonth,
          items: List.generate(12, (i) => i + 1),
          itemLabel: (m) => AppConstants.monthNamesSpanishCapitalized[m - 1],
          onChanged: onMonthChanged,
        ),
      ],
    );
  }
}

class _DateDropdown extends StatelessWidget {
  final String label;
  final int value;
  final List<int> items;
  final ValueChanged<int> onChanged;
  final String Function(int)? itemLabel;

  const _DateDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppConstants.secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppConstants.dropdownBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppConstants.dropdownBorderColor),
          ),
          child: DropdownButton<int>(
            value: value,
            underline: const SizedBox.shrink(),
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            elevation: 2,
            dropdownColor: AppConstants.dropdownBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            items: items
                .map((i) => DropdownMenuItem(
                      value: i,
                      child: Text(itemLabel?.call(i) ?? i.toString()),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}
