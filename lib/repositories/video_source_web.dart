import 'package:video_player/video_player.dart';
import 'package:web/web.dart' as web;

VideoPlayerController localVideoController(String path) {
  final uri = Uri.parse(path);
  if (uri.scheme != 'blob') throw StateError('Local video required');
  return VideoPlayerController.networkUrl(uri);
}

void releaseLocalFile(String path) {
  if (Uri.parse(path).scheme == 'blob') web.URL.revokeObjectURL(path);
}
