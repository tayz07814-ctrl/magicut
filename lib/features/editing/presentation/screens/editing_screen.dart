import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/editing_providers.dart';
import '../../transcription/domain/entities/transcript.dart';

class EditingScreen extends ConsumerStatefulWidget {
  final String videoPath;

  const EditingScreen({super.key, required this.videoPath});

  @override
  ConsumerState<EditingScreen> createState() => _EditingScreenState();
}

class _EditingScreenState extends ConsumerState<EditingScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(editingSessionProvider.notifier).startSession(widget.videoPath);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editingSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Video'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: state.session != null ? () => _exportVideo() : null,
          ),
        ],
      ),
      body: Column(
        children: [
          // Video preview placeholder
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam, size: 64, color: Colors.white54),
                    SizedBox(height: 16),
                    Text('Video Preview', style: TextStyle(color: Colors.white54)),
                  ],
                ),
              ),
            ),
          ),
          // Transcript editor
          Expanded(
            flex: 3,
            child: _buildTranscriptEditor(state),
          ),
          // Controls
          _buildControls(state),
        ],
      ),
    );
  }

  Widget _buildTranscriptEditor(EditingSessionState state) {
    if (state.transcript == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Transcribing...'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.transcript!.segments.length,
      itemBuilder: (context, index) {
        final segment = state.transcript!.segments[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formatTime(segment.startTime)} - ${_formatTime(segment.endTime)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: segment.words.map((word) {
                    return GestureDetector(
                      onTap: () => _toggleWord(word),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: word.isDeleted
                              ? Theme.of(context).colorScheme.error.withOpacity(0.3)
                              : Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          word.text,
                          style: TextStyle(
                            decoration: word.isDeleted ? TextDecoration.lineThrough : null,
                            color: word.isDeleted
                                ? Theme.of(context).colorScheme.onError
                                : null,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls(EditingSessionState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Switch(
            value: state.session?.autoRemoveSilence ?? true,
            onChanged: (value) =>
                ref.read(editingSessionProvider.notifier).toggleAutoRemoveSilence(value),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          const Text('Auto-remove silence'),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => ref.read(editingSessionProvider.notifier).detectSilence(),
            icon: const Icon(Icons.waves),
            label: const Text('Detect Silence'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: state.session != null ? () => _exportVideo() : null,
            icon: const Icon(Icons.save),
            label: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _toggleWord(TranscriptWord word) {
    ref.read(editingSessionProvider.notifier).toggleWordSelection(word);
  }

  void _exportVideo() {
    // Navigate to export or start export process
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting export...')),
    );
  }

  String _formatTime(double seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }
}
