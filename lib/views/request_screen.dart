import 'package:flutter/material.dart';

import '../controllers/consultation_controller.dart';
import '../core/localization.dart';
import '../domain/operation_result.dart';
import '../widgets/asset_icon.dart';
import '../widgets/form_page.dart';
import '../widgets/preview_dialog.dart';
import '../widgets/request_field.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key, required this.controller});
  final ConsultationController controller;

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();
  final _details = TextEditingController();
  final _medicines = TextEditingController();
  final _treatments = TextEditingController();
  final _proposals = TextEditingController();

  @override
  void dispose() {
    for (final controller in [
      _reason,
      _details,
      _medicines,
      _treatments,
      _proposals,
    ]) {
      controller.dispose();
    }
    widget.controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final text = strings(context);
    try {
      final result = await widget.controller.submit(
        reason: _reason.text,
        details: _details.text,
        medicines: _medicines.text,
        specialTreatments: _treatments.text,
        previousProposals: _proposals.text,
      );
      if (!mounted) return;
      await explainPreview(
        context,
        result == OperationResult.previewOnly
            ? text.requestPreview
            : text.actionCompleted,
      );
    } catch (_) {
      if (!mounted) return;
      await explainPreview(context, text.actionFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    final controller = widget.controller;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) => Form(
        key: _formKey,
        child: FormPage(
          title: text.requestTitle,
          action: text.sendRequest,
          onAction: _submit,
          busy: controller.busy,
          children: [
            RequestField(
              label: text.reason,
              hint: text.reasonHint,
              controller: _reason,
              validator: (value) =>
                  inputError(context, controller.validateRequired(value)),
            ),
            RequestField(
              label: text.details,
              hint: text.detailsHint,
              controller: _details,
              validator: (value) =>
                  inputError(context, controller.validateRequired(value)),
            ),
            RequestField(
              label: text.medicines,
              hint: text.medicinesHint,
              controller: _medicines,
            ),
            RequestField(
              label: text.specialTreatments,
              hint: text.specialTreatmentsHint,
              controller: _treatments,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                text.documents,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                text.documentsHint,
                style: const TextStyle(fontSize: 14),
              ),
              trailing: const AssetIcon('next', size: 12),
              onTap: () => explainPreview(context, text.pendingFeature),
            ),
            const Divider(height: 1),
            const SizedBox(height: 20),
            RequestField(
              label: text.previousProposals,
              hint: text.previousProposalsHint,
              controller: _proposals,
            ),
          ],
        ),
      ),
    );
  }
}
