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
      playBtn = playBtn
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 1200.ms,
            curve: Curves.easeInOut,
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
              child: _controlCircle(Icons.skip_previous_rounded, 30),
            ),
            const SizedBox(width: 30),
            _PressableButton(
              onTap: player.togglePlayPause,
              child: playBtn,
            ),
            const SizedBox(width: 30),
            _PressableButton(
              onTap: player.skipNext,
              child: _controlCircle(Icons.skip_next_rounded, 30),
            ),
          ],
        ),
        const SizedBox(height: 30),
        // ── Secondary Controls: Shuffle / Repeat ──
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ModeButton(
              icon: Icons.shuffle_rounded,
              isActive: state.shuffleEnabled,
              onTap: player.toggleShuffle,
            ),
            const SizedBox(width: 25),
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

  Widget _controlCircle(IconData icon, double size) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryTeal.withOpacity(0.07),
        border: Border.all(color: AppColors.primaryTeal.withOpacity(0.18)),
      ),
      child: Icon(icon, size: size, color: Colors.white.withOpacity(0.85)),
    );
  }
}

// ─── Pressable Button ─────────────────────────────────────────────────────────
/// A clean stateful button with scale-on-press animation.
/// Uses proper onTapDown/onTapUp to avoid gesture conflicts that caused
/// the "pause triggers next" bug.
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
        scale: _isPressed ? 0.88 : 1.0,
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
        scale: _isPressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isActive
                ? AppColors.primaryTeal.withOpacity(0.15)
                : Colors.transparent,
            border: Border.all(
              color: widget.isActive
                  ? AppColors.primaryTeal.withOpacity(0.5)
                  : AppColors.textMuted.withOpacity(0.2),
            ),
          ),
          child: Icon(
            widget.icon,
            size: 20,
            color: widget.isActive
                ? AppColors.primaryTeal
                : AppColors.textMuted.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}
