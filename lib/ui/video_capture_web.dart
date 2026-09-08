import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;
import '../repositories/web_video_capture_repository.dart';
import 'video_capture_binding.dart';

VideoCaptureBinding createVideoCapture() {
  final repository = WebVideoCaptureRepository();
  return VideoCaptureBinding(
    repository,
    (_) => HtmlElementView.fromTagName(
      tagName: 'video',
      onElementCreated: (element) =>
          repository.attachPreview(element as web.HTMLVideoElement),
    ),
  );
}
