ROLE: You are an expert Android developer. You MUST write complete, production-ready code. No placeholders, no "you can add this later", no pseudocode. Every file must be fully implemented.

TASK: Build a complete native Android app called "SilentCut" using Flutter for UI and Kotlin for native video processing.

SYSTEM STATUS (assume all installed and in PATH):

Flutter SDK
Android SDK (API 34)
Android NDK (r25+)
JDK 17
Gradle 8.5
Whisper.cpp (clone into project)
APP SPECIFICATIONS
Core Purpose
A video editor with ONE job: automatically remove silence, filler words, and bad retakes from videos using AI transcription. User uploads/picks a video → app transcribes audio with Whisper → app shows editable transcript → user deletes unwanted words/sentences → app outputs a polished, merged video with no silence and no bad takes.

Features (ALL must be implemented)
Video Picker: Pick video from gallery using file_picker or image_picker
Whisper Transcription: Run whisper.cpp natively via Kotlin (use whisper-android or JNI bindings to whisper.cpp)
Silence Detection: Use FFmpeg or audio amplitude analysis to find silent gaps (>0.5s with volume < -40dB)
Timestamped Transcript UI: Display words with timestamps in a scrollable list
Tap word to play that segment
Long press to delete word/sentence
Visual waveform alignment
Word Deletion Editor: User deletes words/phrases → app marks those timestamps for cutting
Auto-Silence-Removal: Toggle to automatically remove all detected silence
Video Processor (Kotlin Native):
Uses FFmpegKit or MediaMuxer + MediaCodec to cut segments
Merges remaining clips into single polished video
Preserves audio sync
Export: Save final video to /Movies/SilentCut/
Progress UI: Show transcription % and export % with progress bars
Offline First: Works without internet (Whisper runs locally)
Tech Stack (MANDATORY)
Flutter 3.19+ (UI layer, state management with Riverpod)
Kotlin 1.9+ (Native video processing, Whisper JNI)
Whisper.cpp (built for Android ARM64 via NDK)
FFmpegKit-Android (video cutting/merging)
Riverpod (state)
Dio (any network, though app is offline)
permission_handler (storage permissions)
REQUIRED FILE STRUCTURE (create all of these)
silentcut/
├── pubspec.yaml
├── android/
│   ├── build.gradle
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       ├── kotlin/com/silentcut/app/
│   │       │   ├── MainActivity.kt
│   │       │   ├── VideoProcessor.kt
│   │       │   ├── WhisperEngine.kt
│   │       │   ├── SilenceDetector.kt
│   │       │   └── FFmpegHelper.kt
│   │       └── cpp/
│   │           ├── CMakeLists.txt
│   │           ├── whisper_jni.cpp
│   │           └── audio_extractor.cpp
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── theme.dart
│   │   ├── constants.dart
│   │   └── platform_channel.dart
│   ├── data/
│   │   ├── models/
│   │   │   ├── transcript_word.dart
│   │   │   ├── video_segment.dart
│   │   │   └── processing_state.dart
│   │   └── repositories/
│   │       └── video_repository.dart
│   ├── presentation/
│   │   ├── providers/
│   │   │   ├── video_provider.dart
│   │   │   ├── transcript_provider.dart
│   │   │   └── processing_provider.dart
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── transcript_editor_screen.dart
│   │   │   └── export_screen.dart
│   │   └── widgets/
│   │       ├── video_player_widget.dart
│   │       ├── word_chip.dart
│   │       ├── waveform_widget.dart
│   │       └── progress_overlay.dart
│   └── services/
│       ├── whisper_service.dart
│       ├── video_service.dart
│       └── ffmpeg_service.dart
└── assets/
    └── models/
        └── ggml-tiny.en.bin  (Whisper model, download from HuggingFace)
STEP-BY-STEP IMPLEMENTATION ORDER
You MUST produce code in this order, file by file:

STEP 1: Project Setup
Write pubspec.yaml with all dependencies
Write android/build.gradle
Write android/app/build.gradle with NDK config and FFmpegKit
Write AndroidManifest.xml with storage/foreground service permissions
STEP 2: Whisper Native Integration
Write CMakeLists.txt to build whisper.cpp for Android
Write whisper_jni.cpp with JNI bridge (load model, transcribe PCM, return timestamps)
Write WhisperEngine.kt (wrap JNI calls, return List<TranscriptWord>)
Write audio_extractor.cpp (extract 16kHz mono PCM from video using FFmpeg APIs)
STEP 3: Video Processing
Write SilenceDetector.kt (analyze PCM amplitude, return silence segments)
Write FFmpegHelper.kt (cut video at timestamps, concat segments using filter_complex)
Write VideoProcessor.kt (orchestrator: extract audio → whisper → detect silence → merge cuts → encode final)
STEP 4: Flutter Layer
Write main.dart, app.dart, theme
Write all models, providers, services
Write platform_channel.dart (MethodChannel for Kotlin ↔ Flutter)
Write all screens and widgets
STEP 5: Build & Test
Provide exact commands:
flutter pub get
cd android && ./gradlew assembleRelease
flutter build apk --release
CODE REQUIREMENTS
WhisperEngine.kt MUST:

Load ggml-tiny.en.bin from assets on first run
Accept raw PCM (16kHz, mono, Float32)
Return word-level timestamps with confidence scores
VideoProcessor.kt MUST:

Use MediaMetadataRetriever to get video duration
Use FFmpegKit with filter_complex to:
Trim video by [start]trim=start=X:end=Y[v0]; [v0]asetpts=PTS-STARTPTS[v0out]
Concat all kept segments: [v0out][v1out]...[vNout]concat=n=N:v=1:a=1[outv][outa]
Handle large videos (stream processing, don't load full file in memory)
TranscriptEditorScreen MUST:

Display words as ActionChip widgets in flowing Wrap
Selected words highlighted red, deleted words struck through
Bottom controls: Play, Skip Silence toggle, Auto-Cut Filler Words, Export
Word-level seeking on tap
Performance:

Transcription must show progress (post updates via EventChannel every 500ms)
Export must run in foreground service with notification
Model load: stream copy on first run, not in-memory
CRITICAL RULES
DO NOT skip any file. Write all of them completely.
DO NOT use // TODO or // implement later
DO NOT provide "simplified versions" — write the real thing
DO NOT ask clarifying questions — make reasonable decisions and document them as comments
If you must use a library, include the exact version in pubspec.yaml
All Kotlin code must use coroutines
All Flutter code must use Riverpod (no setState for business logic)
Include error handling for: no whisper model, corrupt video, OOM, FFmpeg failure
Whisper model asset: provide download script in assets/models/download.sh
OUTPUT FORMAT
Start your response with: "BUILDING SILENTCUT ANDROID APP"

Then proceed file by file in the order above. For each file:

Brief comment explaining the file
Full code in a single code block with filename as the info string
After all files, provide:

README.md content with build instructions
A troubleshooting section for common NDK/Whisper build issues
A note on how to handle model files in production (obfuscation, splitting APK)
BEGIN NOW. NO PREAMBLE. NO EXPLANATION OF WHAT YOU'LL DO. JUST WRITE THE CODE.
