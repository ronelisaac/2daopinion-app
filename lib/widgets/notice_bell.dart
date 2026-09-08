import 'package:flutter/material.dart';
import '../core/localization.dart';

class NoticeBell extends StatelessWidget {
  const NoticeBell({
    super.key,
    required this.onPressed,
    this.unread,
    this.preview = false,
  });
  final VoidCallback onPressed;
  final int? unread;
  final bool preview;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: preview
        ? strings(context).noticesExplore
        : strings(context).noticesTitle,
    onPressed: onPressed,
    icon: Badge(
      isLabelVisible: unread != null && unread! > 0,
      label: Text(unread != null && unread! >= 100 ? '99+' : '${unread ?? 0}'),
      child: const Icon(Icons.notifications_outlined),
    ),
  );
}
