import 'input_validation.dart';

class AccountDraft {
  const AccountDraft({
    required this.email,
    required this.password,
    this.firstName = '',
    this.lastName = '',
    this.passwordConfirmation = '',
    this.acceptedPolicyVersion,
  });

  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String passwordConfirmation;
  final String? acceptedPolicyVersion;

  bool isValid({required bool registering}) =>
      InputValidation.email(email) == null &&
      InputValidation.password(password, registering: registering) == null &&
      (!registering ||
          (InputValidation.required(firstName) == null &&
              InputValidation.required(lastName) == null &&
              InputValidation.confirmation(passwordConfirmation, password) ==
                  null));
}
