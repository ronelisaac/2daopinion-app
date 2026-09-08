import '../domain/patient_notice.dart';
import '../domain/repositories/notice_repository.dart';

class PreviewNoticeRepository implements NoticeRepository {
  List<PatientNotice> _items = [
    PatientNotice(
      id: 'a' * 64,
      kind: NoticeKind.welcome,
      createdAt: DateTime.utc(2026, 9, 8, 12),
      isRead: false,
    ),
    PatientNotice(
      id: 'b' * 64,
      kind: NoticeKind.draftReminder,
      createdAt: DateTime.utc(2026, 9, 8, 11),
      isRead: false,
    ),
  ];
  @override
  Future<NoticePage> page({NoticeCursor? after}) async =>
      NoticePage(List.unmodifiable(_items));
  @override
  Future<int> unreadCount() async =>
      _items.where((item) => !item.isRead).length;
  @override
  Future<void> setRead(String id, bool isRead) async {
    _items = _items
        .map((item) => item.id == id ? item.withRead(isRead) : item)
        .toList();
  }
}
