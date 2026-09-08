import '../domain/account_draft.dart';
import '../domain/operation_result.dart';
import '../domain/repositories/account_repository.dart';

class PreviewAccountRepository implements AccountRepository {
  const PreviewAccountRepository();

  @override
  Future<OperationResult> signIn(AccountDraft account) async =>
      OperationResult.previewOnly;

  @override
  Future<OperationResult> createAccount(AccountDraft account) async =>
      OperationResult.previewOnly;
}
