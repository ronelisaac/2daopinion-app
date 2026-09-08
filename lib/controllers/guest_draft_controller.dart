import '../domain/consultation_draft.dart';

class GuestDraftController {
  ConsultationDraft? content;
  bool resumeAfterAccess = false;
  void update(ConsultationDraft value) {
    content = value;
  }

  void clear() {
    content = null;
    resumeAfterAccess = false;
  }
}
