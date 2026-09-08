import '../account_draft.dart';
import '../operation_result.dart';

abstract interface class AccountRepository {
  Future<OperationResult> signIn(AccountDraft account);
  Future<OperationResult> signInWithGoogle();
  Future<OperationResult> createAccount(AccountDraft account);
}
