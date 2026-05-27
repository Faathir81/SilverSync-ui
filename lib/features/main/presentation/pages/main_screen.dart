import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/ambient_background.dart';
import '../../../../core/widgets/silver_sync_nav_bar.dart';
import '../../../../core/widgets/mini_player_widget.dart';
import '../../../../core/widgets/app_notification.dart';
import '../../../../core/player/audio_player_provider.dart';

import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../sync/presentation/pages/sync_page.dart';
import '../../../archive/presentation/pages/archive_page.dart';
import '../../../sets/presentation/pages/sets_page.dart';
import '../../../config/presentation/pages/config_page.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const SyncPage(),
    const ArchivePage(),
    const SetsPage(),
    const ConfigPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final hasTrack = ref.watch(audioPlayerProvider.select((s) => s.hasTrack));

    return Scaffold(
      body: Stack(
        children: [
          // Centralized Background
          const AmbientBackground(),
          
          // Pages with Original Animated Transition
          Padding(
            padding: EdgeInsets.only(bottom: hasTrack ? 140 : 70), // Balanced for refined nav bar
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.05),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: SizedBox(
                key: ValueKey<int>(_selectedIndex),
                width: double.infinity,
                height: double.infinity,
                child: _pages[_selectedIndex],
              ),
            ),
          ),

          // Mini Player & Nav Bar Group
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MiniPlayerWidget(),
                SilverSyncNavBar(
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              ],
            ),
          ),

          // Global Notification Overlay
          const AppNotification(),
        ],
      ),
    );
  }
}
