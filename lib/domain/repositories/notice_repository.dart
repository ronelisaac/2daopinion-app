import '../patient_notice.dart';

abstract interface class NoticeRepository {
  Future<NoticePage> page({NoticeCursor? after});
  Future<int> unreadCount();
  Future<void> setRead(String id, bool isRead);
}
