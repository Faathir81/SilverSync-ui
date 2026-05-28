import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'core/theme/app_theme.dart';
import 'features/main/presentation/pages/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.ryanheise.audioservice.AudioService',
      androidNotificationChannelName: 'Audio Playback',
      androidNotificationOngoing: false,
      androidStopForegroundOnPause: true,
    );
  }

  runApp(
    const ProviderScope(
      child: SilverSyncApp(),
    ),
  );
}

class SilverSyncApp extends StatelessWidget {
  const SilverSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SilverSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}
