import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:crypto/crypto.dart';
import '../domain/form_limits.dart';
import '../domain/attachment_policy.dart';
import '../domain/pending_document.dart';
import '../domain/private_document.dart';

class FirebasePrivateDocumentRepository implements PrivateDocumentRepository {
  FirebasePrivateDocumentRepository({
    required FirebaseAuth Function() auth,
    required FirebaseFirestore Function() database,
    required FirebaseStorage Function() storage,
  }) : _auth = auth,
       _database = database,
       _storage = storage;
  final FirebaseAuth Function() _auth;
  final FirebaseFirestore Function() _database;
  final FirebaseStorage Function() _storage;
  String _owner([String? expected]) {
    final user = _auth().currentUser;
    if (user == null ||
        !user.emailVerified ||
        (expected != null && expected != user.uid)) {
      throw const DocumentFailure(DocumentIssue.session);
    }
    return user.uid;
  }

  Future<Result> _guard<Result>(Future<Result> Function() operation) async {
    try {
      return await operation();
    } on FirebaseException catch (error) {
      throw DocumentFailure(switch (error.code) {
        'unauthorized' || 'permission-denied' => DocumentIssue.permission,
        'unauthenticated' => DocumentIssue.session,
        'canceled' => DocumentIssue.cancelled,
        _ => DocumentIssue.unavailable,
      });
    }
  }

  CollectionReference<Map<String, dynamic>> _files(String owner) =>
      _database().collection('draftAttachments').doc(owner).collection('files');
  Reference _object(String owner, String draftId, Map<String, dynamic> data) {
    final key = 'private-drafts/$owner/$draftId/${data['id']}';
    if (data['authUserId'] != owner ||
        data['draftId'] != draftId ||
        data['objectKey'] != key ||
        data['storageBackendId'] != 'firebase-development-v1') {
      throw const DocumentFailure(DocumentIssue.invalid);
    }
    return _storage().ref(key);
  }

  PrivateDocument _decode(
    Map<String, dynamic> data,
    PrivateDocumentState state,
  ) => PrivateDocument(
    id: data['id'] as String,
    draftId: data['draftId'] as String,
    title: data['title'] as String,
    fileName: data['fileName'] as String,
    size: data['size'] as int,
    state: state,
  );
  Future<PrivateDocument> _inspect(
    String owner,
    String draftId,
    Map<String, dynamic> data,
  ) async {
    var state = PrivateDocumentState.stored;
    try {
      final metadata = await _object(owner, draftId, data).getMetadata();
      if (metadata.size != data['size'] ||
          metadata.contentType != data['mimeType'] ||
          metadata.customMetadata?['checksum'] != data['checksum']) {
        throw const DocumentFailure(DocumentIssue.invalid);
      }
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') rethrow;
      state = PrivateDocumentState.missing;
    }
    _owner(owner);
    return _decode(data, state);
  }

