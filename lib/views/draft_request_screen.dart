import 'package:flutter/material.dart';
import '../controllers/consultation_draft_controller.dart';
import '../controllers/consultation_steps_controller.dart';
import '../widgets/consultation_wizard.dart';
import '../core/localization.dart';
import '../core/draft_messages.dart';
import '../domain/consultation_draft.dart';
import '../domain/clinical_context.dart';
import '../widgets/clinical_context_fields.dart';
import '../widgets/form_page.dart';
import '../widgets/request_field.dart';
import '../widgets/draft_storage_consent.dart';
import '../widgets/chip_request_field.dart';
import '../controllers/document_selection_controller.dart';
import '../widgets/document_selection_panel.dart';
import '../controllers/private_documents_controller.dart';
import '../widgets/private_documents_panel.dart';

class DraftRequestScreen extends StatefulWidget {
  const DraftRequestScreen({
    super.key,
    required this.controller,
    this.initialDraft,
    this.onInitialDraftConsumed,
    this.documents,
    this.library,
  });
  final ConsultationDraftController controller;
  final ConsultationDraft? initialDraft;
  final VoidCallback? onInitialDraftConsumed;
  final DocumentSelectionController? documents;
  final PrivateDocumentsController? library;
  @override
  State<DraftRequestScreen> createState() => _DraftRequestScreenState();
}

