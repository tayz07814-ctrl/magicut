import 'package:file_picker/file_picker.dart';
import '../../domain/entities/video_file.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';

abstract class VideoPickerRepository {
  Future<List<VideoFile>> pickVideos();
  Future<VideoFile?> getVideoInfo(String path);
}

class VideoPickerRepositoryImpl implements VideoPickerRepository {
  @override
  Future<List<VideoFile>> pickVideos() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      final videos = <VideoFile>[];
      for (final file in result.files) {
        if (file.path != null) {
          final videoFile = VideoFile(
            path: file.path!,
            name: file.name,
            durationMs: 0, // Will be populated later
            width: file.width ?? 0,
            height: file.height ?? 0,
            createdAt: DateTime.now(),
          );
          videos.add(videoFile);
        }
      }

      AppLogger.i('Picked ${videos.length} videos');
      return videos;
    } catch (e) {
      AppLogger.e('Error picking videos', e);
      return [];
    }
  }

  @override
  Future<VideoFile?> getVideoInfo(String path) async {
    try {
      // Video info will be populated using FFmpeg
      return null;
    } catch (e) {
      AppLogger.e('Error getting video info', e);
      return null;
    }
  }
}
