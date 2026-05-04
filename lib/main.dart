import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/colors.dart';
import 'core/widgets/angular_container.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'core/widgets/matrix_background.dart';

import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/sync/presentation/pages/sync_page.dart';
import 'features/archive/presentation/pages/archive_page.dart';
import 'features/sets/presentation/pages/sets_page.dart';
import 'features/config/presentation/pages/config_page.dart';

void main() {
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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _hasTrack = false; // Set to false so it's hidden when no track is playing

  final List<Widget> _pages = [
    const DashboardPage(),
    const SyncPage(),
    const ArchivePage(),
    const SetsPage(),
    const ConfigPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Grid/Circuit
          _buildBackground(),
          
          // Pages with Transition
          Padding(
            padding: const EdgeInsets.only(bottom: 160), // Space for miniplayer + nav
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
          
          // Mini Player Overlay
          if (_hasTrack)
            Positioned(
              bottom: 60, // Sits right above the bottom nav without gap
              left: 0,
              right: 0,
              child: _buildMiniPlayer(),
            ),
          
          // Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(color: AppColors.background), // Base dark color
        const Positioned.fill(child: MatrixBackground()), // Falling code
        // Radial glows for prototype match
        Positioned(
          top: -100,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.primaryTeal.withOpacity(0.08), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          right: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.primaryMagenta.withOpacity(0.06), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniPlayer() {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          // Swiped Right -> Previous Song
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Skipped to Previous', style: AppTheme.monoStyle(color: Colors.white)), backgroundColor: AppColors.background));
        } else if (details.primaryVelocity! < 0) {
          // Swiped Left -> Next Song
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Skipped to Next', style: AppTheme.monoStyle(color: Colors.white)), backgroundColor: AppColors.background));
        }
      },
      child: Container(
        color: AppColors.background.withOpacity(0.95), // Flat, Spotify-like bar
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.music_off_outlined, color: Colors.white24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('NO TRACK ACTIVE', style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 14, color: Colors.white54)),
                  Text('SYSTEM IDLE', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal.withOpacity(0.5))),
                ],
              ),
            ),
            _playerAction(Icons.play_arrow, false),
            const SizedBox(width: 10),
            _playerAction(Icons.skip_next, false),
          ],
        ),
      ),
    );
  }

  Widget _playerAction(IconData icon, bool isActive) {
    return AngularContainer(
      cutSize: 4,
      isActive: isActive,
      width: 40,
      height: 40,
      child: Icon(icon, size: 18, color: isActive ? AppColors.primaryTeal : Colors.white70),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.95),
        border: Border(
          top: BorderSide(color: AppColors.primaryTeal.withOpacity(0.2), width: 1),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
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
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(bottom: isSelected ? 4 : 0, top: isSelected ? 0 : 4),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? AppColors.primaryTeal : AppColors.textMuted.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTheme.monoStyle(
                fontSize: 9,
                color: isSelected ? AppColors.textMain : AppColors.textMuted.withOpacity(0.6),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            // Glowing Indicator Line
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              height: 2,
              width: isSelected ? 30 : 0,
              decoration: BoxDecoration(
                color: AppColors.primaryTeal,
                boxShadow: isSelected ? [
                  BoxShadow(color: AppColors.primaryTeal, blurRadius: 8, spreadRadius: 1),
                ] : [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
