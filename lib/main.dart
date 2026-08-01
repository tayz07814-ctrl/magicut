import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/video_picker/presentation/screens/video_picker_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: SilentCutApp(),
    ),
  );
}

class SilentCutApp extends StatelessWidget {
  const SilentCutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SilentCut',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const VideoPickerScreen(),
    );
  }
}
