import 'form_limits.dart';

class AttachmentPolicy {
  static const documentExtensions = ['jpg', 'jpeg', 'png', 'doc', 'xls', 'pdf'];
  static const videoExtensions = ['mp4', 'mov'];
  static String extension(String name) =>
      name.lastIndexOf('.') > 0 ? name.split('.').last.toLowerCase() : '';
  static bool isVideo(String name) => videoExtensions.contains(extension(name));
  static String? mimeType(String name) => switch (extension(name)) {
    'jpg' || 'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'doc' => 'application/msword',
    'xls' => 'application/vnd.ms-excel',
    'pdf' => 'application/pdf',
    'mp4' => 'video/mp4',
    'mov' => 'video/quicktime',
    _ => null,
  };
  static bool valid(String name, int size, Duration? duration) {
    if (name.length > 255 || mimeType(name) == null || size <= 0) return false;
    if (isVideo(name)) {
      return size <= FormLimits.videoBytes &&
          duration != null &&
          duration.inMilliseconds >= 1 &&
          duration <= FormLimits.videoDuration;
    }
    return duration == null && size <= FormLimits.documentBytes;
  }
}
