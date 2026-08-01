class VideoFile {
  final String path;
  final String name;
  final int durationMs;
  final int width;
  final int height;
  final DateTime createdAt;

  VideoFile({
    required this.path,
    required this.name,
    required this.durationMs,
    required this.width,
    required this.height,
    required this.createdAt,
  });

  String get formattedDuration {
    final seconds = durationMs ~/ 1000;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  String toString() => 'VideoFile(name: $name, duration: $formattedDuration)';
}
