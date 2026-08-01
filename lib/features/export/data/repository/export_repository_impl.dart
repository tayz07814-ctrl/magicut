import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import '../../../core/utils/logger.dart';
import '../../domain/entities/editing_session.dart';

class ExportRepository {
  Future<String?> exportVideo(EditingSession session, String outputPath) async {
    try {
      if (session.keptSegments.isEmpty) {
        // No segments to keep, return null
        return null;
      }

      if (session.keptSegments.length == 1 && 
          !session.autoRemoveSilence &&
          session.removedSegments.isEmpty) {
        // Single segment, no modifications needed - just copy
        final command = '-i "${session.videoPath}" -c copy "$outputPath"';
        final result = await FFmpegKit.execute(command);
        
        if (ReturnCode.isSuccess(await result.getReturnCode())) {
          AppLogger.i('Video exported successfully');
          return outputPath;
        } else {
          AppLogger.e('Export failed: ${await result.getFailStackTrace()}');
          return null;
        }
      }

      // Build concat filter for multiple segments
      final filterParts = <String>[];
      var outputIndex = 0;

      for (final segment in session.keptSegments) {
        filterParts.add(
          '[0:v]trim=start=${segment.start}:end=${segment.end},setpts=PTS-STARTPTS[v$outputIndex];'
          '[0:a]atrim=start=${segment.start}:end=${segment.end},asetpts=PTS-STARTPTS[a$outputIndex]'
        );
        outputIndex++;
      }

      // Concatenate all segments
      var concatInputs = '';
      for (var i = 0; i < outputIndex; i++) {
        concatInputs += '[v$i][a$i]';
      }
      
      final concatFilter = '${filterParts.join('')}${concatInputs}concat=n=$outputIndex:v=1:a=1[outv][outa]';

      final command = '-i "${session.videoPath}" -filter_complex "$concatFilter" -map "[outv]" -map "[outa]" "$outputPath"';
      
      AppLogger.d('Export command: $command');
      
      final result = await FFmpegKit.execute(command);
      
      if (ReturnCode.isSuccess(await result.getReturnCode())) {
        AppLogger.i('Video exported with edits successfully');
        return outputPath;
      } else {
        AppLogger.e('Export failed: ${await result.getFailStackTrace()}');
        return null;
      }
    } catch (e) {
      AppLogger.e('Error exporting video', e);
      return null;
    }
  }

  Future<bool> cancelExport() async {
    await FFmpegKit.cancel();
    AppLogger.i('Export cancelled');
    return true;
  }
}
