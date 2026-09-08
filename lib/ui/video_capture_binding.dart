import 'package:flutter/widgets.dart';
import '../domain/repositories/video_capture_repository.dart';

class VideoCaptureBinding {
  const VideoCaptureBinding(this.repository, this.preview);
  final VideoCaptureRepository repository;
  final WidgetBuilder preview;
}
