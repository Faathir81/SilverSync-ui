import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/player/audio_player_provider.dart';

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
    Widget playBtn = Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.textMain,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: state.isLoading
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(AppColors.background),
              ),
            )
          : Icon(
              state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 40,
              color: AppColors.background,
            ),
    );

    if (state.isPlaying) {
      playBtn = playBtn
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.03, 1.03),
            duration: 1500.ms,
            curve: Curves.easeInOutSine,
          );
    }

    return Column(
      children: [
        // ── Primary Controls: Prev / Play / Next ──
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PressableButton(
              onTap: player.skipPrevious,
              child: _controlIcon(Icons.skip_previous_rounded, 42),
            ),
            const SizedBox(width: 40),
            _PressableButton(
              onTap: player.togglePlayPause,
              child: playBtn,
            ),
            const SizedBox(width: 40),
            _PressableButton(
              onTap: player.skipNext,
              child: _controlIcon(Icons.skip_next_rounded, 42),
            ),
          ],
        ),
        const SizedBox(height: 36),
        // ── Secondary Controls: Shuffle / Repeat ──
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ModeButton(
              icon: Icons.shuffle_rounded,
              isActive: state.shuffleEnabled,
              onTap: player.toggleShuffle,
            ),
            const SizedBox(width: 32),
            _ModeButton(
              icon: state.repeatMode == PlayerRepeatMode.one
                  ? Icons.repeat_one_rounded
                  : Icons.repeat_rounded,
              isActive: state.repeatMode != PlayerRepeatMode.none,
              onTap: player.cycleRepeatMode,
            ),
          ],
        ),
      ],
    );
  }

  Widget _controlIcon(IconData icon, double size) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      child: Icon(icon, size: size, color: AppColors.textMain),
    );
  }
}

// ─── Pressable Button ─────────────────────────────────────────────────────────
class _PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableButton({required this.child, required this.onTap});

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}

// ─── Mode Button (Shuffle / Repeat) ───────────────────────────────────────────
class _ModeButton extends StatefulWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_ModeButton> createState() => _ModeButtonState();
}

class _ModeButtonState extends State<_ModeButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isActive ? AppColors.surface : Colors.transparent,
          ),
          child: Icon(
            widget.icon,
            size: 22,
            color: widget.isActive ? AppColors.primaryTeal : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
