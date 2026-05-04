import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/angular_container.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quota_provider.dart';
import '../providers/auth_provider.dart';
import '../../data/models/quota_model.dart';

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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                quotaAsync.when(
                  data: (quota) => _buildStorageCard(quota),
                  loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal))),
                  error: (_, __) => _buildOfflineStorageCard(ref),
                ),
                const SizedBox(height: 25),
                _buildSectionHeader('AUTH NODES'),
                const SizedBox(height: 15),
                authAsync.when(
                  data: (auth) => Column(
                    children: [
                      _buildAuthNode('Spotify', auth.isSpotifyOnline ? 'OAuth 2.0 - Token Active' : 'Offline / No Token', FontAwesomeIcons.spotify, auth.isSpotifyOnline),
                      const SizedBox(height: 12),
                      _buildAuthNode('Google Drive', auth.isGoogleOnline ? 'Drive API v3 - Scopes OK' : 'Offline / No Scopes', FontAwesomeIcons.googleDrive, auth.isGoogleOnline),
                    ],
                  ),
                  loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal))),
                  error: (_, __) => Column(
                    children: [
                      _buildAuthNode('Spotify', 'Connection Failed', FontAwesomeIcons.spotify, false),
                      const SizedBox(height: 12),
                      _buildAuthNode('Google Drive', 'Connection Failed', FontAwesomeIcons.googleDrive, false),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                authAsync.when(
                  data: (auth) => _buildSystemStatus(isApiOnline: true),
                  loading: () => _buildSystemStatus(isApiOnline: false),
                  error: (_, __) => _buildSystemStatus(isApiOnline: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineStorageCard(WidgetRef ref) {
    return AngularContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 40, color: Colors.redAccent.withOpacity(0.8)),
          const SizedBox(height: 15),
          Text('API DISCONNECTED',
              style: AppTheme.monoStyle(fontSize: 16, color: Colors.redAccent, letterSpacing: 2)),
          const SizedBox(height: 5),
          Text('Unable to fetch storage quota',
              style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          // Retry button — triggers manual reconnect
          GestureDetector(
            onTap: () => ref.read(quotaProvider.notifier).refresh(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryTeal.withOpacity(0.4)),
                color: AppColors.primaryTeal.withOpacity(0.06),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 14, color: AppColors.primaryTeal.withOpacity(0.8)),
                  const SizedBox(width: 6),
                  Text('RETRY CONNECTION',
                      style: AppTheme.monoStyle(
                          fontSize: 10,
                          color: AppColors.primaryTeal.withOpacity(0.8),
                          letterSpacing: 1.5)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text('Auto-retrying every 5s...',
              style: AppTheme.monoStyle(fontSize: 9, color: AppColors.textMuted.withOpacity(0.4))),
        ],
      ),
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
              shadows: [
                const Shadow(color: AppColors.primaryTeal, blurRadius: 10),
              ],
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

  Widget _buildStatusBadge(String text, Color color) {
    return AngularContainer(
      cutSize: 4,
      isActive: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color, blurRadius: 4)],
            ),
          ),
          const SizedBox(width: 8),
          Text(text, style: AppTheme.monoStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSmallSquareBadge(String text) {
    return AngularContainer(
      cutSize: 4,
      width: 40,
      height: 40,
      child: Center(
        child: Text(text, style: AppTheme.monoStyle(fontSize: 12, color: AppColors.primaryTeal)),
      ),
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

  Widget _buildStorageCard(QuotaModel quota) {
    return AngularContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SYSTEM // STORAGE', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal)),
                  Text('Google Drive Quota', style: AppTheme.darkTheme.textTheme.bodyLarge),
                ],
              ),
              _buildSmallBadge('LIVE'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.primaryTeal.withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
                    BoxShadow(color: AppColors.primaryMagenta.withOpacity(0.1), blurRadius: 40, spreadRadius: -5),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: quota.usedPercentage / 100,
                        strokeWidth: 8,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Show full value + unit (e.g. "12.67 GB")
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(quota.usedShort, style: AppTheme.monoStyle(fontSize: 20, color: AppColors.primaryTeal, fontWeight: FontWeight.bold).copyWith(
                            shadows: [Shadow(color: AppColors.primaryTeal, blurRadius: 10)],
                          )),
                        ),
                        Text('OF ${quota.capacity}', style: AppTheme.monoStyle(fontSize: 8, color: AppColors.textMuted)),
                        const SizedBox(height: 2),
                        Text('${quota.usedPercentage.toStringAsFixed(1)}% USED', style: AppTheme.monoStyle(fontSize: 8, color: AppColors.primaryMagenta).copyWith(
                          shadows: [Shadow(color: AppColors.primaryMagenta, blurRadius: 8)],
                        )),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _buildQuotaInfo('CAPACITY', quota.capacity, AppColors.primaryTeal),
                    const SizedBox(height: 10),
                    // silversyncUsed now shows real folder size from backend
                    _buildQuotaInfo('LIBRARY SIZE', quota.silversyncUsed, AppColors.primaryMagenta),
                    const SizedBox(height: 10),
                    _buildQuotaInfo('FREE', quota.free, AppColors.primaryTeal),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(height: 4, width: double.infinity, color: Colors.white10),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 4,
                    width: constraints.maxWidth * (quota.usedPercentage / 100),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.primaryTeal, AppColors.primaryMagenta]),
                    ),
                  );
                }
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0 GB', style: AppTheme.monoStyle(fontSize: 8)),
              Text('${quota.usedPercentage.toStringAsFixed(1)}% ALLOCATED', style: AppTheme.monoStyle(fontSize: 8, color: AppColors.primaryTeal)),
              Text(quota.capacity, style: AppTheme.monoStyle(fontSize: 8)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaInfo(String label, String value, Color color) {
    return AngularContainer(
      cutSize: 6,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTheme.monoStyle(fontSize: 10, color: color, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(value, style: AppTheme.monoStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold).copyWith(
              shadows: [Shadow(color: color, blurRadius: 10)],
            )),
          ],
        ),
      ),
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

  Widget _buildAuthNode(String title, String subtitle, IconData icon, bool isOnline) {
    return AngularContainer(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: isOnline ? AppColors.primaryGreen : Colors.redAccent, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.darkTheme.textTheme.bodyLarge),
                Text(subtitle, style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(isOnline ? 'ONLINE' : 'OFFLINE', style: AppTheme.monoStyle(fontSize: 10, color: isOnline ? AppColors.primaryTeal : Colors.redAccent)),
              Icon(isOnline ? Icons.check_circle_outline : Icons.error_outline, color: isOnline ? AppColors.primaryTeal : Colors.redAccent, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatus({required bool isApiOnline}) {
    return AngularContainer(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          _buildStatusRow('SYNC_ENGINE', isApiOnline ? 'STANDBY' : 'OFFLINE', isApiOnline ? AppColors.primaryTeal : Colors.redAccent),
          const SizedBox(height: 8),
          _buildStatusRow('API_GATEWAY', isApiOnline ? 'NOMINAL' : 'UNREACHABLE', isApiOnline ? AppColors.primaryTeal : Colors.redAccent),
          const SizedBox(height: 8),
          _buildStatusRow('AUTH_SERVICE', isApiOnline ? 'ACTIVE' : 'OFFLINE', isApiOnline ? AppColors.primaryTeal : Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String status, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.monoStyle(fontSize: 10, color: color)),
        Row(
          children: [
            Icon(Icons.play_arrow, size: 12, color: color),
            const SizedBox(width: 4),
            SizedBox(
              width: 75,
              child: Text(status, style: AppTheme.monoStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryTeal.withOpacity(0.5)),
      ),
      child: Text(text, style: AppTheme.monoStyle(fontSize: 8, color: AppColors.primaryTeal)),
    );
  }
}
