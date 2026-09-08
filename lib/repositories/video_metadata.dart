import 'video_source_web.dart'
    if (dart.library.io) 'video_source_native.dart'
    as source;

Future<Duration> readVideoDuration(String path) async {
  final controller = source.localVideoController(path);
  try {
    await controller.initialize().timeout(const Duration(seconds: 20));
    if (controller.value.hasError) throw StateError('Invalid video');
    return controller.value.duration;
  } finally {
    await controller.dispose();
  }
}

void releaseLocalFile(String path) => source.releaseLocalFile(path);