class _DraftRequestScreenState extends State<DraftRequestScreen> {
  final _steps = ConsultationStepsController();
  final _scroll = ScrollController();
  final _reason = TextEditingController();
  final _details = TextEditingController();
  final _medicines = TextEditingController();
  final _treatments = TextEditingController();
  final _proposals = TextEditingController();
  bool _accepted = false;
  bool _dirty = false;
  bool _allowPop = false;
  bool _confirming = false;
  bool _savedNotice = false;
  bool _initialConsumed = false;
  ClinicalContext _clinical = const ClinicalContext();
  int _clinicalVersion = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!await widget.controller.load() || !mounted) return;
    var content = widget.controller.saved?.content;
    var useGuest = false;
    if (!_initialConsumed && widget.initialDraft != null) {
      useGuest =
          content == null ||
          await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: Text(strings(context).guestExistingTitle),
                  content: Text(strings(context).guestExistingBody),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(strings(context).guestKeepSaved),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(strings(context).guestUseNew),
                    ),
                  ],
                ),
              ) ==
              true;
      if (!mounted) return;
      if (useGuest) content = widget.initialDraft;
      if (!useGuest) widget.documents?.clear();
      _initialConsumed = true;
      widget.onInitialDraftConsumed?.call();
    }
    setState(() {
      _reason.text = content?.reason ?? '';
      _details.text = content?.details ?? '';
      _medicines.text = content?.medicines ?? '';
      _treatments.text = content?.specialTreatments ?? '';
      _proposals.text = content?.previousProposals ?? '';
      _clinical = content?.clinicalContext ?? const ClinicalContext();
      _clinicalVersion++;
      _dirty = useGuest;
      _savedNotice = false;
    });
    _goTo(useGuest ? 3 : 0);
    if (widget.controller.saved != null) {
      widget.library?.load(widget.controller.saved!.id);
    }
  }

  ConsultationDraft get _content => ConsultationDraft(
    countryCode: widget.controller.country.code,
    reason: _reason.text,
    details: _details.text,
    medicines: _medicines.text,
    specialTreatments: _treatments.text,
    previousProposals: _proposals.text,
    clinicalContext: _clinical,
  );

  void _goTo(int step) {
    if (widget.controller.busy || (widget.library?.transferring ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    _steps.select(step);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    if (_confirming) return false;
    _confirming = true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings(context).draftUnsavedTitle),
        content: Text(strings(context).draftUnsavedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings(context).draftKeepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings(context).draftDiscardChanges),
          ),
        ],
      ),
    );
    _confirming = false;
    return confirmed == true;
  }

  Future<void> _reload() async {
    if (widget.library?.transferring ?? false) return;
    if (widget.controller.busy || !await _confirmDiscard() || !mounted) return;
    await _load();
  }

  Future<void> _save() async {
    if (widget.library?.transferring ?? false) return;
    final success = await widget.controller.save(_content, accepted: _accepted);
    if (success && mounted) {
      widget.library?.load(widget.controller.saved!.id);
      setState(() {
        _dirty = false;
        _savedNotice = true;
      });
    }
  }

  void _changed(String _) => setState(() {
    _dirty = true;
    _savedNotice = false;
  });

  @override
  void dispose() {
    widget.library?.dispose();
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
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([widget.controller, _steps, widget.library]),
    builder: (context, child) {
      final controller = widget.controller;
      final text = strings(context);
      final transferring = widget.library?.transferring ?? false;
      if (!controller.loaded) {
        return Scaffold(
          appBar: AppBar(title: Text(text.draftTitle)),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: controller.busy
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(draftMessage(context, controller.issue!)),
                        TextButton(onPressed: _load, child: Text(text.retry)),
                      ],
                    ),
            ),
          ),
        );
      }
      return PopScope(
        canPop: _allowPop || (!_dirty && !controller.busy && !transferring),
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop ||
              transferring ||
              controller.busy ||
              !await _confirmDiscard() ||
              !context.mounted) {
            return;
          }
          setState(() => _allowPop = true);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.of(context).pop();
          });
        },
        child: FormPage(
          title: text.draftTitle,
          scrollController: _scroll,
          action: _steps.isReview ? text.saveDraft : text.nextStep,
          busy: controller.busy || transferring,
          onAction: () => _steps.isReview ? _save() : _goTo(_steps.index + 1),
          children: [
            Text(text.draftNotice),
            const SizedBox(height: 12),
            Text(text.noEmergencyNotice),
            const SizedBox(height: 16),
            if (_dirty) Text(text.draftUnsavedStatus),
            if (_savedNotice)
              Text(text.draftSaved, key: const ValueKey('draftSaved')),
            if (controller.saved != null)
              Text(
                text.draftSavedDate(
                  MaterialLocalizations.of(
                    context,
                  ).formatCompactDate(controller.saved!.updatedAt.toLocal()),
                ),
              ),
            const SizedBox(height: 16),
            AbsorbPointer(
              absorbing: controller.busy || transferring,
              child: Column(
                children: [
                  ConsultationWizard(
                    documents: widget.documents == null
                        ? null
                        : DocumentSelectionPanel(
                            controller: widget.documents!,
                            readOnly: _steps.isReview,
                            localUploadsEnabled: widget.library != null,
                          ),
                    step: _steps.index,
                    onStep: _goTo,
                    busy: controller.busy,
                    content: _content,
                    consultationFields: Column(
                      children: [
                        RequestField(
                          key: const ValueKey('draftReason'),
                          label: text.reason,
                          hint: text.reasonHint,
                          controller: _reason,
                          onChanged: _changed,
                        ),
                        RequestField(
                          key: const ValueKey('draftDetails'),
                          minLines: 4,
                          maxLines: 10,
                          label: text.details,
                          hint: text.detailsHint,
                          controller: _details,
                          onChanged: _changed,
                        ),
                        ChipRequestField(
                          key: const ValueKey('draftMedicines'),
                          label: text.medicines,
                          hint: text.medicinesHint,
                          controller: _medicines,
                          onChanged: _changed,
                        ),
                        RequestField(
                          key: const ValueKey('draftTreatments'),
                          label: text.specialTreatments,
                          hint: text.specialTreatmentsHint,
                          controller: _treatments,
                          onChanged: _changed,
                        ),
                        RequestField(
                          key: const ValueKey('draftProposals'),
                          label: text.previousProposals,
                          hint: text.previousProposalsHint,
                          controller: _proposals,
                          onChanged: _changed,
                        ),
                      ],
                    ),
                    clinicalFields: ClinicalContextFields(
                      key: ValueKey(_clinicalVersion),
                      showContext: _steps.index != 2,
                      showGoals: _steps.index == 2,
                      value: _clinical,
                      onChanged: (value) {
                        _clinical = value;
                        _changed('');
                      },
                    ),
                  ),
                  if (_steps.isReview)
                    DraftStorageConsent(
                      recorded: controller.saved != null,
                      value: _accepted,
                      onChanged: (value) => setState(() => _accepted = value),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (controller.issue != null)
              Text(
                draftMessage(context, controller.issue!),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            TextButton(
              onPressed: controller.busy || transferring ? null : _reload,
              child: Text(text.draftReload),
            ),
            if (_steps.isReview &&
                widget.library != null &&
                widget.documents != null)
              PrivateDocumentsPanel(
                controller: widget.library!,
                selection: widget.documents!,
              ),
            Text(text.draftNoSubmission),
            if (!_steps.isReview)
              TextButton(
                onPressed: controller.busy ? null : () => _goTo(3),
                child: Text(text.saveProgress),
              ),
          ],
        ),
      );
    },
  );
}
