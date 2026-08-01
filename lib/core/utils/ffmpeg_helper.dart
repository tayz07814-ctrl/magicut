import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import '../core/utils/logger.dart';

class FFmpegHelper {
  /// Detect silence in video using FFmpeg silencedetect filter
  static Future<List<SilenceSegment>> detectSilence(
    String videoPath, {
    double thresholdDb = -50.0,
    int minDurationMs = 500,
  }) async {
    try {
      final durationResult = await _getVideoDuration(videoPath);
      final totalDuration = durationResult.$1;
      
      final silences = <SilenceSegment>[];
      final silenceStarts = <double>[];
      
      // Use silencedetect filter to find silent segments
      final command = '-i "$videoPath" -af silencedetect=noise=${thresholdDb}dB:d=${minDurationMs / 1000.0} -f null -';
      
      await FFmpegKit.execute(command).then((session) async {
        final logs = await session.getLogs();
        for (final log in logs) {
          final message = log.getMessage();
          if (message.contains('silence_start')) {
            final start = _parseTimestamp(message, 'silence_start: ');
            if (start != null) silenceStarts.add(start);
          } else if (message.contains('silence_end')) {
            final end = _parseTimestamp(message, 'silence_end: ');
            final duration = _parseDuration(message, 'duration: ');
            if (end != null && silenceStarts.isNotEmpty) {
              silences.add(SilenceSegment(
                start: silenceStarts.removeLast(),
                end: end,
                duration: duration ?? 0,
              ));
            }
          }
        }
      });
      
      AppLogger.i('Detected ${silences.length} silence segments');
      return silences;
    } catch (e) {
      AppLogger.e('Error detecting silence', e);
      return [];
    }
  }

  /// Get video duration in seconds
  static Future<(double, int)> _getVideoDuration(String videoPath) async {
    double duration = 0;
    int width = 0;
    
    final command = '-i "$videoPath"';
    await FFmpegKit.execute(command).then((session) {
      final logs = session.getLogs();
      for (final log in logs) {
        final message = log.getMessage();
        if (message.contains('Duration:')) {
          final match = RegExp(r'Duration: (\d+):(\d+):(\d+)\.(\d+)').firstMatch(message);
          if (match != null) {
            final hours = int.parse(match.group(1)!);
            final minutes = int.parse(match.group(2)!);
            final seconds = int.parse(match.group(3)!);
            final milliseconds = int.parse(match.group(4)!);
            duration = hours * 3600 + minutes * 60 + seconds + milliseconds / 1000;
          }
        }
        if (message.contains('Stream #') && message.contains('Video:')) {
          final match = RegExp(r'(\d+)x(\d+)').firstMatch(message);
          if (match != null) {
            width = int.parse(match.group(1)!);
          }
        }
      }
    });
    
    return (duration, width);
  }

  static double? _parseTimestamp(String message, String prefix) {
    try {
      final index = message.indexOf(prefix);
      if (index == -1) return null;
      final start = index + prefix.length;
      final end = message.indexOf('\n', start);
      final value = message.substring(start, end == -1 ? message.length : end).trim();
      return double.tryParse(value);
    } catch (e) {
      return null;
    }
  }

  static double? _parseDuration(String message, String prefix) {
    try {
      final index = message.indexOf(prefix);
      if (index == -1) return null;
      final start = index + prefix.length;
      final end = message.indexOf(' ', start);
      final value = message.substring(start, end == -1 ? message.length : end).trim();
      return double.tryParse(value);
    } catch (e) {
      return null;
    }
  }

  /// Remove silence segments from video
  static Future<String?> removeSilence(
    String inputPath,
    String outputPath,
    List<SilenceSegment> silences,
  ) async {
    try {
      if (silences.isEmpty) {
        // No silence to remove, just copy
        final command = '-i "$inputPath" -c copy "$outputPath"';
        final session = await FFmpegKit.execute(command);
        
        if (ReturnCode.isSuccess(await session.getReturnCode())) {
          AppLogger.i('Video copied successfully');
          return outputPath;
        }
        return null;
      }

      // Build complex filter to remove silence segments
      final filterParts = <String>[];
      var currentIndex = 0;
      
      for (var i = 0; i < silences.length; i++) {
        final silence = silences[i];
        if (silence.start > currentIndex) {
          filterParts.add('[$currentIndex:${silence.start}]v${filterParts.length},a${filterParts.length}');
        }
        currentIndex = silence.end;
      }
      
      // Add remaining part after last silence
      final durationResult = await _getVideoDuration(inputPath);
      if (currentIndex < durationResult.$1) {
        filterParts.add('[$currentIndex:${durationResult.$1}]v${filterParts.length},a${filterParts.length}');
      }
      
      // Concatenate all kept segments
      final concatInputs = filterParts.length;
      var concatFilter = '';
      for (var i = 0; i < concatInputs; i++) {
        concatFilter += '[v$i][a$i]';
      }
      concatFilter += 'concat=n=$concatInputs:v=1:a=1[outv][outa]';
      
      final command = '-i "$inputPath" -filter_complex "$concatFilter" -map "[outv]" -map "[outa]" "$outputPath"';
      
      final session = await FFmpegKit.execute(command);
      
      if (ReturnCode.isSuccess(await session.getReturnCode())) {
        AppLogger.i('Silence removed successfully');
        return outputPath;
      } else {
        AppLogger.e('Failed to remove silence: ${await session.getFailStackTrace()}');
        return null;
      }
    } catch (e) {
      AppLogger.e('Error removing silence', e);
      return null;
    }
  }
}

class SilenceSegment {
  final double start;
  final double end;
  final double duration;

  SilenceSegment({
    required this.start,
    required this.end,
    required this.duration,
  });

  @override
  String toString() => 'SilenceSegment(start: $start, end: $end, duration: $duration)';
}
