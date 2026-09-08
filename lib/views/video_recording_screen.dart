import 'package:flutter/material.dart';
import '../controllers/video_capture_controller.dart';
import '../domain/video_capture.dart';
import '../core/localization.dart';
import '../widgets/responsive_content.dart';

class VideoRecordingScreen extends StatefulWidget {
  const VideoRecordingScreen({
    super.key,
    required this.controller,
    required this.preview,
  });
  final VideoCaptureController controller;
  final WidgetBuilder preview;
  @override
  State<VideoRecordingScreen> createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ([
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.detached,
    ].contains(state)) {
      widget.controller.interrupt();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    final controller = widget.controller;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) controller.interrupt(notify: false);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(text.recordVideoTitle)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ResponsiveContent(
              maxWidth: 720,
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(text.recordVideoPrivacy),
                    const SizedBox(height: 16),
                    if (controller.phase != VideoCapturePhase.idle)
                      AspectRatio(
                        aspectRatio: 4 / 3,
                        child: widget.preview(context),
                      ),
                    const SizedBox(height: 12),
                    if ([
                      VideoCapturePhase.preparing,
                      VideoCapturePhase.finishing,
                    ].contains(controller.phase))
                      const LinearProgressIndicator(),
                    if (controller.phase == VideoCapturePhase.preparing)
                      Text(text.recordVideoPreparing),
                    if (controller.phase == VideoCapturePhase.finishing)
                      Text(text.recordVideoFinishing),
                    if (controller.issue != null)
                      Text(
                        switch (controller.issue!) {
                          VideoCaptureIssue.unsupported =>
                            text.recordVideoUnsupported,
                          VideoCaptureIssue.permission =>
                            text.recordVideoPermission,
                          VideoCaptureIssue.invalid => text.videoInvalid,
                          VideoCaptureIssue.interrupted =>
                            text.recordVideoInterrupted,
                          VideoCaptureIssue.unavailable =>
                            text.recordVideoFailed,
                        },
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    if (controller.phase == VideoCapturePhase.idle ||
                        (controller.phase == VideoCapturePhase.failed &&
                            controller.issue != VideoCaptureIssue.interrupted))
                      FilledButton(
                        onPressed: controller.prepare,
                        child: Text(text.recordVideoEnable),
                      ),
                    if (controller.phase == VideoCapturePhase.ready) ...[
                      Text(text.recordVideoReady),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: controller.start,
                        icon: const Icon(Icons.fiber_manual_record),
                        label: Text(text.recordVideoStart),
                      ),
                    ],
                    if (controller.phase == VideoCapturePhase.recording) ...[
                      Text(
                        text.recordVideoTimer(controller.seconds),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: controller.stop,
                        icon: const Icon(Icons.stop),
                        label: Text(text.recordVideoStop),
                      ),
                    ],
                    if (controller.phase == VideoCapturePhase.review) ...[
                      Text(text.recordVideoReview),
                      Text(
                        text.videoDurationLabel(
                          (controller.video!.duration!.inMilliseconds / 1000)
                              .ceil(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () =>
                            Navigator.pop(context, controller.video),
                        child: Text(text.recordVideoUse),
                      ),
                      TextButton(
                        onPressed: controller.prepare,
                        child: Text(text.recordVideoAgain),
                      ),
                    ],
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(text.recordVideoCancel),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
