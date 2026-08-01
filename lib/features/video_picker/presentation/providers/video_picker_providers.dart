import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/video_picker_repository_impl.dart';
import '../../domain/entities/video_file.dart';

final videoPickerRepositoryProvider = Provider<VideoPickerRepository>(
  (ref) => VideoPickerRepositoryImpl(),
);

final pickedVideosProvider = StateNotifierProvider<PickedVideosNotifier, List<VideoFile>>(
  (ref) => PickedVideosNotifier(ref.watch(videoPickerRepositoryProvider)),
);

class PickedVideosNotifier extends StateNotifier<List<VideoFile>> {
  final VideoPickerRepository _repository;

  PickedVideosNotifier(this._repository) : super([]);

  Future<void> pickVideos() async {
    final videos = await _repository.pickVideos();
    state = [...state, ...videos];
  }

  void removeVideo(int index) {
    if (index >= 0 && index < state.length) {
      state = [...state]..removeAt(index);
    }
  }

  void clearVideos() {
    state = [];
  }

  void selectVideo(VideoFile video) {
    // Handle video selection for editing
  }
}
