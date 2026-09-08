import '../consultation_draft.dart';
import '../operation_result.dart';

abstract interface class ConsultationRepository {
  Future<OperationResult> submit(ConsultationDraft draft);
}
