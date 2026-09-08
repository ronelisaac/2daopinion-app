import 'package:flutter/services.dart';

class TextLimitFormatter extends TextInputFormatter {
  const TextLimitFormatter(this.limit);
  final int limit;
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.text.length <= limit ? newValue : oldValue;
}
