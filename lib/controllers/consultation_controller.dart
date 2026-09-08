import 'package:flutter/foundation.dart';

import '../domain/input_validation.dart';
import '../domain/consultation_draft.dart';
import '../domain/country_config.dart';
import '../domain/operation_result.dart';
import '../domain/repositories/consultation_repository.dart';

class ConsultationController extends ChangeNotifier {
  ConsultationController(this._repository, {required this.country});

  final ConsultationRepository _repository;
  final CountryConfig country;
  bool _busy = false;
  bool _disposed = false;

  bool get busy => _busy;

  InputIssue? validateRequired(String? value) =>
      InputValidation.required(value);

  Future<OperationResult> submit({
    required String reason,
    required String details,
    required String medicines,
    required String specialTreatments,
    required String previousProposals,
  }) async {
    if (_busy) throw StateError('A consultation operation is already running.');
    final draft = ConsultationDraft(
      countryCode: country.code,
      reason: reason.trim(),
      details: details.trim(),
      medicines: medicines.trim(),
      specialTreatments: specialTreatments.trim(),
      previousProposals: previousProposals.trim(),
    );
    if (!draft.isComplete) {
      throw ArgumentError('Consultation fields are invalid.');
    }
    _busy = true;
    notifyListeners();
    try {
      return await _repository.submit(draft);
    } finally {
      _busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
