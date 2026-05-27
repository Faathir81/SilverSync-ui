import 'package:flutter/material.dart';

class AppColors {
  // ── Backgrounds ─────────────────────────────────────────────
  static const Color background     = Color(0xFF0A0A0F); // Near-black violet
  static const Color surface        = Color(0xFF111118); // Elevated dark
  static const Color surfaceHigh    = Color(0xFF1C1C2A); // Card/Modal surface
  static const Color surfaceBorder  = Color(0xFF252535); // Subtle borders

  // ── Accent System ────────────────────────────────────────────
  static const Color accent         = Color(0xFF7C6FFF); // Violet primary
  static const Color accentDim      = Color(0x337C6FFF); // 20% violet (glow)
  static const Color accentWarm     = Color(0xFFF0624D); // Coral warm accent
  static const Color accentGreen    = Color(0xFF34D399); // Emerald for success

  // ── Typography ───────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFFF2F2F7); // Warm white
  static const Color textSecondary  = Color(0xFF8E8E9E); // Mid grey
  static const Color textTertiary   = Color(0xFF4A4A5E); // Dim grey (hints)

  // ── Legacy aliases (keep existing references compiling) ──────
  static const Color textMain       = textPrimary;
  static const Color textMuted      = textSecondary;
  static const Color primaryTeal    = accent;       // remapped → violet
  static const Color primaryMagenta = accentWarm;
  static const Color primaryGreen   = accentGreen;
  static const Color cardInner      = surfaceHigh;
  static const Color glowTeal       = accentDim;
  static const Color glowMagenta    = Color(0x33F0624D);

  // ── Gradient Presets ─────────────────────────────────────────
  static LinearGradient get accentGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C6FFF), Color(0xFFA78BFA)],
  );

  static LinearGradient get cardBorderGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.08),
      Colors.white.withValues(alpha: 0.02),
    ],
  );

  static LinearGradient get activeCardGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      accent.withValues(alpha: 0.15),
      accent.withValues(alpha: 0.04),
    ],
  );
}
