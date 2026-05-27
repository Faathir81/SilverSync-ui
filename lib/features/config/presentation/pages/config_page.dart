import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/angular_container.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../dashboard/presentation/providers/quota_provider.dart';

import '../../../dashboard/presentation/providers/auth_provider.dart';
import '../widgets/auth_button.dart';

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
              Text('SILVERSYNC', style: AppTheme.darkTheme.textTheme.displayLarge?.copyWith(
                shadows: [const Shadow(color: AppColors.primaryTeal, blurRadius: 10)],
              )),
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
            _buildApiStatusRow(isApiOnline),
          ]
        ],
      ),
    );
  }

  Widget _buildApiStatusRow(bool isOnline) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOnline ? AppColors.primaryGreen.withOpacity(0.05) : Colors.redAccent.withOpacity(0.05),
        border: Border.all(color: isOnline ? AppColors.primaryGreen.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(isOnline ? Icons.wifi : Icons.wifi_off, color: isOnline ? AppColors.primaryGreen : Colors.redAccent, size: 14),
          const SizedBox(width: 10),
          Text(isOnline ? 'ALL SERVICES NOMINAL' : 'API OFFLINE', style: AppTheme.monoStyle(fontSize: 10, color: isOnline ? AppColors.primaryGreen : Colors.redAccent)),
        ],
      ),
    );
  }

  Widget _buildToggleRow(IconData icon, Color iconColor, String title, String subtitle, bool enabled, Function(bool) onToggle) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
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
        Switch(
          value: enabled,
          onChanged: onToggle,
          activeColor: AppColors.primaryTeal,
        ),
      ],
    );
  }

  Widget _buildRuntimeMetrics(AsyncValue quotaAsync) {
    String driveQuota = quotaAsync.maybeWhen(data: (q) => '${q.usedPercentage.toStringAsFixed(1)}%', orElse: () => 'N/A');
    return AngularContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('◈ RUNTIME METRICS', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal.withOpacity(0.4), letterSpacing: 2)),
          const SizedBox(height: 15),
          _buildMetricRow('SYNC_ENGINE_v', '2.4.1'),
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
          Text(key, style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted.withOpacity(0.5))),
          Text(value, style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal)),
        ],
      ),
    );
  }

  Widget _buildAuthNodes(AsyncValue<AuthStatus> authAsync) {
    final status = authAsync.maybeWhen(data: (d) => d, orElse: () => null);
    final isLoading = authAsync is AsyncLoading;

    return AngularContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('◈ AUTH NODES', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal.withOpacity(0.4), letterSpacing: 2)),
          const SizedBox(height: 15),
          AuthButton(
            name: 'Spotify',
            icon: FontAwesomeIcons.spotify,
            accentColor: const Color(0xFF1DB954),
            isOnline: status?.isSpotifyOnline ?? false,
            isLoading: isLoading,
            onConnect: () => _openUrl('${AppConstants.baseUrl}/auth/login'),
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
            isOnline: status?.isGoogleOnline ?? false,
            isLoading: isLoading,
            onConnect: () => _openUrl('${AppConstants.baseUrl}/auth/google/login'),
            onRefresh: () => ref.invalidate(authStatusProvider),
            onRevoke: () async {
              await ref.read(apiServiceProvider).logoutGoogle();
              ref.invalidate(authStatusProvider);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      await Future.delayed(const Duration(seconds: 5));
      if (mounted) ref.invalidate(authStatusProvider);
    }
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
