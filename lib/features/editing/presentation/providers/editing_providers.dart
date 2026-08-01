import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/editing_session.dart';
import '../../../features/transcription/domain/entities/transcript.dart';
import '../../../core/utils/ffmpeg_helper.dart';

final editingSessionProvider = StateNotifierProvider<EditingSessionNotifier, EditingSessionState>(
  (ref) => EditingSessionNotifier(),
);

class EditingSessionState {
  final EditingSession? session;
  final Transcript? transcript;
  final List<SilenceSegment> detectedSilences;
  final bool isProcessing;
  final double processingProgress;
  final String? outputPath;

  EditingSessionState({
    this.session,
    this.transcript,
    List<SilenceSegment>? detectedSilences,
    this.isProcessing = false,
    this.processingProgress = 0.0,
    this.outputPath,
  }) : detectedSilences = detectedSilences ?? [];

  EditingSessionState copyWith({
    EditingSession? session,
    Transcript? transcript,
    List<SilenceSegment>? detectedSilences,
    bool? isProcessing,
    double? processingProgress,
    String? outputPath,
  }) {
    return EditingSessionState(
      session: session ?? this.session,
      transcript: transcript ?? this.transcript,
      detectedSilences: detectedSilences ?? this.detectedSilences,
      isProcessing: isProcessing ?? this.isProcessing,
      processingProgress: processingProgress ?? this.processingProgress,
      outputPath: outputPath ?? this.outputPath,
    );
  }
}

class EditingSessionNotifier extends StateNotifier<EditingSessionState> {
  EditingSessionNotifier() : super(EditingSessionState());

  void startSession(String videoPath) {
    state = state.copyWith(
      session: EditingSession(videoPath: videoPath),
    );
  }

  void setTranscript(Transcript transcript) {
    state = state.copyWith(transcript: transcript);
  }

  void toggleWordSelection(TranscriptWord word) {
    // Toggle word deletion state
    final updatedWords = transcript?.segments
        .expand((s) => s.words)
        .map((w) => w == word ? word.copyWith(isDeleted: !word.isDeleted) : w)
        .toList();
    
    // Update segments based on deleted words
    _updateSegmentsFromWords(updatedWords);
  }

  void _updateSegmentsFromWords(List<TranscriptWord> words) {
    if (state.transcript == null) return;

    final keptRanges = <TimeRange>[];
    double? rangeStart;

    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      if (!word.isDeleted) {
        if (rangeStart == null) {
          rangeStart = word.startTime;
        }
        if (i == words.length - 1 || words[i + 1].isDeleted) {
          keptRanges.add(TimeRange(start: rangeStart!, end: word.endTime));
          rangeStart = null;
        }
      }
    }

    if (state.session != null) {
      state = state.copyWith(
        session: state.session!.copyWith(keptSegments: keptRanges),
      );
    }
  }

  void toggleAutoRemoveSilence(bool value) {
    if (state.session != null) {
      state = state.copyWith(
        session: state.session!.copyWith(autoRemoveSilence: value),
      );
    }
  }

  Future<void> detectSilence() async {
    if (state.session?.videoPath == null) return;

    final silences = await FFmpegHelper.detectSilence(state.session!.videoPath);
    state = state.copyWith(detectedSilences: silences);
  }

  void addManualCut(double time) {
    // Add a manual cut point at the specified time
    if (state.session == null) return;

    final currentKept = state.session!.keptSegments;
    // Logic to split or merge segments based on cut point
    // Simplified implementation
    state = state.copyWith(
      session: state.session!.copyWith(keptSegments: currentKept),
    );
  }

  void removeSegment(int index) {
    if (state.session == null || index >= state.session!.keptSegments.length) return;

    final updated = [...state.session!.keptSegments]..removeAt(index);
    state = state.copyWith(
      session: state.session!.copyWith(keptSegments: updated),
    );
  }

  void clearSession() {
    state = EditingSessionState();
  }
}
