import 'package:flutter/foundation.dart';
import '../domain/patient_notice.dart';
import '../domain/repositories/notice_repository.dart';

class NoticesController extends ChangeNotifier {
  NoticesController(this._repository);
  final NoticeRepository _repository;
  List<PatientNotice> _items = [];
  List<PatientNotice> get items => List.unmodifiable(_items);
  NoticeCursor? _next;
  bool get hasMore => _next != null;
  bool busy = false;
  bool loaded = false;
  bool _disposed = false;
  int? unread;
  NoticeIssue? issue;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _failed(Object error) {
    issue = error is NoticeFailure ? error.issue : NoticeIssue.unavailable;
    unread = null;
    if (issue == NoticeIssue.session) {
      _items = [];
      _next = null;
      loaded = false;
    }
  }

  Future<void> refreshCount() async {
    if (busy || _disposed) return;
    busy = true;
    issue = null;
    unread = null;
    _notify();
    try {
      final count = await _repository.unreadCount();
      if (!_disposed) unread = count;
    } catch (error) {
      if (!_disposed) _failed(error);
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> load({bool more = false}) async {
    if (busy || _disposed || (more && !hasMore)) return;
    busy = true;
    issue = null;
    unread = null;
    _notify();
    try {
      final result = await _repository.page(after: more ? _next : null);
      if (_disposed) return;
      final merged = {
        for (final item in more ? _items : <PatientNotice>[]) item.id: item,
      };
      for (final item in result.items) {
        merged[item.id] = item;
      }
      _items = merged.values.toList();
      _next = result.next;
      loaded = true;
      final count = await _repository.unreadCount();
      if (!_disposed) unread = count;
    } catch (error) {
      if (!_disposed) _failed(error);
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> setRead(PatientNotice notice, bool value) async {
    if (busy || _disposed) return;
    busy = true;
    issue = null;
    _notify();
    try {
      await _repository.setRead(notice.id, value);
      if (_disposed) return;
      _items = _items
          .map((item) => item.id == notice.id ? item.withRead(value) : item)
          .toList();
      final count = await _repository.unreadCount();
      if (!_disposed) unread = count;
    } catch (error) {
      if (!_disposed) _failed(error);
    } finally {
      busy = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _items = [];
    unread = null;
    _next = null;
    super.dispose();
  }
}
