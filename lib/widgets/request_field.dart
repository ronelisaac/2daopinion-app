import 'package:flutter/material.dart';
import '../domain/form_limits.dart';
import 'text_limit_formatter.dart';

class RequestField extends StatelessWidget {
  const RequestField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.onChanged,
    this.minLines = 1,
    this.maxLines = 4,
    this.helperText,
    this.errorText,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final int minLines;
  final int maxLines;
  final String? helperText;
  final String? errorText;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: TextFormField(
      controller: controller,
      onChanged: onChanged,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: TextInputType.multiline,
      maxLength: FormLimits.text,
      buildCounter:
          (context, {required currentLength, required isFocused, maxLength}) =>
              Text('${controller.text.length}/${FormLimits.text}'),
      inputFormatters: [const TextLimitFormatter(FormLimits.text)],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        errorText: errorText,
        helperMaxLines: 3,
        errorMaxLines: 3,
      ),
      validator: validator,
    ),
  );
}
