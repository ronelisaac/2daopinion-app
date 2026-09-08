import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/attachment_policy.dart';
import '../domain/form_limits.dart';
import '../domain/pending_document.dart';
import '../domain/repositories/video_capture_repository.dart';

enum VideoCapturePhase {
  idle,
  preparing,
  ready,
  recording,
  finishing,
  review,
  failed,
}

class VideoCaptureController extends ChangeNotifier {
  VideoCaptureController(this._repository);
  final VideoCaptureRepository _repository;
  VideoCapturePhase phase = VideoCapturePhase.idle;
  VideoCaptureIssue? issue;
  PendingDocument? video;
  int seconds = 0;
  Timer? _timer;
  Timer? _deadline;
  bool _interrupted = false;
  final Stopwatch _watch = Stopwatch();
  bool _disposed = false;

  void _fail(Object error) {
    issue = error is VideoCaptureFailure
        ? error.issue
        : VideoCaptureIssue.unavailable;
    phase = VideoCapturePhase.failed;
  }

  Future<void> prepare() async {
    if (_disposed ||
        _interrupted ||
        ![
          VideoCapturePhase.idle,
          VideoCapturePhase.review,
          VideoCapturePhase.failed,
        ].contains(phase)) {
      return;
    }
    video = null;
    issue = null;
    seconds = 0;
    phase = VideoCapturePhase.preparing;
    notifyListeners();
    try {
      await _repository.prepare();
      if (!_disposed && !_interrupted) phase = VideoCapturePhase.ready;
    } catch (error) {
      if (!_disposed && !_interrupted) _fail(error);
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> start() async {
    if (_disposed || phase != VideoCapturePhase.ready) return;
    phase = VideoCapturePhase.recording;
    _watch.reset();
    _watch.start();
    _deadline = Timer(FormLimits.videoDuration, stop);
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      seconds = _watch.elapsed.inSeconds;
      if (_watch.elapsed >= FormLimits.videoDuration) stop();
      if (!_disposed) notifyListeners();
    });
    notifyListeners();
    try {
      final captured = await _repository.record();
      if (_disposed || _interrupted) return;
      if (!captured.isVideo ||
          !AttachmentPolicy.valid(
            captured.fileName,
            captured.bytes.length,
            captured.duration,
          )) {
        throw const VideoCaptureFailure(VideoCaptureIssue.invalid);
      }
      video = captured;
      phase = VideoCapturePhase.review;
    } catch (error) {
      if (!_disposed && !_interrupted) _fail(error);
    } finally {
      _timer?.cancel();
      _deadline?.cancel();
      _watch.stop();
      if (!_disposed) notifyListeners();
    }
  }

  void stop() {
    if (_disposed || phase != VideoCapturePhase.recording) return;
    phase = VideoCapturePhase.finishing;
    _timer?.cancel();
    _deadline?.cancel();
    _repository.stop();
    notifyListeners();
  }

  void interrupt({bool notify = true}) {
    if (_disposed) return;
    _interrupted = true;
    _timer?.cancel();
    _deadline?.cancel();
    _repository.dispose();
    video = null;
    issue = VideoCaptureIssue.interrupted;
    phase = VideoCapturePhase.failed;
    if (notify) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _deadline?.cancel();
    _watch.stop();
    video = null;
    _repository.dispose();
    super.dispose();
  }
}
