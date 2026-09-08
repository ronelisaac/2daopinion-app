import 'package:flutter/foundation.dart';
import '../domain/form_limits.dart';

class ChipInputController extends ChangeNotifier {
  ChipInputController(String value) {
    restore(value);
  }
  List<String> _items = [];
  String pending = '';
  bool limitReached = false;
  List<String> get items => List.unmodifiable(_items);
  String get value => [..._items, if (pending.isNotEmpty) pending].join('\n');
  void restore(String value) {
    _items = value.split('\n').where((item) => item.isNotEmpty).toList();
    pending = '';
    limitReached = false;
    notifyListeners();
  }

  bool edit(String input, {bool commit = false}) {
    final parts = input.split(RegExp('[,\n]'));
    final next = [
      ..._items,
      ...parts
          .take(parts.length - 1)
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty),
    ];
    var rest = parts.last;
    if (commit && rest.trim().isNotEmpty) {
      next.add(rest.trim());
      rest = '';
    }
    final result = [...next, if (rest.isNotEmpty) rest].join('\n');
    limitReached = result.length > FormLimits.text;
    if (!limitReached) {
      _items = next;
      pending = rest;
    }
    notifyListeners();
    return !limitReached;
  }

  void remove(int index) {
    _items.removeAt(index);
    limitReached = false;
    notifyListeners();
  }
}
