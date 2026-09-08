import 'package:flutter/material.dart';

import '../controllers/bootstrap_controller.dart';
import 'loading_screen.dart';
import 'welcome_screen.dart';

class BootstrapView extends StatefulWidget {
  const BootstrapView({super.key, required this.initialize});
  final Future<void> Function() initialize;

  @override
  State<BootstrapView> createState() => _BootstrapViewState();
}

class _BootstrapViewState extends State<BootstrapView> {
  late final BootstrapController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BootstrapController(widget.initialize);
    _controller.start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _controller,
    builder: (context, child) => switch (_controller.status) {
      BootstrapStatus.ready => const WelcomeScreen(),
      BootstrapStatus.failed => LoadingScreen(
        failed: true,
        onRetry: _controller.start,
      ),
      BootstrapStatus.idle || BootstrapStatus.loading => const LoadingScreen(),
    },
  );
}
