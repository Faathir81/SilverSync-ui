import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../providers/track_provider.dart';
import '../../data/models/track_model.dart';

class EditMetadataDialog extends ConsumerStatefulWidget {
  final TrackModel track;

  const EditMetadataDialog({
    super.key,
    required this.track,
  });

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
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryMagenta.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(color: AppColors.primaryMagenta.withOpacity(0.1), blurRadius: 20),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EDIT METADATA',
              style: AppTheme.monoStyle(fontSize: 16, color: AppColors.primaryMagenta, letterSpacing: 2, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            _buildTextField('TITLE', _titleController),
            const SizedBox(height: 20),
            _buildTextField('ARTIST', _artistController),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('CANCEL', style: AppTheme.monoStyle(color: AppColors.textMuted)),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () async {
                    final api = ref.read(apiServiceProvider);
                    await updateTrackMetadata(
                      api, 
                      ref, 
                      widget.track.id, 
                      _titleController.text.trim(), 
                      _artistController.text.trim()
                    );
                    if (mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryMagenta,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('SAVE CHANGES', style: AppTheme.monoStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryMagenta.withOpacity(0.6))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: AppTheme.darkTheme.textTheme.bodyLarge,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.03),
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryMagenta)),
          ),
        ),
      ],
    );
  }
}
