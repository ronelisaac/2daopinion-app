enum InputIssue { required, invalidEmail, shortPassword, passwordMismatch }

abstract final class InputValidation {
  static InputIssue? required(String? value) =>
      value == null || value.trim().isEmpty ? InputIssue.required : null;

  static InputIssue? email(String? value) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value?.trim() ?? '')
      ? null
      : InputIssue.invalidEmail;

  static InputIssue? password(String? value, {required bool registering}) {
    if (value == null || value.isEmpty) return InputIssue.required;
    if (registering && value.length < 8) return InputIssue.shortPassword;
    return null;
  }

  static InputIssue? confirmation(String? value, String password) =>
      value == password ? null : InputIssue.passwordMismatch;
}