  @override
  Future<List<PrivateDocument>> list(String draftId) => _guard(() async {
    final owner = _owner();
    final records = await _files(owner)
        .limit(FormLimits.documents + 1)
        .get(const GetOptions(source: Source.server));
    _owner(owner);
    final result = <PrivateDocument>[];
    for (final record in records.docs) {
      result.add(await _inspect(owner, draftId, record.data()));
    }
    return result;
  });
  @override
  Future<PrivateDocument> upload(
    String draftId,
    PendingDocument document, {
    required bool accepted,
    required TransferCancellation cancellation,
    required void Function(double) onProgress,
  }) => _guard(() async {
    final owner = _owner();
    cancellation.check();
    if (!accepted ||
        document.title.trim().isEmpty ||
        document.title.length > 120 ||
        !AttachmentPolicy.valid(
          document.fileName,
          document.bytes.length,
          document.duration,
        )) {
      throw const DocumentFailure(DocumentIssue.invalid);
    }
    final mimeType = AttachmentPolicy.mimeType(document.fileName)!;
    final checksum = sha256.convert(document.bytes).toString();
    final id = sha256.convert(utf8.encode('$draftId:$checksum')).toString();
    final reference = _files(owner).doc(id);
    final quota = _database().collection('draftAttachments').doc(owner);
    final data = await _database().runTransaction<Map<String, dynamic>>((
      transaction,
    ) async {
      final existing = await transaction.get(reference);
      final budget = await transaction.get(quota);
      try {
        _owner(owner);
        cancellation.check();
      } on DocumentFailure catch (error) {
        return {'localFailure': error.issue.name};
      }
      if (existing.exists) return existing.data()!;
      final count = (budget.data()?['count'] as int? ?? 0) + 1;
      final videoCount =
          (budget.data()?['videoCount'] as int? ?? 0) +
          (document.isVideo ? 1 : 0);
      final size =
          (budget.data()?['bytes'] as int? ?? 0) + document.bytes.length;
      if (videoCount > 1 ||
          count - videoCount > FormLimits.documents ||
          size > FormLimits.totalDocumentBytes) {
        return {'localFailure': DocumentIssue.quota.name};
      }
      final record = <String, dynamic>{
        'id': id,
        'authUserId': owner,
        'draftId': draftId,
        'countryCode': 'CL',
        'title': document.title.trim(),
        'fileName': document.fileName,
        'size': document.bytes.length,
        'mimeType': mimeType,
        if (document.isVideo)
          'durationMilliseconds': document.duration!.inMilliseconds,
        'checksum': checksum,
        'storageBackendId': 'firebase-development-v1',
        'objectKey': 'private-drafts/$owner/$draftId/$id',
        'policyVersion': 'dev-files-2026-09-08',
        'acceptedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      };
      transaction.set(reference, record);
      transaction.set(quota, {
        'count': count,
        'videoCount': videoCount,
        'bytes': size,
        'lastDocumentId': id,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return record;
    });
    _owner(owner);
    cancellation.check();
    if (data.containsKey('localFailure')) {
      throw DocumentFailure(
        DocumentIssue.values.byName(data['localFailure'] as String),
      );
    }
    final existing = await _inspect(owner, draftId, data);
    if (existing.state == PrivateDocumentState.stored) {
      onProgress(1);
      return existing;
    }
    cancellation.check();
    final task = _object(owner, draftId, data).putData(
      document.bytes,
      SettableMetadata(
        contentType: data['mimeType'] as String,
        cacheControl: 'private, no-store',
        customMetadata: {'documentId': id, 'checksum': checksum},
      ),
    );
    cancellation.bind(() {
      unawaited(
        task.cancel().then<void>(
          (_) {},
          onError: (Object error, StackTrace stackTrace) {},
        ),
      );
    });
    final identity = _auth().userChanges().listen((user) {
      if (user?.uid != owner || user?.emailVerified != true) {
        cancellation.cancel();
      }
    });
    final progress = task.snapshotEvents.listen((snapshot) {
      if (!cancellation.cancelled) {
        onProgress(snapshot.bytesTransferred / document.bytes.length);
      }
    }, onError: (Object error, StackTrace stackTrace) {});
    try {
      await task;
      _owner(owner);
      cancellation.check();
      final confirmed = await _inspect(owner, draftId, data);
      if (confirmed.state != PrivateDocumentState.stored) {
        throw const DocumentFailure(DocumentIssue.unavailable);
      }
      return confirmed;
    } finally {
      cancellation.bind(null);
      await identity.cancel();
      await progress.cancel();
    }
  });
  @override
  Future<Uint8List> read(String draftId, String documentId) => _guard(() async {
    final owner = _owner();
    final record = await _files(
      owner,
    ).doc(documentId).get(const GetOptions(source: Source.server));
    _owner(owner);
    if (!record.exists) throw const DocumentFailure(DocumentIssue.invalid);
    final bytes = await _object(owner, draftId, record.data()!).getData(
      AttachmentPolicy.isVideo(record.data()!['fileName'] as String)
          ? FormLimits.videoBytes
          : FormLimits.documentBytes,
    );
    _owner(owner);
    if (bytes == null ||
        sha256.convert(bytes).toString() != record.data()!['checksum']) {
      throw const DocumentFailure(DocumentIssue.invalid);
    }
    return bytes;
  });
  @override
  Future<void> delete(String draftId, String documentId) => _guard(() async {
    final owner = _owner();
    final record = await _files(
      owner,
    ).doc(documentId).get(const GetOptions(source: Source.server));
    _owner(owner);
    if (!record.exists) throw const DocumentFailure(DocumentIssue.invalid);
    try {
      await _object(owner, draftId, record.data()!).delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') rethrow;
    }
    _owner(owner);
  });
}
