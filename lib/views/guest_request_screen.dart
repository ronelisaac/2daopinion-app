import 'package:flutter/material.dart';
import '../controllers/guest_draft_controller.dart';
import '../controllers/consultation_steps_controller.dart';
import '../core/localization.dart';
import '../domain/clinical_context.dart';
import '../domain/consultation_draft.dart';
import '../domain/country_config.dart';
import '../widgets/clinical_context_fields.dart';
import '../widgets/form_page.dart';
import '../widgets/request_field.dart';
import '../widgets/consultation_wizard.dart';

class GuestRequestScreen extends StatefulWidget {
  const GuestRequestScreen({
    super.key,
    required this.controller,
    required this.onAccess,
  });
  final GuestDraftController controller;
  final VoidCallback onAccess;
  @override
  State<GuestRequestScreen> createState() => _GuestRequestScreenState();
}

class _GuestRequestScreenState extends State<GuestRequestScreen> {
  final _steps = ConsultationStepsController();
  final _scroll = ScrollController();
  late final _reason = TextEditingController(
    text: widget.controller.content?.reason ?? '',
  );
  late final _details = TextEditingController(
    text: widget.controller.content?.details ?? '',
  );
  late final _medicines = TextEditingController(
    text: widget.controller.content?.medicines ?? '',
  );
  late final _treatments = TextEditingController(
    text: widget.controller.content?.specialTreatments ?? '',
  );
  late final _proposals = TextEditingController(
    text: widget.controller.content?.previousProposals ?? '',
  );
  late ClinicalContext _clinical =
      widget.controller.content?.clinicalContext ?? const ClinicalContext();

  ConsultationDraft get _content => ConsultationDraft(
    countryCode: CountryConfig.chile.code,
    reason: _reason.text,
    details: _details.text,
    medicines: _medicines.text,
    specialTreatments: _treatments.text,
    previousProposals: _proposals.text,
    clinicalContext: _clinical,
  );
  void _capture(String _) => widget.controller.update(_content);
  void _goTo(int step) {
    FocusScope.of(context).unfocus();
    _steps.select(step);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  void dispose() {
    _steps.dispose();
    _scroll.dispose();
    for (final field in [
      _reason,
      _details,
      _medicines,
      _treatments,
      _proposals,
    ]) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    return ListenableBuilder(
      listenable: _steps,
      builder: (context, _) => FormPage(
        title: text.requestTitle,
        scrollController: _scroll,
        action: _steps.isReview ? text.guestContinue : text.nextStep,
        onAction: () {
          if (!_steps.isReview) {
            _goTo(_steps.index + 1);
            return;
          }
          _capture('');
          widget.controller.resumeAfterAccess = true;
          widget.onAccess();
        },
        showFooter: true,
        children: [
          Text(text.guestRequestNotice),
          const SizedBox(height: 12),
          Text(
            text.noEmergencyNotice,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          ConsultationWizard(
            step: _steps.index,
            onStep: _goTo,
            content: _content,
            consultationFields: Column(
              children: [
                RequestField(
                  label: text.reason,
                  hint: text.reasonHint,
                  controller: _reason,
                  onChanged: _capture,
                ),
                RequestField(
                  label: text.details,
                  hint: text.detailsHint,
                  controller: _details,
                  onChanged: _capture,
                ),
                RequestField(
                  label: text.medicines,
                  hint: text.medicinesHint,
                  controller: _medicines,
                  onChanged: _capture,
                ),
                RequestField(
                  label: text.specialTreatments,
                  hint: text.specialTreatmentsHint,
                  controller: _treatments,
                  onChanged: _capture,
                ),
                RequestField(
                  label: text.previousProposals,
                  hint: text.previousProposalsHint,
                  controller: _proposals,
                  onChanged: _capture,
                ),
              ],
            ),
            clinicalFields: ClinicalContextFields(
              showContext: _steps.index != 2,
              showGoals: _steps.index == 2,
              value: _clinical,
              onChanged: (value) {
                _clinical = value;
                _capture('');
              },
            ),
          ),
        ],
      ),
    );
  }
}
