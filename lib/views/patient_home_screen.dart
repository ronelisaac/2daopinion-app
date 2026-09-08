import 'package:flutter/material.dart';
import '../controllers/draft_overview_controller.dart';
import '../widgets/draft_overview_card.dart';
import 'home_screen.dart';
import '../controllers/notices_controller.dart';
import '../widgets/notice_bell.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({
    super.key,
    required this.controller,
    required this.onSignOut,
    this.notices,
  });
  final DraftOverviewController controller;
  final VoidCallback onSignOut;
  final NoticesController? notices;
  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  bool _opening = false;
  @override
  void initState() {
    super.initState();
    widget.controller.load();
    widget.notices?.refreshCount();
  }

  Future<void> _openDraft() async {
    if (_opening) return;
    _opening = true;
    try {
      await Navigator.pushNamed(context, '/request');
    } finally {
      _opening = false;
      if (mounted) await widget.controller.load();
    }
  }

  @override
  void dispose() {
    widget.notices?.dispose();
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([widget.controller, widget.notices]),
    builder: (context, _) => HomeScreen(
      showFooter: true,
      onSignOut: widget.onSignOut,
      onRequest: _openDraft,
      noticeAction: NoticeBell(
        unread: widget.notices?.unread,
        onPressed: () async {
          await Navigator.pushNamed(context, '/notifications');
          if (mounted) await widget.notices?.refreshCount();
        },
      ),
      secondaryContent: DraftOverviewCard(
        overview: widget.controller.overview,
        loading: widget.controller.status == DraftOverviewStatus.loading,
        failed: widget.controller.status == DraftOverviewStatus.failed,
        onOpen: _openDraft,
        onRefresh: widget.controller.load,
      ),
    ),
  );
}
