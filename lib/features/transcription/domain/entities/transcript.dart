class TranscriptWord {
  final String text;
  final double startTime;
  final double endTime;
  final bool isFillerWord;
  final bool isDeleted;

  TranscriptWord({
    required this.text,
    required this.startTime,
    required this.endTime,
    required this.isFillerWord,
    this.isDeleted = false,
  });

  TranscriptWord copyWith({
    String? text,
    double? startTime,
    double? endTime,
    bool? isFillerWord,
    bool? isDeleted,
  }) {
    return TranscriptWord(
      text: text ?? this.text,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isFillerWord: isFillerWord ?? this.isFillerWord,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

class TranscriptSegment {
  final int index;
  final String text;
  final double startTime;
  final double endTime;
  final List<TranscriptWord> words;

  TranscriptSegment({
    required this.index,
    required this.text,
    required this.startTime,
    required this.endTime,
    required this.words,
  });
}

class Transcript {
  final String videoPath;
  final List<TranscriptSegment> segments;
  final Duration totalDuration;

  Transcript({
    required this.videoPath,
    required this.segments,
    required this.totalDuration,
  });

  List<TranscriptWord> get allWords {
    return segments.expand((s) => s.words).toList();
  }
}
