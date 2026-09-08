import 'package:flutter/material.dart';
import '../controllers/consultation_draft_controller.dart';
import '../core/localization.dart';
import '../core/draft_messages.dart';
import '../domain/consultation_draft.dart';
import '../domain/clinical_context.dart';
import '../widgets/clinical_context_fields.dart';
import '../widgets/form_page.dart';
import '../widgets/request_field.dart';
import '../widgets/draft_storage_consent.dart';

class DraftRequestScreen extends StatefulWidget {
  const DraftRequestScreen({
    super.key,
    required this.controller,
    this.initialDraft,
    this.onInitialDraftConsumed,
  });
  final ConsultationDraftController controller;
  final ConsultationDraft? initialDraft;
  final VoidCallback? onInitialDraftConsumed;
  @override
  State<DraftRequestScreen> createState() => _DraftRequestScreenState();
}

class _DraftRequestScreenState extends State<DraftRequestScreen> {
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
    if (widget.controller.busy || !await _confirmDiscard() || !mounted) return;
    await _load();
  }

  Future<void> _save() async {
    final success = await widget.controller.save(
      ConsultationDraft(
        countryCode: widget.controller.country.code,
        reason: _reason.text,
        details: _details.text,
        medicines: _medicines.text,
        specialTreatments: _treatments.text,
        previousProposals: _proposals.text,
        clinicalContext: _clinical,
      ),
      accepted: _accepted,
    );
    if (success && mounted) {
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
    listenable: widget.controller,
    builder: (context, child) {
      final controller = widget.controller;
      final text = strings(context);
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
        canPop: _allowPop || (!_dirty && !controller.busy),
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop ||
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
          action: text.saveDraft,
          busy: controller.busy,
          onAction: _save,
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
              absorbing: controller.busy,
              child: Column(
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
                    label: text.details,
                    hint: text.detailsHint,
                    controller: _details,
                    onChanged: _changed,
                  ),
                  RequestField(
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
                  ClinicalContextFields(
                    key: ValueKey(_clinicalVersion),
                    value: _clinical,
                    onChanged: (value) {
                      _clinical = value;
                      _changed('');
                    },
                  ),
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
              onPressed: controller.busy ? null : _reload,
              child: Text(text.draftReload),
            ),
            Text(text.draftNoSubmission),
          ],
        ),
      );
    },
  );
}
