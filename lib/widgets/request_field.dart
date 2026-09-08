import 'package:flutter/material.dart';

class RequestField extends StatelessWidget {
  const RequestField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: TextFormField(
      controller: controller,
      minLines: 1,
      maxLines: 4,
      maxLength: 4000,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
      ),
      validator: validator,
    ),
  );
}
