import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/angular_container.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/services/api_service.dart';
import '../../../dashboard/presentation/providers/quota_provider.dart';
import '../../../dashboard/presentation/providers/auth_provider.dart';
import '../../../../core/providers/notification_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ConfigPage extends ConsumerStatefulWidget {
  const ConfigPage({super.key});

  @override
  ConsumerState<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends ConsumerState<ConfigPage> {
  bool apiHealthEnabled = true;
  bool autoSyncEnabled = true;
  bool notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final quotaAsync = ref.watch(quotaProvider);
    final authAsync = ref.watch(authStatusProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ═══════════════ STICKY HEADER ═══════════════
        Container(
          color: AppColors.background,
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SYS // ACTIVE', style: AppTheme.monoStyle(fontSize: 12, color: AppColors.primaryTeal.withOpacity(0.7))),
              const SizedBox(height: 4),
              Text('SILVERSYNC', style: AppTheme.darkTheme.textTheme.displayLarge),
              const SizedBox(height: 25),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CONTROL // SYSTEM CONFIG', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal.withOpacity(0.4), letterSpacing: 2)),
                  const SizedBox(height: 4),
                  Text('Settings', style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 18)),
                ],
              ),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.primaryTeal.withOpacity(0.15)),

        // ═══════════════ SCROLLABLE CONTENT ═══════════════
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSystemModules(authAsync),
                const SizedBox(height: 20),
                _buildRuntimeMetrics(quotaAsync),
                const SizedBox(height: 20),
                _buildAuthNodes(authAsync),
                const SizedBox(height: 30),
                _buildAppSignature(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSystemModules(AsyncValue<AuthStatus> authAsync) {
    bool isApiOnline = authAsync.maybeWhen(data: (d) => true, orElse: () => false);
    return AngularContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('◈ SYSTEM MODULES', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal.withOpacity(0.4), letterSpacing: 2)),
          const SizedBox(height: 15),
          _buildToggleRow(Icons.monitor_heart, AppColors.primaryTeal, 'API Health Monitor', 'Ping backend services', apiHealthEnabled, (v) => setState(() => apiHealthEnabled = v)),
          const Divider(color: Colors.white10, height: 20),
          _buildToggleRow(Icons.radio, AppColors.primaryMagenta, 'Auto Sync', 'Sync on playlist change', autoSyncEnabled, (v) => setState(() => autoSyncEnabled = v)),
          const Divider(color: Colors.white10, height: 20),
          _buildToggleRow(Icons.security, AppColors.primaryGreen, 'Push Notifications', 'Sync status alerts', notificationsEnabled, (v) => setState(() => notificationsEnabled = v)),
          
          if (apiHealthEnabled) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isApiOnline ? AppColors.primaryGreen.withOpacity(0.05) : Colors.redAccent.withOpacity(0.05),
                border: Border.all(color: isApiOnline ? AppColors.primaryGreen.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(isApiOnline ? Icons.wifi : Icons.wifi_off, color: isApiOnline ? AppColors.primaryGreen : Colors.redAccent, size: 14),
                  const SizedBox(width: 10),
                  Text(isApiOnline ? 'ALL SERVICES NOMINAL' : 'API OFFLINE', style: AppTheme.monoStyle(fontSize: 10, color: isApiOnline ? AppColors.primaryGreen : Colors.redAccent)),
                  if (isApiOnline) ...[
                    const SizedBox(width: 10),
                    Text('· LATENCY: 42ms', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryGreen.withOpacity(0.4))),
                    const Spacer(),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppColors.primaryGreen.withOpacity(0.8), blurRadius: 4)],
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildToggleRow(IconData icon, Color iconColor, String title, String subtitle, bool enabled, Function(bool) onToggle) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.08),
            border: Border.all(color: iconColor.withOpacity(0.2)),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 14)),
              Text(subtitle, style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted.withOpacity(0.7))),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => onToggle(!enabled),
          child: _NeonToggle(enabled: enabled),
        ),
      ],
    );
  }

  Widget _buildRuntimeMetrics(AsyncValue quotaAsync) {
    String driveQuota = quotaAsync.when(
      data: (q) => '${q.usedPercentage.toStringAsFixed(1)}%',
      loading: () => '...',
      error: (_, __) => 'N/A',
    );

    return AngularContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('◈ RUNTIME METRICS', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal.withOpacity(0.4), letterSpacing: 2)),
          const SizedBox(height: 15),
          _buildMetricRow('SYNC_ENGINE_v', '2.4.1'),
          _buildMetricRow('API_BUILD', '20260504'),
          _buildMetricRow('DRIVE_QUOTA', driveQuota),
          _buildMetricRow('UPTIME', '99.98%'),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.memory, size: 14, color: AppColors.primaryTeal.withOpacity(0.3)),
              const SizedBox(width: 8),
              Text(key, style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted.withOpacity(0.5), letterSpacing: 1)),
            ],
          ),
          Text(value, style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal).copyWith(shadows: [const Shadow(color: AppColors.primaryTeal, blurRadius: 4)])),
        ],
      ),
    );
  }

  Widget _buildAuthNodes(AsyncValue<AuthStatus> authAsync) {
    bool spotifyOnline = authAsync.maybeWhen(data: (d) => d.isSpotifyOnline, orElse: () => false);
    bool googleOnline = authAsync.maybeWhen(data: (d) => d.isGoogleOnline, orElse: () => false);
    bool isLoading = authAsync is AsyncLoading;

    return AngularContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('◈ AUTH NODES', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal.withOpacity(0.4), letterSpacing: 2)),
          const SizedBox(height: 15),
          _buildAuthButton(
            name: 'Spotify',
            icon: FontAwesomeIcons.spotify,
            accentColor: const Color(0xFF1DB954),
            isOnline: spotifyOnline,
            isLoading: isLoading,
            onConnect: () => _openUrl('http://192.168.1.13:8080/auth/login'),
            onRefresh: () {
              ref.read(notificationProvider.notifier).show('REFRESHING SPOTIFY STATUS...');
              ref.invalidate(authStatusProvider);
            },
            onRevoke: () async {
              ref.read(notificationProvider.notifier).show('REVOKING SPOTIFY SESSION...');
              await ref.read(apiServiceProvider).logoutSpotify();
              ref.invalidate(authStatusProvider);
            },
          ),
          const SizedBox(height: 10),
          _buildAuthButton(
            name: 'Google Drive',
            icon: FontAwesomeIcons.googleDrive,
            accentColor: const Color(0xFF4285F4),
            isOnline: googleOnline,
            isLoading: isLoading,
            onConnect: () => _openUrl('http://192.168.1.13:8080/auth/google/login'),
            onRefresh: () {
              ref.read(notificationProvider.notifier).show('REFRESHING DRIVE STATUS...');
              ref.invalidate(authStatusProvider);
            },
            onRevoke: () async {
              ref.read(notificationProvider.notifier).show('REVOKING DRIVE SESSION...');
              await ref.read(apiServiceProvider).logoutGoogle();
              ref.invalidate(authStatusProvider);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    ref.read(notificationProvider.notifier).show('OPENING AUTH GATEWAY...');
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ref.read(notificationProvider.notifier).show('COULD NOT OPEN AUTH URL');
    }
    // After user likely finishes OAuth, refresh auth status
    await Future.delayed(const Duration(seconds: 5));
    if (mounted) ref.invalidate(authStatusProvider);
  }

  Widget _buildAuthButton({
    required String name,
    required IconData icon,
    required Color accentColor,
    required bool isOnline,
    required bool isLoading,
    required VoidCallback onConnect,
    required VoidCallback onRefresh,
    required VoidCallback onRevoke,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : (isOnline ? onRefresh : onConnect),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isOnline
              ? accentColor.withOpacity(0.04)
              : AppColors.primaryTeal.withOpacity(0.04),
          border: Border.all(
            color: isOnline
                ? accentColor.withOpacity(0.2)
                : AppColors.primaryTeal.withOpacity(0.25),
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (isOnline ? accentColor : AppColors.primaryTeal).withOpacity(0.1),
                border: Border.all(color: (isOnline ? accentColor : AppColors.primaryTeal).withOpacity(0.3)),
              ),
              child: isLoading
                  ? const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 1.5)))
                  : Icon(icon, color: isOnline ? accentColor : AppColors.primaryTeal, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                    color: AppColors.textMain,
                  )),
                  Text(
                    isOnline ? 'Connected — Tap to refresh' : 'Not connected — Tap to login',
                    style: AppTheme.monoStyle(fontSize: 9, color: isOnline ? accentColor.withOpacity(0.6) : AppColors.primaryTeal.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: isLoading ? null : (isOnline ? onRevoke : onConnect),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isOnline ? Colors.redAccent.withOpacity(0.08) : AppColors.primaryTeal.withOpacity(0.1),
                  border: Border.all(color: isOnline ? Colors.redAccent.withOpacity(0.3) : AppColors.primaryTeal.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOnline ? Icons.link_off : Icons.open_in_browser,
                      size: 12,
                      color: isOnline ? Colors.redAccent.withOpacity(0.8) : AppColors.primaryTeal,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? 'REVOKE' : 'CONNECT',
                      style: AppTheme.monoStyle(
                        fontSize: 10,
                        color: isOnline ? Colors.redAccent.withOpacity(0.8) : AppColors.primaryTeal,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSignature() {
    return Center(
      child: Column(
        children: [
          Text('SILVERSYNC // v1.0.0', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal.withOpacity(0.25), letterSpacing: 2)),
          const SizedBox(height: 4),
          Text('PREMIUM EDITION ◈ SILVER WOLF', style: AppTheme.monoStyle(fontSize: 8, color: AppColors.primaryMagenta.withOpacity(0.2), letterSpacing: 2)),
        ],
      ),
    );
  }
}

class _NeonToggle extends StatelessWidget {
  final bool enabled;

  const _NeonToggle({required this.enabled});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 50,
      height: 26,
      decoration: BoxDecoration(
        color: enabled ? AppColors.primaryTeal.withOpacity(0.12) : AppColors.cardInner.withOpacity(0.8),
        border: Border.all(color: enabled ? AppColors.primaryTeal.withOpacity(0.5) : AppColors.textMuted.withOpacity(0.4)),
        boxShadow: enabled ? [
          BoxShadow(color: AppColors.primaryTeal.withOpacity(0.3), blurRadius: 12),
        ] : [],
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            top: 2,
            left: enabled ? 26 : 2,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: enabled ? AppColors.primaryTeal : AppColors.textMuted.withOpacity(0.6),
                boxShadow: enabled ? [
                  BoxShadow(color: AppColors.primaryTeal.withOpacity(0.9), blurRadius: 8),
                ] : [],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
