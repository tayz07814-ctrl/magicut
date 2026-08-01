import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/video_file.dart';
import '../providers/video_picker_providers.dart';
import '../../../core/constants/app_constants.dart';

class VideoPickerScreen extends ConsumerWidget {
  const VideoPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videos = ref.watch(pickedVideosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SilentCut'),
        actions: [
          if (videos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () => ref.read(pickedVideosProvider.notifier).clearVideos(),
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: videos.isEmpty
          ? _buildEmptyState(context, ref)
          : _buildVideoList(context, ref, videos),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ref.read(pickedVideosProvider.notifier).pickVideos(),
        icon: const Icon(Icons.video_library),
        label: const Text('Pick Videos'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No videos selected',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Tap the button below to pick videos from your gallery',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => ref.read(pickedVideosProvider.notifier).pickVideos(),
            icon: const Icon(Icons.add),
            label: const Text('Select Videos'),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoList(BuildContext context, WidgetRef ref, List<VideoFile> videos) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 60,
                color: Colors.grey[800],
                child: const Icon(Icons.video_file, size: 40),
              ),
            ),
            title: Text(
              video.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(video.formattedDuration),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Navigate to editing screen
                    _navigateToEditing(context, video);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => ref.read(pickedVideosProvider.notifier).removeVideo(index),
                ),
              ],
            ),
            onTap: () => _navigateToEditing(context, video),
          ),
        );
      },
    );
  }

  void _navigateToEditing(BuildContext context, VideoFile video) {
    // TODO: Navigate to editing screen when created
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening ${video.name} for editing')),
    );
  }
}
