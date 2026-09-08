import '../domain/consultation_draft.dart';
import '../domain/operation_result.dart';
import '../domain/repositories/consultation_repository.dart';

class PreviewConsultationRepository implements ConsultationRepository {
  const PreviewConsultationRepository();

  @override
  Future<OperationResult> submit(ConsultationDraft draft) async =>
      OperationResult.previewOnly;
}
