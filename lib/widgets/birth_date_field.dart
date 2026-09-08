import 'package:flutter/material.dart';
import '../domain/birth_date.dart';
import '../core/localization.dart';

class BirthDateField extends StatelessWidget {
  const BirthDateField({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final BirthDate? value;
  final ValueChanged<BirthDate?> onChanged;
  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    final date = value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InputDecorator(
        decoration: InputDecoration(labelText: text.birthDate),
        child: Row(
          children: [
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(
                  date == null
                      ? text.selectBirthDate
                      : MaterialLocalizations.of(context).formatMediumDate(
                          DateTime(date.year, date.month, date.day),
                        ),
                ),
                onPressed: () async {
                  final now = DateTime.now().toUtc();
                  final today = DateTime(now.year, now.month, now.day);
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: date != null && date.validAt(now)
                        ? DateTime(date.year, date.month, date.day)
                        : today,
                    firstDate: DateTime(1900),
                    lastDate: today,
                    initialDatePickerMode: DatePickerMode.year,
                  );
                  if (selected != null && context.mounted) {
                    onChanged(
                      BirthDate(selected.year, selected.month, selected.day),
                    );
                  }
                },
              ),
            ),
            if (date != null)
              IconButton(
                tooltip: text.clearBirthDate,
                onPressed: () => onChanged(null),
                icon: const Icon(Icons.close),
              ),
          ],
        ),
      ),
    );
  }
}
