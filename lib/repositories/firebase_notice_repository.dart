import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/patient_notice.dart';
import '../domain/repositories/notice_repository.dart';

class FirebaseNoticeRepository implements NoticeRepository {
  FirebaseNoticeRepository({
    required FirebaseAuth Function() auth,
    required FirebaseFirestore Function() database,
  }) : _auth = auth,
       _database = database;
  final FirebaseAuth Function() _auth;
  final FirebaseFirestore Function() _database;
  String _owner([String? expected]) {
    final user = _auth().currentUser;
    if (user == null ||
        !user.emailVerified ||
        (expected != null && expected != user.uid)) {
      throw const NoticeFailure(NoticeIssue.session);
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> _items(String uid) =>
      _database().collection('patientNotices').doc(uid).collection('items');
  Future<Result> _guard<Result>(Future<Result> Function() operation) async {
    try {
      return await operation();
    } on NoticeFailure {
      rethrow;
    } on FirebaseException catch (error) {
      throw NoticeFailure(
        error.code == 'unauthenticated' || error.code == 'permission-denied'
            ? NoticeIssue.session
            : NoticeIssue.unavailable,
      );
    } catch (_) {
      throw const NoticeFailure(NoticeIssue.invalid);
    }
  }

  PatientNotice _decode(
    String uid,
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(snapshot.id) ||
        data.length != 6 ||
        !data.keys.toSet().containsAll([
          'id',
          'recipientId',
          'schemaVersion',
          'templateCode',
          'createdAt',
          'readAt',
        ]) ||
        data['id'] != snapshot.id ||
        data['recipientId'] != uid ||
        data['schemaVersion'] != 1 ||
        data['createdAt'] is! Timestamp ||
        (data['readAt'] != null && data['readAt'] is! Timestamp)) {
      throw const NoticeFailure(NoticeIssue.invalid);
    }
    final kind = switch (data['templateCode']) {
      'welcome' => NoticeKind.welcome,
      'draft_reminder' => NoticeKind.draftReminder,
      _ => throw const NoticeFailure(NoticeIssue.invalid),
    };
    return PatientNotice(
      id: snapshot.id,
      kind: kind,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRead: data['readAt'] != null,
    );
  }

  @override
  Future<NoticePage> page({NoticeCursor? after}) => _guard(() async {
    final uid = _owner(after?.ownerId);
    Query<Map<String, dynamic>> query = _items(uid)
        .orderBy('createdAt', descending: true)
        .orderBy(FieldPath.documentId, descending: true);
    if (after != null) {
      query = query.startAfter([
        Timestamp(after.timestampSeconds, after.timestampNanoseconds),
        after.id,
      ]);
    }
    final result = await query
        .limit(21)
        .get(const GetOptions(source: Source.server));
    _owner(uid);
    final items = result.docs
        .take(20)
        .map((record) => _decode(uid, record))
        .toList();
    final last = items.isEmpty ? null : result.docs[items.length - 1];
    final timestamp = last?.data()['createdAt'] as Timestamp?;
    return NoticePage(
      items,
      next: result.docs.length > 20 && last != null && timestamp != null
          ? NoticeCursor(
              ownerId: uid,
              timestampSeconds: timestamp.seconds,
              timestampNanoseconds: timestamp.nanoseconds,
              id: last.id,
            )
          : null,
    );
  });
  @override
  Future<int> unreadCount() => _guard(() async {
    final uid = _owner();
    final result = await _items(uid)
        .where('readAt', isNull: true)
        .limit(100)
        .get(const GetOptions(source: Source.server));
    _owner(uid);
    return result.docs.length;
  });
  @override
  Future<void> setRead(String id, bool isRead) => _guard(() async {
    final uid = _owner();
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(id)) {
      throw const NoticeFailure(NoticeIssue.invalid);
    }
    final reference = _items(uid).doc(id);
    final valid = await _database().runTransaction<bool>((transaction) async {
      final snapshot = await transaction.get(reference);
      final user = _auth().currentUser;
      if (user?.uid != uid ||
          user?.emailVerified != true ||
          !snapshot.exists ||
          snapshot.data()?['recipientId'] != uid) {
        return false;
      }
      if ((snapshot.data()?['readAt'] != null) != isRead) {
        transaction.update(reference, {
          'readAt': isRead ? FieldValue.serverTimestamp() : null,
        });
      }
      return true;
    });
    _owner(uid);
    if (!valid) throw const NoticeFailure(NoticeIssue.invalid);
  });
}
