import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_player_service.dart';

class PlayerControls extends StatelessWidget {
  final PlayerStateModel state;
  final AudioPlayerNotifier player;

  const PlayerControls({
    super.key,
    required this.state,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    Widget playBtn = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: state.isPlaying
              ? [AppColors.primaryTeal, const Color(0xFF00B8CC)]
              : [AppColors.primaryTeal.withOpacity(0.8), AppColors.primaryTeal.withOpacity(0.5)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withOpacity(state.isPlaying ? 0.55 : 0.25),
            blurRadius: state.isPlaying ? 28 : 16,
            spreadRadius: state.isPlaying ? 4 : 1,
          ),
        ],
      ),
      child: state.isLoading
          ? const Padding(
              padding: EdgeInsets.all(22),
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.black),
              ),
            )
          : Icon(
              state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 38,
              color: AppColors.background,
            ),
    );

    if (state.isPlaying) {
      playBtn = playBtn.animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1200.ms, curve: Curves.easeInOut);
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _controlBtn(
              icon: Icons.skip_previous_rounded,
              size: 30,
              onTap: () => player.skipPrevious(),
            ),
            const SizedBox(width: 30),
            GestureDetector(
              onTap: () => player.togglePlayPause(),
              child: playBtn,
            ),
            const SizedBox(width: 30),
            _controlBtn(
              icon: Icons.skip_next_rounded,
              size: 30,
              onTap: () => player.skipNext(),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _modeButton(
              icon: Icons.shuffle_rounded,
              isActive: state.shuffleEnabled,
              onTap: () => player.toggleShuffle(),
            ),
            const SizedBox(width: 25),
            _modeButton(
              icon: state.repeatMode == PlayerRepeatMode.one ? Icons.repeat_one_rounded : Icons.repeat_rounded,
              isActive: state.repeatMode != PlayerRepeatMode.none,
              onTap: () => player.cycleRepeatMode(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _controlBtn({required IconData icon, required double size, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryTeal.withOpacity(0.07),
          border: Border.all(color: AppColors.primaryTeal.withOpacity(0.18)),
        ),
        child: Icon(icon, size: size, color: Colors.white.withOpacity(0.85)),
      ),
    );
  }

  Widget _modeButton({required IconData icon, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? AppColors.primaryTeal.withOpacity(0.15) : Colors.transparent,
          border: Border.all(
            color: isActive ? AppColors.primaryTeal.withOpacity(0.5) : AppColors.textMuted.withOpacity(0.2),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? AppColors.primaryTeal : AppColors.textMuted.withOpacity(0.4),
        ),
      ),
    );
  }
}
