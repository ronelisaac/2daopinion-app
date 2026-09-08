import 'package:flutter/material.dart';
import '../repositories/unsupported_video_capture_repository.dart';
import 'video_capture_binding.dart';

VideoCaptureBinding createVideoCapture() => VideoCaptureBinding(
  UnsupportedVideoCapture(),
  (_) => const Center(child: Icon(Icons.videocam_off_outlined)),
);
