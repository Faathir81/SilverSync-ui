import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/angular_container.dart';
import '../../../../core/services/api_service.dart';
import '../../data/models/sync_log_model.dart';
import '../providers/sync_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SyncPage extends ConsumerStatefulWidget {
  const SyncPage({super.key});

  @override
  ConsumerState<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends ConsumerState<SyncPage> {
  final _urlController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMsg;
  SyncLogModel? _currentJob;
  Timer? _pollTimer;

  @override
  void dispose() {
    _urlController.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _startSync() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _errorMsg = 'URL is required');
      return;
    }
    if (!url.contains('open.spotify.com')) {
      setState(() => _errorMsg = 'Must be a valid Spotify URL');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMsg = null;
      _currentJob = null;
    });

    try {
      final api = ref.read(apiServiceProvider);
      final job = await initiateSync(api, url);
      setState(() {
        _currentJob = job;
        _isSubmitting = false;
        _urlController.clear();
      });
      _startPolling(job.id);
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMsg = 'Sync failed: ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  void _startPolling(int jobId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      try {
        final api = ref.read(apiServiceProvider);
        final response = await api.getSyncStatus(jobId.toString());
        if (response.statusCode == 200) {
          final updated = SyncLogModel.fromJson(response.data);
          if (mounted) setState(() => _currentJob = updated);
          if (updated.isDone || updated.isFailed) {
            _pollTimer?.cancel();
          }
        }
      } catch (_) {
        _pollTimer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
              _buildModuleHeader('SYNC // MODULE'),
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
                _buildSyncInputCard(),
                if (_errorMsg != null) ...[
                  const SizedBox(height: 10),
                  _buildErrorBanner(_errorMsg!),
                ],
                const SizedBox(height: 30),
                _buildSectionHeader('LIVE ACTIVITY'),
                const SizedBox(height: 15),
                if (_currentJob == null)
                  _buildEmptyActivityState()
                else
                  _buildActivityCard(_currentJob!),
              ],
            ),
          ),
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

  Widget _buildSyncInputCard() {
    return AngularContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('INGEST // SPOTIFY ENDPOINT', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal)),
          const SizedBox(height: 4),
          Text('Sync to Drive', style: AppTheme.darkTheme.textTheme.bodyLarge),
          const SizedBox(height: 5),
          Text('Supports track & playlist URLs', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted.withOpacity(0.6))),
          const SizedBox(height: 20),
          _buildUrlInput(),
          const SizedBox(height: 15),
          _buildSyncButton(),
        ],
      ),
    );
  }

  Widget _buildUrlInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: AppColors.primaryTeal.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: TextField(
        controller: _urlController,
        style: AppTheme.monoStyle(color: AppColors.primaryTeal),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'open.spotify.com/track/... or /playlist/...',
          hintStyle: AppTheme.monoStyle(color: AppColors.primaryTeal.withOpacity(0.3)),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text('URL://', style: AppTheme.monoStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      ),
    );
  }

  Widget _buildSyncButton() {
    return GestureDetector(
      onTap: _isSubmitting ? null : _startSync,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isSubmitting ? 0.5 : 1.0,
        child: AngularContainer(
          cutSize: 8,
          isActive: !_isSubmitting,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isSubmitting) ...[
                const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
                  ),
                ),
                const SizedBox(width: 10),
                Text('QUEUING...', style: AppTheme.monoStyle(fontSize: 14, color: AppColors.primaryTeal, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ] else ...[
                const Icon(FontAwesomeIcons.bolt, size: 16, color: AppColors.primaryTeal),
                const SizedBox(width: 10),
                Text('INITIATE SYNC', style: AppTheme.monoStyle(fontSize: 14, color: AppColors.primaryTeal, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(width: 10),
                const Icon(Icons.send_rounded, size: 16, color: AppColors.primaryTeal),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String msg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.05),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 14),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: AppTheme.monoStyle(fontSize: 10, color: Colors.redAccent))),
        ],
      ),
    );
  }

  Widget _buildEmptyActivityState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.radar, size: 40, color: AppColors.primaryTeal.withOpacity(0.3)),
            const SizedBox(height: 15),
            Text('NO ACTIVE SYNC TASKS', style: AppTheme.monoStyle(fontSize: 14, color: AppColors.textMuted, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(SyncLogModel job) {
    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    if (job.isDone) {
      statusColor = AppColors.primaryGreen;
      statusIcon = Icons.check_circle_outline;
      statusLabel = 'DONE';
    } else if (job.isFailed) {
      statusColor = Colors.redAccent;
      statusIcon = Icons.cancel_outlined;
      statusLabel = 'FAILED';
    } else if (job.isRunning) {
      statusColor = AppColors.primaryTeal;
      statusIcon = Icons.upload_rounded;
      statusLabel = job.status;
    } else {
      statusColor = AppColors.primaryMagenta;
      statusIcon = Icons.access_time;
      statusLabel = 'QUEUED';
    }

    return AngularContainer(
      cutSize: 6,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 3, height: 40, color: statusColor),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('JOB #${job.id}', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted)),
                    Text(
                      job.spotifyUrl.length > 45 ? '${job.spotifyUrl.substring(0, 45)}...' : job.spotifyUrl,
                      style: AppTheme.monoStyle(fontSize: 11, color: AppColors.textMain),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  border: Border.all(color: statusColor.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (job.isRunning)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: SizedBox(
                          width: 10, height: 10,
                          child: CircularProgressIndicator(strokeWidth: 1.5, valueColor: AlwaysStoppedAnimation(statusColor)),
                        ),
                      )
                    else
                      Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 6),
                    Text(statusLabel, style: AppTheme.monoStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          if (job.message.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              color: Colors.white.withOpacity(0.02),
              child: Text(job.message, style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted.withOpacity(0.8))),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primaryTeal, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Text(title, style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMain, letterSpacing: 2)),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: Colors.white10)),
      ],
    );
  }
}
