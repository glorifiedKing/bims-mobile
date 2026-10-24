import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme.dart';
import '../../repositories/ai_compliance_repository.dart';

class ProfessionalQuickAuditUploadScreen extends StatefulWidget {
  const ProfessionalQuickAuditUploadScreen({super.key});

  @override
  State<ProfessionalQuickAuditUploadScreen> createState() =>
      _ProfessionalQuickAuditUploadScreenState();
}

class _ProfessionalQuickAuditUploadScreenState
    extends State<ProfessionalQuickAuditUploadScreen> {
  final _repository = AiComplianceRepository();

  String _discipline = 'architectural';
  String _occupancyClass = 'Class A (Residential)';
  String? _selectedFilePath;
  String? _selectedFileName;
  int? _selectedFileSize;
  bool _isUploading = false;
  String? _errorMessage;

  final List<Map<String, dynamic>> _disciplines = [
    {
      'id': 'architectural',
      'label': 'Architectural',
      'icon': Icons.architecture,
      'desc': 'Egress, door swing, room sizes, window/floor ventilation ratios & PWD access',
    },
    {
      'id': 'structural',
      'label': 'Structural',
      'icon': Icons.foundation,
      'desc': 'Column & beam schedules, grid lines, foundation & reinforcement notes',
    },
    {
      'id': 'mechanical',
      'label': 'Mechanical',
      'icon': Icons.hvac,
      'desc': 'HVAC, plumbing slopes, pipe sizing, storm-water & fire suppression systems',
    },
    {
      'id': 'electrical',
      'label': 'Electrical',
      'icon': Icons.electric_bolt,
      'desc': 'Power distribution, single-line diagrams, illumination & emergency lighting',
    },
  ];

  final List<String> _occupancyClasses = [
    'Class A (Residential)',
    'Class B (Commercial)',
    'Class C (Assembly)',
    'Class D (Industrial)',
    'Class E (Educational)',
    'Class F (Institutional)',
  ];

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // 50MB Limit
        const maxLimit = 50 * 1024 * 1024;
        if (file.size > maxLimit) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File exceeds statutory 50MB limit. Please select a smaller PDF.'),
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
          SnackBar(
            content: Text('Error selecting file: '),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  Future<void> _submitAudit() async {
    if (_selectedFilePath == null) {
      setState(() {
        _errorMessage = 'Please select a CAD/Revit PDF drawing to audit.';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      final audit = await _repository.submitQuickAudit(
        filePath: _selectedFilePath!,
        discipline: _discipline,
        occupancyClass: _occupancyClass,
      );

      if (mounted) {
        // Navigate to the live result polling screen
        context.pushReplacement('/professional/quick-audits/${audit.id}');
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
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('New Quick Audit'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header introduction
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryGreen.withOpacity(0.1),
                  AppTheme.accentGold.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.bolt, color: AppTheme.accentGold, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Instant AI Compliance Check',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Audits your 2D engineering submission directly against the Uganda National Building Code (2019) and Building Control Regulations (2020).',
                        style: TextStyle(fontSize: 12, color: AppTheme.textDark, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            '1. SELECT ENGINEERING DISCIPLINE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryGreen,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),

          // Discipline Selector
          ..._disciplines.map((d) {
            final isSelected = _discipline == d['id'];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryGreen : Colors.grey.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isSelected
                      ? AppTheme.primaryGreen
                      : Colors.grey.withOpacity(0.15),
                  child: Icon(
                    d['icon'] as IconData,
                    color: isSelected ? Colors.white : AppTheme.textDark,
                    size: 20,
                  ),
                ),
                title: Text(
                  d['label'] as String,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? AppTheme.primaryGreen : AppTheme.textDark,
                  ),
                ),
                subtitle: Text(
                  d['desc'] as String,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppTheme.primaryGreen)
                    : null,
                onTap: () {
                  setState(() {
                    _discipline = d['id'] as String;
                  });
                },
              ),
            );
          }),

          const SizedBox(height: 20),
          const Text(
            '2. BUILDING OCCUPANCY CLASS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryGreen,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.25)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _occupancyClass,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryGreen),
                items: _occupancyClasses.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _occupancyClass = val;
                    });
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            '3. SELECT DRAWING PDF (MAX 50MB)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryGreen,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),

          GestureDetector(
            onTap: _pickPdf,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedFilePath != null
                      ? AppTheme.primaryGreen
                      : AppTheme.accentGold.withOpacity(0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _selectedFilePath == null
                  ? Column(
                      children: const [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: AppTheme.accentGold,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Tap to select blueprint / CAD PDF',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Must contain vector lines, explicit scale bar, and readable text',
                          style: TextStyle(fontSize: 11, color: AppTheme.textLight),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf,
                            color: AppTheme.primaryGreen,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedFileName ?? 'selected.pdf',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ' MB • PDF',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _pickPdf,
                          child: const Text('Change'),
                        ),
                      ],
                    ),
            ),
          ),

          // Preflight notice
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Statutory Pre-Flight Criteria',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF856404),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '• Minimum 200 DPI resolution\n• Explicit numerical scale (e.g. 1:100, 1:50) or graphic scale bar\n• CAD-exported vector format is strongly recommended for millimetric accuracy.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF856404), height: 1.4),
                ),
              ],
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.danger.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.danger, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(fontSize: 12, color: AppTheme.danger),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _isUploading ? null : _submitAudit,
            child: _isUploading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('UPLOADING & DISPATCHING AI...'),
                    ],
                  )
                : const Text('RUN AI COMPLIANCE AUDIT'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
