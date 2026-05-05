import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/colors.dart';
import 'core/services/audio_player_service.dart';
import 'core/widgets/matrix_background.dart';
import 'core/widgets/mini_player_widget.dart';
import 'core/widgets/app_notification.dart';

import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/sync/presentation/pages/sync_page.dart';
import 'features/archive/presentation/pages/archive_page.dart';
import 'features/sets/presentation/pages/sets_page.dart';
import 'features/config/presentation/pages/config_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.ryanheise.audioservice.AudioService',
      androidNotificationChannelName: 'Audio Playback',
      androidNotificationOngoing: true,
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

// ─── App Shell ────────────────────────────────────────────────────────────────
// Responsibilities:
//   1. Page routing (bottom nav → page swap)
//   2. Ambient background rendering
//   3. Stacking MiniPlayer above Bottom Nav
//
// NOT responsible for: player logic, audio state, image loading.
// Those are delegated to MiniPlayerWidget and AudioPlayerService.
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const DashboardPage(),
    const SyncPage(),
    const ArchivePage(),
    Navigator(
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => const SetsPage(),
      ),
    ),
    const ConfigPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Selective rebuild: only re-render shell when hasTrack changes (mini player show/hide)
    final hasTrack = ref.watch(audioPlayerProvider.select((s) => s.hasTrack));

    return Scaffold(
      body: Stack(
        children: [
          // ── Ambient Background ──────────────────────────────────
          _buildBackground(),

          // ── Pages ───────────────────────────────────────────────
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.04),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: SizedBox(
                key: ValueKey<int>(_selectedIndex),
                width: double.infinity,
                height: double.infinity,
                child: _pages[_selectedIndex],
              ),
            ),
          ),

          // ── Bottom UI Section (Mini Player + Nav Bar) ──────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mini Player with slide animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  height: hasTrack ? 76 : 0, // Height of mini player
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: hasTrack ? 1 : 0,
                    child: const MiniPlayerWidget(),
                  ),
                ),
                // Bottom Navigation
                _buildBottomNav(),
              ],
            ),
          ),

          // ── Global Notifications (always on very top) ───────────
          AppNotification(bottomOffset: hasTrack ? 76 + 70 : 70),
        ],
      ),
    );
  }

  // ── Background ──────────────────────────────────────────────────────────────
  Widget _buildBackground() {
    return Stack(
      children: [
        Container(color: AppColors.background),
        const Positioned.fill(child: MatrixBackground()),
        Positioned(
          top: -100, left: -50,
          child: Container(
            width: 300, height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.primaryTeal.withValues(alpha: 0.08), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100, right: -50,
          child: Container(
            width: 250, height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.primaryMagenta.withValues(alpha: 0.06), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Bottom Navigation ───────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF080C16).withValues(alpha: 0.97),
        border: Border(
          top: BorderSide(
            color: AppColors.primaryTeal.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(0, Icons.home_rounded, 'HOME'),
            _navItem(1, FontAwesomeIcons.bolt, 'SYNC'),
            _navItem(2, Icons.library_music_rounded, 'ARCHIVE'),
            _navItem(3, Icons.playlist_play_rounded, 'SETS'),
            _navItem(4, Icons.settings_rounded, 'CONFIG'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing pill indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: isSelected ? 28 : 0,
              height: 2,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal,
                borderRadius: BorderRadius.circular(1),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.primaryTeal, blurRadius: 8, spreadRadius: 1)]
                    : [],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 14 : 0,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryTeal.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected
                    ? AppColors.primaryTeal
                    : AppColors.textMuted.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.monoStyle(
                fontSize: 8,
                color: isSelected
                    ? AppColors.primaryTeal.withValues(alpha: 0.8)
                    : AppColors.textMuted.withValues(alpha: 0.4),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
