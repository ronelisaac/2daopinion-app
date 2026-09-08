import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../domain/clinical_context.dart';
import '../domain/birth_date.dart';
import 'birth_date_field.dart';
import 'chip_request_field.dart';
import 'request_field.dart';

class ClinicalContextFields extends StatefulWidget {
  const ClinicalContextFields({
    super.key,
    required this.value,
    required this.onChanged,
    this.showContext = true,
    this.showGoals = true,
  });
  final ClinicalContext value;
  final ValueChanged<ClinicalContext> onChanged;
  final bool showContext;
  final bool showGoals;
  @override
  State<ClinicalContextFields> createState() => _ClinicalContextFieldsState();
}

class _ClinicalContextFieldsState extends State<ClinicalContextFields> {
  late final _patient = TextEditingController(
    text: widget.value.patientContext,
  );
  late final _diagnosis = TextEditingController(
    text: widget.value.knownDiagnosis,
  );
  late final _evolution = TextEditingController(
    text: widget.value.symptomEvolution,
  );
  late final _history = TextEditingController(
    text: widget.value.medicalHistory,
  );
  late final _allergies = TextEditingController(text: widget.value.allergies);
  late final _questions = TextEditingController(text: widget.value.questions);
  late final _studies = TextEditingController(text: widget.value.studySummary);
  late final _specialty = TextEditingController(text: widget.value.specialty);
  late String _modality = widget.value.modality;
  late BirthDate? _birthDate = widget.value.birthDate;
  void _changed(String _) => widget.onChanged(
    ClinicalContext(
      birthDate: _birthDate,
      patientContext: _patient.text,
      knownDiagnosis: _diagnosis.text,
      symptomEvolution: _evolution.text,
      medicalHistory: _history.text,
      allergies: _allergies.text,
      questions: _questions.text,
      studySummary: _studies.text,
      specialty: _specialty.text,
      modality: _modality,
    ),
  );
  @override
  void dispose() {
    for (final field in [
      _patient,
      _diagnosis,
      _evolution,
      _history,
      _allergies,
      _questions,
      _studies,
      _specialty,
    ]) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showContext) ...[
          Text(
            text.clinicalContextTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(text.clinicalOptionalNotice),
          const SizedBox(height: 20),
          BirthDateField(
            value: _birthDate,
            onChanged: (value) {
              setState(() => _birthDate = value);
              _changed('');
            },
          ),
          RequestField(
            label: text.patientContext,
            hint: text.patientContextHint,
            controller: _patient,
            onChanged: _changed,
          ),
          RequestField(
            label: text.knownDiagnosis,
            minLines: 3,
            maxLines: 8,
            hint: text.knownDiagnosisHint,
            controller: _diagnosis,
            onChanged: _changed,
          ),
          ChipRequestField(
            label: text.symptomEvolution,
            hint: text.symptomEvolutionHint,
            controller: _evolution,
            onChanged: _changed,
          ),
          RequestField(
            label: text.medicalHistory,
            hint: text.medicalHistoryHint,
            controller: _history,
            onChanged: _changed,
          ),
          ChipRequestField(
            label: text.allergies,
            hint: text.allergiesHint,
            controller: _allergies,
            onChanged: _changed,
          ),
        ],
        if (widget.showGoals) ...[
          Text(
            text.clinicalGoalsTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          ChipRequestField(
            label: text.questions,
            hint: text.questionsHint,
            controller: _questions,
            onChanged: _changed,
          ),
          if (_studies.text.isNotEmpty)
            RequestField(
              label: text.legacyStudySummary,
              hint: text.studySummaryHint,
              controller: _studies,
              onChanged: _changed,
            ),
          const SizedBox(height: 20),
          RequestField(
            label: text.specialty,
            hint: text.specialtyHint,
            controller: _specialty,
            onChanged: _changed,
          ),
          DropdownButtonFormField<String>(
            initialValue: _modality,
            isExpanded: true,
            decoration: InputDecoration(labelText: text.preferredModality),
            items: [
              DropdownMenuItem(value: '', child: Text(text.modalityUnsure)),
              DropdownMenuItem(
                value: 'document_review',
                child: Text(text.modalityDocument),
              ),
              DropdownMenuItem(
                value: 'review_and_consultation',
                child: Text(text.modalityConsultation),
              ),
            ],
            onChanged: (value) {
              _modality = value ?? '';
              _changed('');
            },
          ),
          const SizedBox(height: 12),
          Text(text.modalityNotice),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}
