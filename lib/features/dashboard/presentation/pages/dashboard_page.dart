import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/quota_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/storage_quota_card.dart';
import '../widgets/auth_node_card.dart';
import '../widgets/system_status_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning.';
    if (hour < 18) return 'Good afternoon.';
    return 'Good evening.';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotaAsync = ref.watch(quotaProvider);
    final authAsync = ref.watch(authStatusProvider);

    return CustomScrollView(
      slivers: [
        // ── Large Title Header ─────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SilverSync',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _greeting(),
                  style: AppTheme.darkTheme.textTheme.displayLarge,
                ),
              ],
            ),
          ),
        ),

        // ── Status Bar ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: authAsync.when(
              data: (auth) => _StatusPill(isOnline: true),
              loading: () => const _StatusPill(isOnline: false),
              error: (_, __) => const _StatusPill(isOnline: false),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // ── Storage Card ─────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: quotaAsync.when(
              data: (quota) => StorageQuotaCard(quota: quota),
              loading: () => const _LoadingCard(height: 100),
              error: (_, __) => _buildOfflineCard(ref),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // ── Section: Connections ─────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: AppTheme.sectionLabel('Connections'),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: authAsync.when(
              data: (auth) => Column(
                children: [
                  AuthNodeCard(
                    title: 'Spotify',
                    subtitle: auth.isSpotifyOnline ? 'Connected' : 'Not connected',
                    icon: FontAwesomeIcons.spotify,
                    isOnline: auth.isSpotifyOnline,
                  ),
                  const SizedBox(height: 10),
                  AuthNodeCard(
                    title: 'Google Drive',
                    subtitle: auth.isGoogleOnline ? 'Connected' : 'Not connected',
                    icon: FontAwesomeIcons.googleDrive,
                    isOnline: auth.isGoogleOnline,
                  ),
                ],
              ),
              loading: () => const _LoadingCard(height: 130),
              error: (_, __) => Column(
                children: [
                  AuthNodeCard(title: 'Spotify', subtitle: 'Unavailable', icon: FontAwesomeIcons.spotify, isOnline: false),
                  const SizedBox(height: 10),
                  AuthNodeCard(title: 'Google Drive', subtitle: 'Unavailable', icon: FontAwesomeIcons.googleDrive, isOnline: false),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // ── Section: System ──────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: AppTheme.sectionLabel('System'),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: authAsync.when(
              data: (_) => const SystemStatusCard(isApiOnline: true),
              loading: () => const SystemStatusCard(isApiOnline: false),
              error: (_, __) => const SystemStatusCard(isApiOnline: false),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 180)),
      ],
    );
  }

  Widget _buildOfflineCard(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 36, color: Colors.redAccent.withValues(alpha: 0.7)),
          const SizedBox(height: 12),
          Text('Cannot reach server', style: AppTheme.darkTheme.textTheme.bodyLarge),
          const SizedBox(height: 4),
          Text('Check your network connection', style: AppTheme.darkTheme.textTheme.bodyMedium),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => ref.read(quotaProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: const BorderSide(color: AppColors.accent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isOnline;
  const _StatusPill({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: isOnline ? AppColors.accentGreen : AppColors.textTertiary,
            shape: BoxShape.circle,
            boxShadow: isOnline ? [
              BoxShadow(color: AppColors.accentGreen.withValues(alpha: 0.5), blurRadius: 6),
            ] : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isOnline ? 'Connected' : 'Offline',
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: isOnline ? AppColors.accentGreen : AppColors.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final double height;
  const _LoadingCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
        ),
      ),
    );
  }
}
