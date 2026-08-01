import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/repository/export_repository_impl.dart';
import '../../../features/editing/domain/entities/editing_session.dart';
import '../../../features/editing/presentation/providers/editing_providers.dart';

final exportRepositoryProvider = Provider<ExportRepository>(
  (ref) => ExportRepository(),
);

final exportStateProvider = StateNotifierProvider<ExportNotifier, ExportState>(
  (ref) => ExportNotifier(
    ref.watch(exportRepositoryProvider),
    ref.watch(editingSessionProvider.notifier),
  ),
);

enum ExportStatus { idle, preparing, exporting, completed, error, cancelled }

class ExportState {
  final ExportStatus status;
  final String? outputPath;
  final double progress;
  final String? errorMessage;
  final Duration? estimatedTimeRemaining;

  ExportState({
    this.status = ExportStatus.idle,
    this.outputPath,
    this.progress = 0.0,
    this.errorMessage,
    this.estimatedTimeRemaining,
  });

  ExportState copyWith({
    ExportStatus? status,
    String? outputPath,
    double? progress,
    String? errorMessage,
    Duration? estimatedTimeRemaining,
  }) {
    return ExportState(
      status: status ?? this.status,
      outputPath: outputPath ?? this.outputPath,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      estimatedTimeRemaining: estimatedTimeRemaining ?? this.estimatedTimeRemaining,
    );
  }
}

class ExportNotifier extends StateNotifier<ExportState> {
  final ExportRepository _repository;
  final EditingSessionNotifier _editingNotifier;

  ExportNotifier(this._repository, this._editingNotifier) : super(ExportState());

  Future<void> startExport() async {
    final session = _editingNotifier.state.session;
    if (session == null) {
      state = state.copyWith(
        status: ExportStatus.error,
        errorMessage: 'No editing session found',
      );
      return;
    }

    state = state.copyWith(status: ExportStatus.preparing, progress: 0.0);

    try {
      // Get output directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${directory.path}/silentcut_$timestamp.mp4';

      state = state.copyWith(status: ExportStatus.exporting, progress: 0.1);

      // Start export
      final result = await _repository.exportVideo(session, outputPath);

      if (result != null) {
        state = state.copyWith(
          status: ExportStatus.completed,
          outputPath: result,
          progress: 1.0,
        );
      } else {
        state = state.copyWith(
          status: ExportStatus.error,
          errorMessage: 'Export failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: ExportStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> cancelExport() async {
    await _repository.cancelExport();
    state = state.copyWith(status: ExportStatus.cancelled);
  }

  void reset() {
    state = ExportState();
  }
}
