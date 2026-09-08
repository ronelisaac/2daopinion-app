import '../pending_document.dart';

export '../video_capture.dart';

abstract interface class VideoCaptureRepository {
  Future<void> prepare();
  Future<PendingDocument> record();
  void stop();
  void dispose();
}
