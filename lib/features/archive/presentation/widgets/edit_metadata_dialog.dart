import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../providers/track_provider.dart';
import '../../data/models/track_model.dart';

class EditMetadataDialog extends ConsumerStatefulWidget {
  final TrackModel track;

  const EditMetadataDialog({super.key, required this.track});

  @override
  ConsumerState<EditMetadataDialog> createState() => _EditMetadataDialogState();
}

class _EditMetadataDialogState extends ConsumerState<EditMetadataDialog> {
  late TextEditingController _titleController;
  late TextEditingController _artistController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.track.title);
    _artistController = TextEditingController(text: widget.track.artist);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.surfaceBorder),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 30, offset: const Offset(0, 10)),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Metadata', style: AppTheme.darkTheme.textTheme.displaySmall),
            const SizedBox(height: 6),
            Text('Update track title and artist name.', style: AppTheme.darkTheme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            _buildField('Title', _titleController),
            const SizedBox(height: 16),
            _buildField('Artist', _artistController),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final api = ref.read(apiServiceProvider);
                    await updateTrackMetadata(
                      api,
                      ref,
                      widget.track.id,
                      _titleController.text.trim(),
                      _artistController.text.trim(),
                    );
                    if (mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        )),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
          ),
        ),
      ],
    );
  }
}
