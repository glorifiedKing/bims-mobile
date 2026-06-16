import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme.dart';
import '../bloc/attachments/professional_attachments_bloc.dart';
import '../bloc/attachments/professional_attachments_event.dart';
import '../bloc/attachments/professional_attachments_state.dart';
import '../models/pro_attachment_model.dart';
import '../models/pro_attachment_type_model.dart';

class ProfessionalUploadAttachmentScreen extends StatefulWidget {
  final ProAttachmentModel? attachment;

  const ProfessionalUploadAttachmentScreen({super.key, this.attachment});

  @override
  State<ProfessionalUploadAttachmentScreen> createState() =>
      _ProfessionalUploadAttachmentScreenState();
}

class _ProfessionalUploadAttachmentScreenState
    extends State<ProfessionalUploadAttachmentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _referenceController = TextEditingController();
  final _particularsController = TextEditingController();
  final _clientDetailsController = TextEditingController();

  List<ProAttachmentTypeModel> _types = [];
  ProAttachmentTypeModel? _selectedType;
  bool _isLoadingTypes = false;

  String? _selectedFilePath;
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  int? _selectedFileSize;

  bool _isSubmitting = false;
  bool _isEditMode = false;

  bool get _hasSelectedFile =>
      _selectedFilePath != null || _selectedFileBytes != null;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.attachment != null;

    if (_isEditMode) {
      _particularsController.text = widget.attachment!.particulars;
      // Note: reference and clientDetails are not returned in the GET response,
      // so they will start empty, which is normal.
    }

    // Trigger types fetch on load
    context.read<ProfessionalAttachmentsBloc>().add(
      FetchProfessionalAttachmentTypes(),
    );
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _particularsController.dispose();
    _clientDetailsController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // 25MB Limit Check (25 * 1024 * 1024 bytes)
        const maxLimit = 25 * 1024 * 1024;
        if (file.size > maxLimit) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'File size exceeds 25MB limit. Please select a smaller PDF.',
                ),
                backgroundColor: AppTheme.danger,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedFilePath = file.path;
          _selectedFileBytes = file.bytes;
          _selectedFileName = file.name;
          _selectedFileSize = file.size;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an attachment type.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    if (!_isEditMode && !_hasSelectedFile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a PDF document.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    if (_isEditMode) {
      context.read<ProfessionalAttachmentsBloc>().add(
        EditProfessionalAttachment(
          id: widget.attachment!.id,
          attachmentType: _selectedType!.id,
          reference: _referenceController.text.trim(),
          particulars: _particularsController.text.trim(),
          clientDetails: _clientDetailsController.text.trim(),
          documentPath: _selectedFilePath,
          documentBytes: _selectedFileBytes,
          fileName: _selectedFileName,
        ),
      );
    } else {
      context.read<ProfessionalAttachmentsBloc>().add(
        UploadProfessionalAttachment(
          attachmentType: _selectedType!.id,
          reference: _referenceController.text.trim(),
          particulars: _particularsController.text.trim(),
          clientDetails: _clientDetailsController.text.trim(),
          documentPath: _selectedFilePath,
          documentBytes: _selectedFileBytes,
          fileName: _selectedFileName,
        ),
      );
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = 0;
    double dBytes = bytes.toDouble();
    while (dBytes >= 1024 && i < suffixes.length - 1) {
      dBytes /= 1024;
      i++;
    }
    return "${dBytes.toStringAsFixed(2)} ${suffixes[i]}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Attachment' : 'Upload Attachment',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(false),
        ),
      ),
      body: BlocListener<ProfessionalAttachmentsBloc, ProfessionalAttachmentsState>(
        listener: (context, state) {
          if (state is AttachmentTypesLoading) {
            setState(() {
              _isLoadingTypes = true;
            });
          } else if (state is AttachmentTypesLoaded) {
            setState(() {
              _types = state.types;
              _isLoadingTypes = false;

              // If in Edit Mode, match the type by title
              if (_isEditMode && _selectedType == null) {
                final matched = _types.firstWhere(
                  (type) =>
                      type.title.toLowerCase() ==
                      widget.attachment!.attachmentType.toLowerCase(),
                  orElse: () => _types.first,
                );
                _selectedType = matched;
              } else if (_types.isNotEmpty && _selectedType == null) {
                _selectedType = _types.first;
              }
            });
          } else if (state is AttachmentTypesError) {
            setState(() {
              _isLoadingTypes = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to load attachment types: ${state.message}',
                ),
                backgroundColor: AppTheme.danger,
              ),
            );
          } else if (state is AttachmentSubmissionLoading) {
            setState(() {
              _isSubmitting = true;
            });
          } else if (state is AttachmentSubmissionSuccess) {
            setState(() {
              _isSubmitting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.primaryGreen,
              ),
            );
            context.pop(true);
          } else if (state is AttachmentSubmissionError) {
            setState(() {
              _isSubmitting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.danger,
              ),
            );
          }
        },
        child: _isSubmitting
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryGreen),
                    SizedBox(height: 16),
                    Text(
                      'Uploading your design. Please wait...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppTheme.primaryGreen,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _isEditMode
                                    ? 'Modify your design details. File replacement is optional.'
                                    : 'Upload your architectural drawings or structural designs in PDF format (Max 25MB).',
                                style: const TextStyle(
                                  color: AppTheme.primaryGreen,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Form Fields
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFEEEEEE)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Type selection
                              const Text(
                                'Attachment Type *',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _isLoadingTypes
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(
                                          color: AppTheme.primaryGreen,
                                        ),
                                      ),
                                    )
                                  : DropdownButtonFormField<
                                      ProAttachmentTypeModel
                                    >(
                                      value: _selectedType,
                                      items: _types
                                          .map(
                                            (type) =>
                                                DropdownMenuItem<
                                                  ProAttachmentTypeModel
                                                >(
                                                  value: type,
                                                  child: Text(
                                                    type.title,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                          )
                                          .toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedType = val;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: AppTheme.primaryGreen,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                              const SizedBox(height: 20),

                              // Reference field
                              const Text(
                                'Reference Number *',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _referenceController,
                                decoration: InputDecoration(
                                  hintText: 'e.g. 12345',
                                  prefixIcon: const Icon(
                                    Icons.bookmark_border,
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppTheme.primaryGreen,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Reference number is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Particulars field
                              const Text(
                                'Particulars *',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _particularsController,
                                minLines: 3,
                                maxLines: 5,
                                decoration: InputDecoration(
                                  hintText:
                                      'Describe the plans, project title, size, or specifics...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppTheme.primaryGreen,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Particulars are required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Client details field
                              const Text(
                                'Client Details *',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _clientDetailsController,
                                minLines: 2,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText:
                                      'Enter developer name, phone number, email or physical address...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppTheme.primaryGreen,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Client details are required';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Document Selector Card
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFEEEEEE)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _isEditMode
                                        ? 'Replace Document'
                                        : 'Document File *',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (_isEditMode)
                                    const Text(
                                      '(Optional)',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              if (_isEditMode && !_hasSelectedFile) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.picture_as_pdf,
                                        color: Colors.grey,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          widget.attachment!.attachmentFile,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              InkWell(
                                onTap: _pickFile,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _hasSelectedFile
                                        ? AppTheme.primaryGreen.withOpacity(
                                            0.02,
                                          )
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _hasSelectedFile
                                          ? AppTheme.primaryGreen
                                          : Colors.grey.shade300,
                                      style: _hasSelectedFile
                                          ? BorderStyle.solid
                                          : BorderStyle.none,
                                    ),
                                  ),
                                  child: _hasSelectedFile
                                      ? Column(
                                          children: [
                                            const Icon(
                                              Icons.picture_as_pdf,
                                              color: AppTheme.primaryGreen,
                                              size: 48,
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              _selectedFileName ?? '',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _selectedFileSize != null
                                                  ? _formatBytes(
                                                      _selectedFileSize!,
                                                    )
                                                  : '',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            const Text(
                                              'Tap to change file',
                                              style: TextStyle(
                                                color: AppTheme.primaryGreen,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Icon(
                                              Icons.cloud_upload_outlined,
                                              color: Colors.grey.shade400,
                                              size: 48,
                                            ),
                                            const SizedBox(height: 12),
                                            const Text(
                                              'Tap to browse design PDF file',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Supported format: PDF. Maximum size: 25 MB.',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit button
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _isEditMode ? 'Update Design' : 'Upload Design',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
