import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../repositories/ai_compliance_repository.dart';

class ProfessionalDrawingUploadScreen extends StatefulWidget {
  final String blockId;
  final String blockName;
  final String discipline;
  final int currentVersionNumber;

  const ProfessionalDrawingUploadScreen({
    super.key,
    required this.blockId,
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
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  bool _isUploading = false;

  bool get _hasSelectedFile =>
      _selectedFilePath != null || _selectedFileBytes != null;

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      setState(() {
        _selectedFilePath = kIsWeb ? null : file.path;
        _selectedFileBytes = file.bytes;
        _selectedFileName = file.name;
      });
    }
  }

  Future<void> _upload() async {
    if (!_hasSelectedFile) return;
    setState(() => _isUploading = true);
    try {
      await _repository.uploadDrawing(
        blockId: widget.blockId,
        discipline: widget.discipline,
        filePath: _selectedFilePath,
        fileBytes: _selectedFileBytes,
        fileName: _selectedFileName,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.primaryGreen,
            content: Text(
              '${widget.discipline.toUpperCase()} drawing (v${widget.currentVersionNumber + 1}) uploaded and queued for AI compliance audit.',
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.danger,
            content: Text(e.toString().replaceAll('Exception:', '').trim()),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextVersion = widget.currentVersionNumber + 1;
    final isArchitectural = widget.discipline.toLowerCase() == 'architectural';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Upload ${widget.discipline[0].toUpperCase()}${widget.discipline.substring(1)} Drawing',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppTheme.primaryGreen.withOpacity(0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.layers,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.blockName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Discipline: ${widget.discipline.toUpperCase()}  •  Target Version: v$nextVersion',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isArchitectural
                        ? AppTheme.primaryGreen.withOpacity(0.08)
                        : Colors.blue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isArchitectural ? Icons.straighten : Icons.info_outline,
                        size: 16,
                        color: isArchitectural
                            ? AppTheme.primaryGreen
                            : Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isArchitectural
                              ? 'Multi-floor PDF sheets supported: Uploading an Architectural drawing automatically extracts floor-by-floor details and recalculates the block & project Gross Floor Area (GFA) and Statutory Fee.'
                              : 'Uploading a new file for ${widget.discipline.toUpperCase()} automatically increments the drawing version to v$nextVersion and preserves previous versions.',
                          style: TextStyle(
                            fontSize: 11,
                            color: isArchitectural
                                ? AppTheme.primaryGreen
                                : Colors.blue.shade900,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _isUploading ? null : _pickFile,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _hasSelectedFile
                      ? AppTheme.primaryGreen
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _hasSelectedFile
                        ? Icons.task_alt
                        : Icons.upload_file_outlined,
                    size: 56,
                    color: AppTheme.primaryGreen,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _hasSelectedFile
                        ? (_selectedFileName ?? 'Selected PDF')
                        : 'Select Vector Drawing (PDF)',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'This upload will be recorded as Version v$nextVersion and automatically audited against the Uganda National Building Code.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: (!_hasSelectedFile || _isUploading)
                  ? null
                  : _upload,
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(
                _isUploading
                    ? 'Uploading & Triggering AI Audit...'
                    : 'Upload Version v$nextVersion & Run Audit',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
