import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/transcription_repository_impl.dart';
import '../../domain/entities/transcript.dart';

final transcriptionRepositoryProvider = Provider<TranscriptionRepository>(
  (ref) => TranscriptionRepositoryImpl(),
);

final transcriptionStateProvider = StateNotifierProvider<TranscriptionNotifier, TranscriptionState>(
  (ref) => TranscriptionNotifier(ref.watch(transcriptionRepositoryProvider)),
);

enum TranscriptionStatus { idle, loading, processing, completed, error }

class TranscriptionState {
  final TranscriptionStatus status;
  final Transcript? transcript;
  final String? errorMessage;
  final double progress;

  TranscriptionState({
    this.status = TranscriptionStatus.idle,
    this.transcript,
    this.errorMessage,
    this.progress = 0.0,
  });

  TranscriptionState copyWith({
    TranscriptionStatus? status,
    Transcript? transcript,
    String? errorMessage,
    double? progress,
  }) {
    return TranscriptionState(
      status: status ?? this.status,
      transcript: transcript ?? this.transcript,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }
}

class TranscriptionNotifier extends StateNotifier<TranscriptionState> {
  final TranscriptionRepository _repository;

  TranscriptionNotifier(this._repository) : super(TranscriptionState());

  Future<void> transcribe(String videoPath) async {
    state = state.copyWith(status: TranscriptionStatus.loading, progress: 0.0);

    try {
      // Load model
      state = state.copyWith(progress: 0.2);
      final loaded = await _repository.loadModel();
      
      if (!loaded) {
        state = state.copyWith(
          status: TranscriptionStatus.error,
          errorMessage: 'Failed to load transcription model',
        );
        return;
      }

      // Transcribe
      state = state.copyWith(status: TranscriptionStatus.processing, progress: 0.5);
      final transcript = await _repository.transcribe(videoPath);

      if (transcript == null) {
        state = state.copyWith(
          status: TranscriptionStatus.error,
          errorMessage: 'Transcription failed',
        );
        return;
      }

      state = state.copyWith(
        status: TranscriptionStatus.completed,
        transcript: transcript,
        progress: 1.0,
      );
    } catch (e) {
      state = state.copyWith(
        status: TranscriptionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = TranscriptionState();
  }

  void unloadModel() {
    _repository.unloadModel();
  }
}
