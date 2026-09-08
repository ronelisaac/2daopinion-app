import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/consultation_draft.dart';
import 'clinical_context_mapper.dart';
import '../domain/saved_consultation_draft.dart';
import '../domain/repositories/consultation_draft_repository.dart';

class FirebaseConsultationDraftRepository
    implements ConsultationDraftRepository {
  FirebaseConsultationDraftRepository({
    required FirebaseAuth Function() auth,
    required FirebaseFirestore Function() database,
  }) : _auth = auth,
       _database = database;
  final FirebaseAuth Function() _auth;
  final FirebaseFirestore Function() _database;

  String _owner() {
    final user = _auth().currentUser;
    if (user == null || !user.emailVerified) {
      throw const DraftFailure(DraftIssue.session);
    }
    return user.uid;
  }

  Future<Result> _guard<Result>(Future<Result> Function() operation) async {
    try {
      return await operation();
    } on FirebaseException catch (error) {
      throw DraftFailure(switch (error.code) {
        'permission-denied' => DraftIssue.permission,
        'unauthenticated' => DraftIssue.session,
        _ => DraftIssue.unavailable,
      });
    }
  }

  SavedConsultationDraft _decode(Map<String, dynamic> data) =>
      SavedConsultationDraft(
        id: data['id'] as String,
        revision: data['revision'] as int,
        updatedAt: (data['updatedAt'] as Timestamp).toDate().toUtc(),
        content: ConsultationDraft(
          countryCode: data['countryCode'] as String,
          reason: data['reason'] as String,
          details: data['details'] as String,
          medicines: data['medicines'] as String,
          specialTreatments: data['specialTreatments'] as String,
          previousProposals: data['previousProposals'] as String,
          clinicalContext: ClinicalContextMapper.decode(
            data['clinicalContext'] as Map<String, dynamic>?,
          ),
        ),
      );

  @override
  Future<SavedConsultationDraft?> load() => _guard(() async {
    final owner = _owner();
    final snapshot = await _database()
        .collection('consultationDrafts')
        .doc(owner)
        .get(const GetOptions(source: Source.server));
    if (_owner() != owner) throw const DraftFailure(DraftIssue.session);
    return snapshot.exists ? _decode(snapshot.data()!) : null;
  });

  @override
  Future<SavedConsultationDraft> save(
    ConsultationDraft content, {
    required int expectedRevision,
    required bool acceptStorageTerms,
  }) => _guard(() async {
    if (!content.withinStorageLimits) {
      throw const DraftFailure(DraftIssue.invalid);
    }
    final owner = _owner();
    final database = _database();
    final reference = database.collection('consultationDrafts').doc(owner);
    final newId = database.collection('consultationDrafts').doc().id;
    final issue = await database.runTransaction<DraftIssue?>((
      transaction,
    ) async {
      final existing = await transaction.get(reference);
      final profile = await transaction.get(
        database.collection('profiles').doc(owner),
      );
      if (_auth().currentUser?.uid != owner || !profile.exists) {
        return DraftIssue.session;
      }
      if ((existing.data()?['revision'] ?? 0) != expectedRevision) {
        return DraftIssue.conflict;
      }
      if (!existing.exists && !acceptStorageTerms) {
        return DraftIssue.consent;
      }
      final fields = <String, dynamic>{
        'reason': content.reason,
        'details': content.details,
        'medicines': content.medicines,
        'specialTreatments': content.specialTreatments,
        'previousProposals': content.previousProposals,
        'clinicalContext': ClinicalContextMapper.encode(
          content.clinicalContext,
        ),
        'revision': expectedRevision + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (existing.exists) {
        transaction.update(reference, fields);
      } else {
        transaction.set(reference, {
          ...fields,
          'id': newId,
          'authUserId': owner,
          'patientId': profile.data()!['id'],
          'countryCode': content.countryCode,
          'status': 'draft',
          'environment': 'development',
          'policyVersion': draftStoragePolicyVersion,
          'createdAt': FieldValue.serverTimestamp(),
        });
        transaction.set(
          reference.collection('consents').doc(draftStoragePolicyVersion),
          {
            'draftId': newId,
            'authUserId': owner,
            'policyVersion': draftStoragePolicyVersion,
            'context': 'development-draft-storage',
            'accepted': true,
            'acceptedAt': FieldValue.serverTimestamp(),
          },
        );
      }
      return null;
    });
    if (issue != null) throw DraftFailure(issue);
    if (_owner() != owner) throw const DraftFailure(DraftIssue.session);
    final persisted = await reference.get(
      const GetOptions(source: Source.server),
    );
    if (_owner() != owner) throw const DraftFailure(DraftIssue.session);
    if (persisted.data()?['revision'] != expectedRevision + 1) {
      throw const DraftFailure(DraftIssue.conflict);
    }
    return _decode(persisted.data()!);
  });
}
