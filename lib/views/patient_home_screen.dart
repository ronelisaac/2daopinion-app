import 'package:flutter/material.dart';
import '../controllers/draft_overview_controller.dart';
import '../widgets/draft_overview_card.dart';
import 'home_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({
    super.key,
    required this.controller,
    required this.onSignOut,
  });
  final DraftOverviewController controller;
  final VoidCallback onSignOut;
  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  bool _opening = false;
  @override
  void initState() {
    super.initState();
    widget.controller.load();
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
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) => HomeScreen(
      showFooter: true,
      onSignOut: widget.onSignOut,
      onRequest: _openDraft,
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
