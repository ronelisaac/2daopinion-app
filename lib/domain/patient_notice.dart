enum NoticeKind { welcome, draftReminder }

enum NoticeIssue { session, unavailable, invalid }

class NoticeFailure implements Exception {
  const NoticeFailure(this.issue);
  final NoticeIssue issue;
}

class PatientNotice {
  const PatientNotice({
    required this.id,
    required this.kind,
    required this.createdAt,
    required this.isRead,
  });
  final String id;
  final NoticeKind kind;
  final DateTime createdAt;
  final bool isRead;
  PatientNotice withRead(bool value) =>
      PatientNotice(id: id, kind: kind, createdAt: createdAt, isRead: value);
}

class NoticeCursor {
  const NoticeCursor({
    required this.ownerId,
    required this.timestampSeconds,
    required this.timestampNanoseconds,
    required this.id,
  });
  final String ownerId;
  final int timestampSeconds;
  final int timestampNanoseconds;
  final String id;
}

class NoticePage {
  const NoticePage(this.items, {this.next});
  final List<PatientNotice> items;
  final NoticeCursor? next;
}
