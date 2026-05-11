import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/angular_container.dart';

import '../providers/quota_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/storage_quota_card.dart';
import '../widgets/auth_node_card.dart';
import '../widgets/system_status_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              _buildHeader(),
              const SizedBox(height: 25),
              _buildModuleHeader('HOME // MODULE'),
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
                // Quota Section
                quotaAsync.when(
                  data: (quota) => StorageQuotaCard(quota: quota),
                  loading: () => const _LoadingPlaceholder(),
                  error: (_, __) => _buildOfflineStorageCard(ref),
                ),
                
                const SizedBox(height: 25),
                _buildSectionHeader('AUTH NODES'),
                const SizedBox(height: 15),
                
                // Auth Nodes Section
                authAsync.when(
                  data: (auth) => Column(
                    children: [
                      AuthNodeCard(
                        title: 'Spotify',
                        subtitle: auth.isSpotifyOnline ? 'OAuth 2.0 - Token Active' : 'Offline / No Token',
                        icon: FontAwesomeIcons.spotify,
                        isOnline: auth.isSpotifyOnline,
                      ),
                      const SizedBox(height: 12),
                      AuthNodeCard(
                        title: 'Google Drive',
                        subtitle: auth.isGoogleOnline ? 'Drive API v3 - Scopes OK' : 'Offline / No Scopes',
                        icon: FontAwesomeIcons.googleDrive,
                        isOnline: auth.isGoogleOnline,
                      ),
                    ],
                  ),
                  loading: () => const _LoadingPlaceholder(),
                  error: (_, __) => const Column(
                    children: [
                      AuthNodeCard(title: 'Spotify', subtitle: 'Connection Failed', icon: FontAwesomeIcons.spotify, isOnline: false),
                      SizedBox(height: 12),
                      AuthNodeCard(title: 'Google Drive', subtitle: 'Connection Failed', icon: FontAwesomeIcons.googleDrive, isOnline: false),
                    ],
                  ),
                ),
                
                const SizedBox(height: 25),
                
                // System Status Section
                authAsync.when(
                  data: (auth) => const SystemStatusCard(isApiOnline: true),
                  loading: () => const SystemStatusCard(isApiOnline: false),
                  error: (_, __) => const SystemStatusCard(isApiOnline: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SYS // ACTIVE', style: AppTheme.monoStyle(fontSize: 12, color: AppColors.primaryTeal.withOpacity(0.7))),
            const SizedBox(height: 4),
            Text('SILVERSYNC', style: AppTheme.darkTheme.textTheme.displayLarge?.copyWith(
              shadows: [const Shadow(color: AppColors.primaryTeal, blurRadius: 10)],
            )),
          ],
        ),
        Row(
          children: [
            _buildStatusBadge('LIVE', AppColors.primaryTeal),
            const SizedBox(width: 10),
            _buildSmallSquareBadge('SS'),
          ],
        ),
      ],
    );
  }

  Widget _buildModuleHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: AppColors.primaryTeal),
        const SizedBox(width: 10),
        Text(title, style: AppTheme.monoStyle(fontSize: 12, color: AppColors.textMain)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.white10)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(title, style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted)),
        ),
        Expanded(child: Container(height: 1, color: Colors.white10)),
      ],
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(text, style: AppTheme.monoStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSmallSquareBadge(String text) {
    return AngularContainer(
      cutSize: 4,
      width: 32,
      height: 32,
      child: Center(
        child: Text(text, style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal)),
      ),
    );
  }

  Widget _buildOfflineStorageCard(WidgetRef ref) {
    return AngularContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.cloud_off, size: 40, color: Colors.redAccent.withOpacity(0.8)),
          const SizedBox(height: 15),
          Text('API DISCONNECTED', style: AppTheme.monoStyle(fontSize: 16, color: Colors.redAccent, letterSpacing: 2)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.read(quotaProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh, size: 14),
            label: Text('RETRY CONNECTION', style: AppTheme.monoStyle(fontSize: 10)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withOpacity(0.1),
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal)),
      ),
    );
  }
}
