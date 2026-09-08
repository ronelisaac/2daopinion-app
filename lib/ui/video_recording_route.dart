import 'package:flutter/material.dart';
import '../controllers/video_capture_controller.dart';
import '../views/video_recording_screen.dart';
import 'video_capture_binding.dart';
import 'video_capture_stub.dart'
    if (dart.library.js_interop) 'video_capture_web.dart'
    as platform;

class VideoRecordingRoute extends StatefulWidget {
  const VideoRecordingRoute({super.key});
  @override
  State<VideoRecordingRoute> createState() => _VideoRecordingRouteState();
}

class _VideoRecordingRouteState extends State<VideoRecordingRoute> {
  late final VideoCaptureBinding binding = platform.createVideoCapture();
  late final VideoCaptureController controller = VideoCaptureController(
    binding.repository,
  );
  @override
  Widget build(BuildContext context) =>
      VideoRecordingScreen(controller: controller, preview: binding.preview);
}
