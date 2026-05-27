import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../dashboard/presentation/providers/quota_provider.dart';
import '../../../dashboard/presentation/providers/auth_provider.dart';
import '../providers/preference_provider.dart';
import '../widgets/auth_button.dart';


class ConfigPage extends ConsumerWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotaAsync = ref.watch(quotaProvider);
    final authAsync = ref.watch(authStatusProvider);
    final prefsAsync = ref.watch(preferenceProvider);

    return CustomScrollView(
      slivers: [
        // ── Header ───────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Text('Settings', style: AppTheme.darkTheme.textTheme.displayLarge),
          ),
        ),

        // ── Section: Preferences ─────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: AppTheme.sectionLabel('Preferences'),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: prefsAsync.when(
              data: (prefs) => _SettingsCard(
                children: [
                  _ToggleRow(
                    icon: Icons.monitor_heart_rounded,
                    iconColor: AppColors.accent,
                    title: 'API Health Monitor',
                    subtitle: 'Ping backend services periodically',
                    value: prefs.apiHealthEnabled,
                    onChanged: (v) => ref.read(preferenceProvider.notifier).toggleApiHealth(v),
                  ),
                  _Divider(),
                  _ToggleRow(
                    icon: Icons.sync_rounded,
                    iconColor: AppColors.accentWarm,
                    title: 'Auto Sync',
                    subtitle: 'Sync when playlist changes are detected',
                    value: prefs.autoSyncEnabled,
                    onChanged: (v) => ref.read(preferenceProvider.notifier).toggleAutoSync(v),
                  ),
                  _Divider(),
                  _ToggleRow(
                    icon: Icons.notifications_rounded,
                    iconColor: AppColors.accentGreen,
                    title: 'Push Notifications',
                    subtitle: 'Receive sync status alerts',
                    value: prefs.notificationsEnabled,
                    onChanged: (v) => ref.read(preferenceProvider.notifier).toggleNotifications(v),
                  ),
                ],
              ),
              loading: () => Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.accent)),
                ),
              ),
              error: (err, stack) => _SettingsCard(
                children: [_InfoRow(label: 'Preferences', value: 'Failed to load')],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 28)),

        // ── Section: Storage ─────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: AppTheme.sectionLabel('Storage'),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: quotaAsync.when(
              data: (q) => _SettingsCard(
                children: [
                  _InfoRow(label: 'Drive Usage', value: q.used),
                  _Divider(),
                  _InfoRow(label: 'Quota Used', value: '${q.usedPercentage.toStringAsFixed(1)}%'),
                  _Divider(),
                  _InfoRow(label: 'Sync Engine', value: 'v2.4.1'),
                ],
              ),
              loading: () => Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.accent)),
                ),
              ),
              error: (_, __) => _SettingsCard(
                children: [_InfoRow(label: 'Drive Usage', value: 'Unavailable')],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 28)),

        // ── Section: Accounts ─────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: AppTheme.sectionLabel('Connected Accounts'),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: authAsync.when(
              data: (status) => Column(
                children: [
                  AuthButton(
                    name: 'Spotify',
                    icon: FontAwesomeIcons.spotify,
                    accentColor: const Color(0xFF1DB954),
                    isOnline: status.isSpotifyOnline,
                    isLoading: false,
                    onConnect: () => _openUrl('${AppConstants.baseUrl}/auth/login', ref),
                    onRefresh: () => ref.invalidate(authStatusProvider),
                    onRevoke: () async {
                      await ref.read(apiServiceProvider).logoutSpotify();
                      ref.invalidate(authStatusProvider);
                    },
                  ),
                  const SizedBox(height: 10),
                  AuthButton(
                    name: 'Google Drive',
                    icon: FontAwesomeIcons.googleDrive,
                    accentColor: const Color(0xFF4285F4),
                    isOnline: status.isGoogleOnline,
                    isLoading: false,
                    onConnect: () => _openUrl('${AppConstants.baseUrl}/auth/google/login', ref),
                    onRefresh: () => ref.invalidate(authStatusProvider),
                    onRevoke: () async {
                      await ref.read(apiServiceProvider).logoutGoogle();
                      ref.invalidate(authStatusProvider);
                    },
                  ),
                ],
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.accent)),
                ),
              ),
              error: (_, __) => Column(
                children: [
                  AuthButton(name: 'Spotify', icon: FontAwesomeIcons.spotify, accentColor: const Color(0xFF1DB954), isOnline: false, isLoading: false, onConnect: () {}, onRefresh: () {}, onRevoke: () async {}),
                ],
              ),
            ),
          ),
        ),

        // ── Footer ───────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
            child: Center(
              child: Column(
                children: [
                  Text('SilverSync', style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: 4),
                  Text('Version 1.0.0', style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  )),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 180)),
      ],
    );
  }

  Future<void> _openUrl(String url, WidgetRef ref) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      await Future.delayed(const Duration(seconds: 5));
      ref.invalidate(authStatusProvider);
    }
  }
}

// ── Settings Card ─────────────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(children: children),
    );
  }
}

// ── Divider ───────────────────────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 60),
      child: Container(height: 0.5, color: AppColors.surfaceBorder),
    );
  }
}

// ── Toggle Row ────────────────────────────────────────────────────────────────
class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 15)),
                Text(subtitle, style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 15)),
          Text(value, style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          )),
        ],
      ),
    );
  }
}
