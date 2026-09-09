import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/consultation_submission.dart';
import '../domain/saved_consultation_draft.dart';
import '../domain/private_document.dart';
import '../domain/repositories/consultation_submission_repository.dart';

class FirebaseConsultationSubmissionRepository
    implements ConsultationSubmissionRepository {
  FirebaseConsultationSubmissionRepository({
    required FirebaseAuth Function() auth,
    required FirebaseFirestore Function() database,
    this.documents,
  }) : _auth = auth,
       _database = database;
  final FirebaseAuth Function() _auth;
  final FirebaseFirestore Function() _database;
  final PrivateDocumentRepository? documents;

  String _owner() {
    final user = _auth().currentUser;
    if (user == null || !user.emailVerified) {
      throw const SubmissionFailure(SubmissionIssue.session);
    }
    return user.uid;
  }

  ConsultationSubmission _decode(Map<String, dynamic> data) =>
      ConsultationSubmission(
        id: data['id'] as String,
        revision: data['revision'] as int,
        submittedAt: (data['submittedAt'] as Timestamp).toDate().toUtc(),
        documentCount:
            (data['attachmentBatch']?['count'] as int? ?? 0) -
            (data['attachmentBatch']?['videoCount'] as int? ?? 0),
        hasVideo: data['attachmentBatch']?['videoCount'] == 1,
      );

  Future<Result> _guard<Result>(Future<Result> Function() action) async {
    try {
      return await action();
    } on FirebaseException catch (error) {
      throw SubmissionFailure(
        error.code == 'permission-denied' || error.code == 'unauthenticated'
            ? SubmissionIssue.session
            : SubmissionIssue.unavailable,
      );
    }
  }

  @override
  Future<ConsultationSubmission?> load() => _guard(() async {
    final owner = _owner();
    final snapshot = await _database()
        .collection('consultationSubmissions')
        .doc(owner)
        .get(const GetOptions(source: Source.server));
    if (_owner() != owner) {
      throw const SubmissionFailure(SubmissionIssue.session);
    }
    return snapshot.exists ? _decode(snapshot.data()!) : null;
  });

  @override
  Future<ConsultationSubmission> submit(
    SavedConsultationDraft draft, {
    required bool accepted,
  }) => _guard(() async {
    if (!accepted) throw const SubmissionFailure(SubmissionIssue.consent);
    if (!draft.content.readyForSubmission) {
      throw const SubmissionFailure(SubmissionIssue.invalid);
    }
    final owner = _owner();
    final database = _database();
    final reference = database.collection('consultationSubmissions').doc(owner);
    final previous = await load();
    if (_owner() != owner) {
      throw const SubmissionFailure(SubmissionIssue.session);
    }
    if (previous != null) {
      if (previous.id != draft.id) {
        throw const SubmissionFailure(SubmissionIssue.conflict);
      }
      return previous;
    }
    List<PrivateDocument> inspected = const [];
    if (documents != null) {
      try {
        inspected = await documents!.list(draft.id);
      } on DocumentFailure catch (error) {
        throw SubmissionFailure(
          error.issue == DocumentIssue.session
              ? SubmissionIssue.session
              : SubmissionIssue.attachments,
        );
      }
      if (inspected.any((file) => file.state != PrivateDocumentState.stored)) {
        throw const SubmissionFailure(SubmissionIssue.attachments);
      }
    }
    try {
      final issue = await database.runTransaction<SubmissionIssue?>((
        transaction,
      ) async {
        final existing = await transaction.get(reference);
        if (existing.exists) {
          if (existing.data()!['id'] != draft.id) {
            return SubmissionIssue.conflict;
          }
          return null;
        }
        final source = await transaction.get(
          database.collection('consultationDrafts').doc(owner),
        );
        final attachments = await transaction.get(
          database.collection('draftAttachments').doc(owner),
        );
        if (_auth().currentUser?.uid != owner ||
            _auth().currentUser?.emailVerified != true) {
          return SubmissionIssue.session;
        }
        if ((attachments.data()?['count'] ?? 0) != inspected.length ||
            (attachments.exists &&
                !inspected.any(
                  (file) => file.id == attachments.data()!['lastDocumentId'],
                ))) {
          return SubmissionIssue.attachments;
        }
        final data = source.data();
        if (data == null ||
            data['id'] != draft.id ||
            data['revision'] != draft.revision) {
          return SubmissionIssue.conflict;
        }
        final mode =
            (data['clinicalContext'] as Map<String, dynamic>?)?['modality'];
        if (!['document_review', 'review_and_consultation'].contains(mode)) {
          return SubmissionIssue.invalid;
        }
        transaction.set(reference, {
          'id': draft.id,
          'authUserId': owner,
          'countryCode': data['countryCode'],
          'revision': draft.revision,
          'environment': 'development',
          'status': 'received',
          'policyVersion': submissionPolicyVersion,
          'accepted': true,
          'submittedAt': FieldValue.serverTimestamp(),
          'draft': data,
          if (attachments.exists) 'attachmentBatch': attachments.data(),
        });
        transaction.set(database.collection('intakeRequests').doc(draft.id), {
          'id': draft.id,
          'countryCode': data['countryCode'],
          'mode': mode,
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'received',
          'environment': 'development',
          'documentCount':
              (attachments.data()?['count'] as int? ?? 0) -
              (attachments.data()?['videoCount'] as int? ?? 0),
          'hasVideo': attachments.data()?['videoCount'] == 1,
        });
        return null;
      });
      if (issue != null) throw SubmissionFailure(issue);
    } on FirebaseException catch (error) {
      if (error.code != 'permission-denied') rethrow;
      if (_owner() != owner) {
        throw const SubmissionFailure(SubmissionIssue.session);
      }
      final existing = await load();
      if (_owner() != owner) {
        throw const SubmissionFailure(SubmissionIssue.session);
      }
      if (existing == null || existing.id != draft.id) rethrow;
      return existing;
    }
    if (_owner() != owner) {
      throw const SubmissionFailure(SubmissionIssue.session);
    }
    final receipt = await load();
    if (_owner() != owner) {
      throw const SubmissionFailure(SubmissionIssue.session);
    }
    if (receipt == null) {
      throw const SubmissionFailure(SubmissionIssue.unavailable);
    }
    return receipt;
  });
}
