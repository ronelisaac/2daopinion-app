import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import '../domain/attachment_policy.dart';
import '../domain/form_limits.dart';
import '../domain/pending_document.dart';
import '../domain/repositories/video_capture_repository.dart';
import 'video_metadata.dart';

class WebVideoCaptureRepository implements VideoCaptureRepository {
  WebVideoCaptureRepository({Future<web.MediaStream> Function()? acquireStream})
    : _acquireStream = acquireStream ?? _camera;
  final Future<web.MediaStream> Function() _acquireStream;

  static Future<web.MediaStream> _camera() => web.window.navigator.mediaDevices
      .getUserMedia(
        web.MediaStreamConstraints(
          video: web.MediaTrackConstraints(
            width: 640.toJS,
            height: 480.toJS,
            frameRate: 24.toJS,
            facingMode: 'user'.toJS,
          ),
          audio: true.toJS,
        ),
      )
      .toDart;
  web.MediaStream? _stream;
  web.MediaRecorder? _recorder;
  web.HTMLVideoElement? _preview;
  final List<web.Blob> _chunks = [];
  Completer<PendingDocument>? _result;
  Timer? _cutoff;
  String? _url;
  String? _mime;
  int _generation = 0;
  int _bytes = 0;
  bool _disposed = false;

  void attachPreview(web.HTMLVideoElement element) {
    _preview = element;
    element.style.width = '100%';
    element.style.height = '100%';
    element.style.objectFit = 'contain';
    element.playsInline = true;
    _updatePreview();
  }

  void _updatePreview() {
    final preview = _preview;
    if (preview == null) return;
    preview.pause();
    preview.srcObject = null;
    preview.removeAttribute('src');
    preview.controls = _url != null;
    preview.muted = _url == null;
    preview.autoplay = _stream != null;
    if (_url != null) {
      preview.src = _url!;
      preview.load();
    } else if (_stream != null) {
      preview.srcObject = _stream;
      unawaited(
        preview.play().toDart.then<void>((_) {}, onError: (Object _) {}),
      );
    }
  }

  void _stopTracks() {
    for (final track
        in _stream?.getTracks().toDart ?? <web.MediaStreamTrack>[]) {
      track.stop();
    }
    _stream = null;
  }

  void _release() {
    _generation++;
    _cutoff?.cancel();
    final recorder = _recorder;
    _recorder = null;
    if (recorder != null) {
      recorder.ondataavailable = null;
      recorder.onstop = null;
      recorder.onerror = null;
      if (recorder.state != 'inactive') recorder.stop();
    }
    _stopTracks();
    if (_url != null) web.URL.revokeObjectURL(_url!);
    _url = null;
    _chunks.clear();
    _bytes = 0;
    final result = _result;
    _result = null;
    if (result != null && !result.isCompleted) {
      result.completeError(
        const VideoCaptureFailure(VideoCaptureIssue.interrupted),
      );
    }
    _updatePreview();
  }

  @override
  Future<void> prepare() async {
    if (_disposed) {
      throw const VideoCaptureFailure(VideoCaptureIssue.interrupted);
    }
    _release();
    final generation = _generation;
    try {
      if (!web.window.isSecureContext) {
        throw const VideoCaptureFailure(VideoCaptureIssue.unsupported);
      }
      _mime = null;
      for (final candidate in [
        'video/mp4;codecs=avc1,mp4a.40.2',
        'video/mp4',
      ]) {
        if (web.MediaRecorder.isTypeSupported(candidate)) {
          _mime = candidate;
          break;
        }
      }
      if (_mime == null) {
        throw const VideoCaptureFailure(VideoCaptureIssue.unsupported);
      }
      final stream = await _acquireStream();
      if (_disposed || generation != _generation) {
        for (final track in stream.getTracks().toDart) {
          track.stop();
        }
        throw const VideoCaptureFailure(VideoCaptureIssue.interrupted);
      }
      _stream = stream;
      _updatePreview();
    } on VideoCaptureFailure {
      rethrow;
    } catch (_) {
      _stopTracks();
      throw const VideoCaptureFailure(VideoCaptureIssue.permission);
    }
  }

  @override
  Future<PendingDocument> record() async {
    if (_disposed || _stream == null || _mime == null) {
      throw const VideoCaptureFailure(VideoCaptureIssue.unavailable);
    }
    final generation = _generation;
    final result = Completer<PendingDocument>();
    _result = result;
    try {
      final recorder = web.MediaRecorder(
        _stream!,
        web.MediaRecorderOptions(
          mimeType: _mime!,
          videoBitsPerSecond: 1500000,
          audioBitsPerSecond: 64000,
        ),
      );
      _recorder = recorder;
      recorder.ondataavailable = ((web.BlobEvent event) {
        if (_disposed || generation != _generation || result.isCompleted) {
          return;
        }
        _bytes += event.data.size;
        if (_bytes > FormLimits.videoBytes) {
          result.completeError(
            const VideoCaptureFailure(VideoCaptureIssue.invalid),
          );
          _release();
          return;
        }
        if (event.data.size > 0) _chunks.add(event.data);
      }).toJS;
      recorder.onerror = ((web.Event event) {
        if (!result.isCompleted) {
          result.completeError(
            const VideoCaptureFailure(VideoCaptureIssue.unavailable),
          );
        }
        _release();
      }).toJS;
      recorder.onstop = ((web.Event event) {
        _cutoff?.cancel();
        _stopTracks();
        unawaited(_finish(result, generation));
      }).toJS;
      recorder.start(250);
      _cutoff = Timer(const Duration(milliseconds: 29500), stop);
    } catch (_) {
      if (!result.isCompleted) {
        result.completeError(
          const VideoCaptureFailure(VideoCaptureIssue.unavailable),
        );
      }
      _release();
    }
    return result.future;
  }

  Future<void> _finish(
    Completer<PendingDocument> result,
    int generation,
  ) async {
    try {
      if (_disposed || generation != _generation || result.isCompleted) return;
      final blob = web.Blob(
        _chunks.toJS,
        web.BlobPropertyBag(type: 'video/mp4'),
      );
      _url = web.URL.createObjectURL(blob);
      final duration = await readVideoDuration(_url!);
      if (_disposed || generation != _generation || result.isCompleted) return;
      final bytes = (await blob.arrayBuffer().toDart).toDart.asUint8List();
      if (_disposed || generation != _generation || result.isCompleted) return;
      if (!AttachmentPolicy.valid('consulta.mp4', bytes.length, duration)) {
        throw const VideoCaptureFailure(VideoCaptureIssue.invalid);
      }
      _chunks.clear();
      _updatePreview();
      result.complete(
        PendingDocument(
          title: 'consulta.mp4',
          fileName: 'consulta.mp4',
          bytes: bytes,
          duration: duration,
        ),
      );
    } catch (_) {
      if (_disposed || generation != _generation) return;
      if (!result.isCompleted) {
        result.completeError(
          const VideoCaptureFailure(VideoCaptureIssue.invalid),
        );
      }
      _release();
    }
  }

  @override
  void stop() {
    _cutoff?.cancel();
    final recorder = _recorder;
    if (recorder != null && recorder.state != 'inactive') recorder.stop();
    _stopTracks();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _release();
    _preview = null;
  }
}
