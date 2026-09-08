import 'package:flutter/material.dart';
import '../controllers/notices_controller.dart';
import '../core/localization.dart';
import '../widgets/responsive_content.dart';
import '../widgets/informational_footer.dart';
import '../widgets/notice_card.dart';

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key, this.createController, this.preview = false});
  final NoticesController Function()? createController;
  final bool preview;
  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  late final NoticesController? controller;
  @override
  void initState() {
    super.initState();
    controller = widget.createController?.call();
    controller?.load();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    final controller = this.controller;
    Widget content() => ResponsiveContent(
      maxWidth: 800,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.preview
                ? text.noticesPreviewNotice
                : text.noticesLocalNotice,
          ),
          const SizedBox(height: 16),
          if (controller == null) ...[
            Text(text.noticesUnavailable),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/preview/notifications'),
              child: Text(text.noticesExplore),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    controller.unread == null
                        ? text.noticesCountUnknown
                        : text.noticesUnreadCount(
                            controller.unread! >= 100
                                ? '99+'
                                : '${controller.unread}',
                          ),
                  ),
                ),
                IconButton(
                  onPressed: controller.busy ? null : controller.load,
                  tooltip: text.noticesRefresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            if (controller.busy) const LinearProgressIndicator(),
            if (controller.issue != null) ...[
              Text(
                text.noticesFailed,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              TextButton(
                onPressed: controller.busy ? null : controller.load,
                child: Text(text.retry),
              ),
            ],
            if (controller.loaded &&
                controller.items.isEmpty &&
                !controller.busy &&
                controller.issue == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    const Icon(Icons.notifications_none, size: 48),
                    const SizedBox(height: 12),
                    Text(text.noticesEmpty),
                  ],
                ),
              ),
            for (final notice in controller.items)
              NoticeCard(
                key: ValueKey(notice.id),
                notice: notice,
                busy: controller.busy,
                onToggle: () => controller.setRead(notice, !notice.isRead),
              ),
            if (controller.hasMore)
              OutlinedButton(
                onPressed: controller.busy
                    ? null
                    : () => controller.load(more: true),
                child: Text(text.noticesMore),
              ),
          ],
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(title: Text(text.noticesTitle)),
      bottomNavigationBar: const InformationalFooter(showPreviewNotice: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: controller == null
              ? content()
              : ListenableBuilder(
                  listenable: controller,
                  builder: (_, _) => content(),
                ),
        ),
      ),
    );
  }
}
