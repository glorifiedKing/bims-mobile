import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../repositories/ai_compliance_repository.dart';

class ProfessionalDrawingUploadScreen extends StatefulWidget {
  final String floorId;
  final String floorName;
  final String blockName;
  final String discipline;
  final int currentVersionNumber;

  const ProfessionalDrawingUploadScreen({
    super.key,
    required this.floorId,
    required this.floorName,
    required this.blockName,
    required this.discipline,
    this.currentVersionNumber = 0,
  });

  @override
  State<ProfessionalDrawingUploadScreen> createState() =>
      _ProfessionalDrawingUploadScreenState();
}

class _ProfessionalDrawingUploadScreenState
    extends State<ProfessionalDrawingUploadScreen> {
  final _repository = AiComplianceRepository();
  String? _selectedFilePath;
  String? _selectedFileName;
  int? _selectedFileSize;
  bool _isUploading = false;
  String? _errorMessage;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        const maxLimit = 50 * 1024 * 1024;
        if (file.size > maxLimit) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File exceeds 50MB statutory limit.'),
                backgroundColor: AppTheme.danger,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedFilePath = file.path;
          _selectedFileName = file.name;
          _selectedFileSize = file.size;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting file: '), backgroundColor: AppTheme.danger),
        );
      }
    }
  }

  Future<void> _upload() async {
    if (_selectedFilePath == null) {
      setState(() => _errorMessage = 'Please select a drawing PDF file to upload.');
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      await _repository.uploadDrawing(
        floorId: widget.floorId,
        discipline: widget.discipline,
        filePath: _selectedFilePath!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Drawing uploaded successfully! AI compliance check dispatched.'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextVersion = widget.currentVersionNumber + 1;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Upload  Drawing'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ' • ',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Target Version: v$nextVersion',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Discipline: ',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
                ),
                if (widget.currentVersionNumber > 0) ...[
                  const SizedBox(height: 6),
                  const Text(
                    'Note: Re-uploading does not overwrite historical records. It archives v1.0 and creates incremental version v.',
                    style: TextStyle(fontSize: 11, color: Colors.blueGrey),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // File Picker
          const Text(
            'SELECT PDF BLUEPRINT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryGreen,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),

          GestureDetector(
            onTap: _pickFile,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedFilePath != null ? AppTheme.primaryGreen : AppTheme.accentGold,
                  width: 1.5,
                ),
              ),
              child: _selectedFilePath == null
                  ? Column(
                      children: const [
                        Icon(Icons.cloud_upload_outlined, size: 48, color: AppTheme.accentGold),
                        SizedBox(height: 12),
                        Text('Tap to pick engineering PDF (Max 50MB)', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Requires vector lines, scale bar, and readable text', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    )
                  : Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, color: AppTheme.primaryGreen, size: 36),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedFileName ?? 'drawing.pdf',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text('${((_selectedFileSize ?? 0) / (1024 * 1024)).toStringAsFixed(2)} MB'),
                            ],
                          ),
                        ),
                        TextButton(onPressed: _pickFile, child: const Text('Change')),
                      ],
                    ),
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_errorMessage!, style: const TextStyle(color: AppTheme.danger, fontSize: 12)),
            ),
          ],

          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _isUploading ? null : _upload,
            child: _isUploading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                      SizedBox(width: 12),
                      Text('UPLOADING & CHECKING...'),
                    ],
                  )
                : Text('UPLOAD DRAWING (VERSION $nextVersion)'),
          ),
        ],
      ),
    );
  }
}
