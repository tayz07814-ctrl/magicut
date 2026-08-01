class AppConstants {
  // Whisper model settings
  static const String whisperModelPath = 'assets/models/ggml-base.en.bin';
  static const String whisperModelName = 'ggml-base.en.bin';
  
  // Video settings
  static const List<String> supportedVideoFormats = [
    'mp4',
    'mov',
    'avi',
    'mkv',
    'webm',
  ];
  
  // Silence detection thresholds
  static const double silenceThresholdDb = -50.0;
  static const int silenceMinDurationMs = 500;
  
  // UI constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Asset paths
  static const String assetsModels = 'assets/models/';
  static const String assetsFonts = 'assets/fonts/';
}
