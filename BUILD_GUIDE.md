# SilentCut - AI Video Editor

[![Flutter](https://img.shields.io/badge/Flutter-3.19+-blue.svg)](https://flutter.dev)
[![Kotlin](https://img.shields.io/badge/Kotlin-1.9+-purple.svg)](https://kotlinlang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

An intelligent Android video editor that automatically removes silence, filler words, and bad retakes using AI-powered transcription.

## Features

- 🎬 **Video Picker**: Select videos from your device gallery
- 🎙️ **AI Transcription**: Whisper.cpp powered speech-to-text (offline)
- ✂️ **Smart Editing**: Remove silence and filler words automatically
- 📝 **Transcript Editor**: Word-level editing with visual feedback
- 🚀 **Fast Export**: FFmpeg-based video processing
- 🔒 **Privacy First**: All processing happens on-device

## Architecture

```
lib/
├── core/                    # Shared utilities and constants
│   ├── constants/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── video_picker/       # Video selection from gallery
│   ├── transcription/      # Whisper.cpp transcription
│   ├── editing/            # Transcript-based editing
│   └── export/             # Video export with FFmpeg
└── main.dart               # App entry point

android/
├── app/src/main/
│   ├── kotlin/.../        # Native Kotlin code
│   │   ├── WhisperModelLoader.kt
│   │   ├── VideoProcessor.kt
│   │   └── WhisperTranscriber.kt
│   └── cpp/               # Native C++ code
│       ├── CMakeLists.txt
│       └── whisper_wrapper.cpp
```

## Tech Stack

### Flutter/Dart
- **State Management**: Riverpod 2.x
- **Video Processing**: ffmpeg_kit_flutter_full_gpl
- **Video Player**: video_player + chewie
- **File Handling**: file_picker, path_provider

### Native Android (Kotlin/C++)
- **Transcription**: Whisper.cpp via JNI
- **Video Processing**: FFmpegKit
- **Build System**: CMake + Gradle

## Getting Started

### Prerequisites

- Flutter SDK 3.19+
- Android Studio Arctic Fox+
- Android SDK 24+
- NDK 25+
- CMake 3.18+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/silentcut.git
cd silentcut
```

2. Install dependencies:
```bash
flutter pub get
```

3. Download Whisper model:
```bash
# Download ggml-base.en.bin and place in assets/models/
wget https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin -O assets/models/ggml-base.en.bin
```

4. Run the app:
```bash
flutter run
```

## Project Structure

### Core Modules

#### Video Picker (`lib/features/video_picker/`)
- Pick videos from device gallery
- Display video thumbnails and metadata
- Support for multiple video formats (MP4, MOV, AVI, MKV, WebM)

#### Transcription (`lib/features/transcription/`)
- Load Whisper.cpp model
- Extract audio from video
- Generate word-level timestamps
- Detect filler words (um, uh, like, etc.)

#### Editing (`lib/features/editing/`)
- Interactive transcript editor
- Toggle words/segments for removal
- Auto-detect silence using FFmpeg
- Manual cut points

#### Export (`lib/features/export/`)
- Concatenate kept segments
- Apply audio/video filters
- Progress tracking
- Save to device gallery

### Native Components

#### WhisperTranscriber.kt
Kotlin wrapper for Whisper.cpp JNI calls:
- `initModel(path)`: Load model
- `transcribe(audioPath)`: Generate transcript
- `freeModel()`: Release resources

#### VideoProcessor.kt
Native video processing utilities:
- Audio extraction
- Metadata retrieval
- Silence detection

#### whisper_wrapper.cpp
JNI bridge for Whisper.cpp:
- Model initialization
- Transcription execution
- Result formatting

## Configuration

### Android Manifest Permissions

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
```

### Build Configuration

Edit `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        minSdk 24
        targetSdk 34
        ndk {
            abiFilters 'arm64-v8a', 'armeabi-v7a'
        }
    }
}
```

## Development

### Running Tests
```bash
flutter test
```

### Building Release APK
```bash
flutter build apk --release
```

### Building iOS (Future)
```bash
flutter build ios --release
```

## Roadmap

- [ ] iOS support with Swift integration
- [ ] Multiple Whisper model sizes (tiny, base, small, medium, large)
- [ ] Custom filler word detection
- [ ] Batch processing
- [ ] Cloud sync (optional)
- [ ] Video preview during editing
- [ ] Undo/redo functionality
- [ ] Export format options (resolution, bitrate)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Whisper.cpp](https://github.com/ggerganov/whisper.cpp) - Fast Whisper inference
- [FFmpegKit](https://github.com/arthenica/ffmpeg-kit) - FFmpeg for mobile
- [Flutter](https://flutter.dev) - Cross-platform UI framework
- [Riverpod](https://riverpod.dev) - State management

## Contact

For questions or support, please open an issue on GitHub.
