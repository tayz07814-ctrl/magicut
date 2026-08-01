class EditingSession {
  final String videoPath;
  final List<TimeRange> keptSegments;
  final List<TimeRange> removedSegments;
  final bool autoRemoveSilence;
  final bool removeFillerWords;

  EditingSession({
    required this.videoPath,
    List<TimeRange>? keptSegments,
    List<TimeRange>? removedSegments,
    this.autoRemoveSilence = true,
    this.removeFillerWords = false,
  })  : keptSegments = keptSegments ?? [],
        removedSegments = removedSegments ?? [];

  EditingSession copyWith({
    String? videoPath,
    List<TimeRange>? keptSegments,
    List<TimeRange>? removedSegments,
    bool? autoRemoveSilence,
    bool? removeFillerWords,
  }) {
    return EditingSession(
      videoPath: videoPath ?? this.videoPath,
      keptSegments: keptSegments ?? this.keptSegments,
      removedSegments: removedSegments ?? this.removedSegments,
      autoRemoveSilence: autoRemoveSilence ?? this.autoRemoveSilence,
      removeFillerWords: removeFillerWords ?? this.removeFillerWords,
    );
  }
}

class TimeRange {
  final double start;
  final double end;

  TimeRange({
    required this.start,
    required this.end,
  });

  double get duration => end - start;

  TimeRange copyWith({double? start, double? end}) {
    return TimeRange(
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  @override
  String toString() => 'TimeRange($start - $end)';
}
