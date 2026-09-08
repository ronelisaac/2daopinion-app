import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:video_player_web/video_player_web.dart';
import 'package:segunda_opinion_app/domain/repositories/video_capture_repository.dart';
import 'package:segunda_opinion_app/repositories/web_video_capture_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  VideoPlayerPlugin.registerWith(webPluginRegistrar);
  webPluginRegistrar.registerMessageHandler();

  test(
    'MP4 capture, playback metadata, rerecord and cleanup with synthetic canvas only',
    () async {
      final canvas = web.HTMLCanvasElement()
        ..width = 320
        ..height = 240;
      final drawing = canvas.getContext('2d')! as web.CanvasRenderingContext2D;
      var shade = 0;
      final painting = Timer.periodic(const Duration(milliseconds: 40), (_) {
        drawing.fillStyle = 'rgb(${shade++ % 255},0,0)'.toJS;
        drawing.fillRect(0, 0, 320, 240);
      });
      addTearDown(painting.cancel);
      final streams = <web.MediaStream>[];
      final repository = WebVideoCaptureRepository(
        acquireStream: () async {
          final stream = canvas.captureStream(24);
          streams.add(stream);
          return stream;
        },
      );
      addTearDown(repository.dispose);
      final preview = web.HTMLVideoElement();
      repository.attachPreview(preview);
      await repository.prepare();
      final recording = repository.record();
      await Future<void>.delayed(const Duration(seconds: 2));
      repository.stop();
      final video = await recording;
      expect(video.fileName, 'consulta.mp4');
      expect(video.bytes.length, greaterThan(0));
      expect(video.duration!.inMilliseconds, inInclusiveRange(1, 30000));
      expect(
        streams.first.getTracks().toDart.every(
          (track) => track.readyState == 'ended',
        ),
        isTrue,
      );
      expect(preview.controls, isTrue);
      expect(preview.src, startsWith('blob:'));
      await repository.prepare();
      expect(preview.controls, isFalse);
      final repeat = repository.record();
      await Future<void>.delayed(const Duration(seconds: 1));
      repository.stop();
      expect((await repeat).bytes, isNotEmpty);
      repository.dispose();
      expect(
        streams.last.getTracks().toDart.every(
          (track) => track.readyState == 'ended',
        ),
        isTrue,
      );
      expect(preview.getAttribute('src'), isNull);
      expect(preview.srcObject, isNull);
    },
    timeout: const Timeout(Duration(seconds: 60)),
  );

  test(
    'automatic cutoff produces a valid video without a stop click',
    () async {
      final canvas = web.HTMLCanvasElement()
        ..width = 160
        ..height = 120;
      final drawing = canvas.getContext('2d')! as web.CanvasRenderingContext2D;
      final painting = Timer.periodic(
        const Duration(milliseconds: 100),
        (_) => drawing.fillRect(0, 0, 160, 120),
      );
      addTearDown(painting.cancel);
      final stream = canvas.captureStream(10);
      final repository = WebVideoCaptureRepository(
        acquireStream: () async => stream,
      );
      addTearDown(repository.dispose);
      await repository.prepare();
      final result = await repository.record();
      expect(result.duration!.inMilliseconds, inInclusiveRange(28000, 30000));
      expect(
        stream.getTracks().toDart.every((track) => track.readyState == 'ended'),
        isTrue,
      );
    },
    timeout: const Timeout(Duration(seconds: 60)),
  );

  test(
    'cancel during active capture stops tracks and rejects the pending result',
    () async {
      final canvas = web.HTMLCanvasElement()
        ..width = 16
        ..height = 16;
      final stream = canvas.captureStream(10);
      final repository = WebVideoCaptureRepository(
        acquireStream: () async => stream,
      );
      await repository.prepare();
      final recording = repository.record();
      final failure = expectLater(
        recording,
        throwsA(isA<VideoCaptureFailure>()),
      );
      repository.dispose();
      await failure;
      expect(
        stream.getTracks().toDart.every((track) => track.readyState == 'ended'),
        isTrue,
      );
    },
  );

  test(
    'permission denial and cancellation while awaiting a stream never leak devices',
    () async {
      final denied = WebVideoCaptureRepository(
        acquireStream: () async => throw StateError('Synthetic denial'),
      );
      await expectLater(denied.prepare(), throwsA(isA<VideoCaptureFailure>()));
      denied.dispose();
      final pending = Completer<web.MediaStream>();
      final repository = WebVideoCaptureRepository(
        acquireStream: () => pending.future,
      );
      final preparing = repository.prepare();
      repository.dispose();
      final canvas = web.HTMLCanvasElement()
        ..width = 16
        ..height = 16;
      final stream = canvas.captureStream();
      pending.complete(stream);
      await expectLater(preparing, throwsA(isA<VideoCaptureFailure>()));
      expect(
        stream.getTracks().toDart.every((track) => track.readyState == 'ended'),
        isTrue,
      );
    },
  );
}
