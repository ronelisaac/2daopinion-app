import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../domain/patient_notice.dart';

class NoticeCard extends StatelessWidget {
  const NoticeCard({
    super.key,
    required this.notice,
    required this.onToggle,
    this.busy = false,
  });
  final PatientNotice notice;
  final VoidCallback onToggle;
  final bool busy;
  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    final date = notice.createdAt.toLocal();
    final locale = MaterialLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  notice.isRead
                      ? Icons.mark_email_read_outlined
                      : Icons.mark_email_unread_outlined,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    notice.kind == NoticeKind.welcome
                        ? text.noticeWelcomeTitle
                        : text.noticeDraftTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              notice.kind == NoticeKind.welcome
                  ? text.noticeWelcomeBody
                  : text.noticeDraftBody,
            ),
            const SizedBox(height: 12),
            Text(
              '${locale.formatCompactDate(date)} · ${locale.formatTimeOfDay(TimeOfDay.fromDateTime(date))}',
            ),
            Text(notice.isRead ? text.noticeRead : text.noticeUnread),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: busy ? null : onToggle,
                child: Text(
                  notice.isRead ? text.noticeMarkUnread : text.noticeMarkRead,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
