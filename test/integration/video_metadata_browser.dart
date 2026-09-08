import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:file_selector/file_selector.dart';
import 'package:video_player_web/video_player_web.dart';
import 'package:http/http.dart' as http;
import 'package:segunda_opinion_app/domain/pending_document.dart';
import 'package:segunda_opinion_app/repositories/local_document_selection_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  VideoPlayerPlugin.registerWith(webPluginRegistrar);
  webPluginRegistrar.registerMessageHandler();
  test(
    'browser decodes a real short video and rejects an overlong or unreadable video',
    () async {
      const base = String.fromEnvironment(
        'VIDEO_FIXTURE_BASE',
        defaultValue: 'http://127.0.0.1:8773',
      );
      expect(Uri.parse(base).host, isIn(['127.0.0.1', 'localhost']));
      for (final seconds in [2, 31]) {
        final response = await http.get(
          Uri.parse('$base/2daopinion-qa-video-${seconds}s.mp4'),
        );
        expect(response.statusCode, 200);
        final repository = LocalDocumentSelectionRepository(
          picker: (_) async => [
            XFile.fromData(
              response.bodyBytes,
              name: 'ficticio.mp4',
              mimeType: 'video/mp4',
            ),
          ],
        );
        final selecting = repository.select(
          maxFiles: 1,
          maxTotalBytes: 20971520,
          video: true,
        );
        if (seconds == 2) {
          final result = await selecting;
          expect(
            result.single.duration!.inMilliseconds,
            inInclusiveRange(1500, 2500),
          );
        } else {
          await expectLater(
            selecting,
            throwsA(
              isA<DocumentSelectionFailure>().having(
                (error) => error.issue,
                'issue',
                DocumentSelectionIssue.videoInvalid,
              ),
            ),
          );
        }
      }
      final invalid = LocalDocumentSelectionRepository(
        picker: (_) async => [
          XFile.fromData(
            Uint8List(8),
            name: 'invalid.mp4',
            mimeType: 'video/mp4',
          ),
        ],
      );
      await expectLater(
        invalid.select(maxFiles: 1, maxTotalBytes: 100, video: true),
        throwsA(isA<DocumentSelectionFailure>()),
      );
    },
    timeout: const Timeout(Duration(minutes: 1)),
  );
}
