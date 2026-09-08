import '../domain/repositories/video_capture_repository.dart';
import '../domain/pending_document.dart';

class UnsupportedVideoCapture implements VideoCaptureRepository {
  @override
  Future<void> prepare() async =>
      throw const VideoCaptureFailure(VideoCaptureIssue.unsupported);
  @override
  Future<PendingDocument> record() async =>
      throw const VideoCaptureFailure(VideoCaptureIssue.unsupported);
  @override
  void stop() {}
  @override
  void dispose() {}
}
