import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../models/ai_project_model.dart';
import '../../models/quick_audit_model.dart';
import '../../repositories/ai_compliance_repository.dart';
import '../copilot/copilot_floating_assistant.dart';
import '../copilot/professional_copilot_sheet.dart';

class ProfessionalProjectDetailsScreen extends StatefulWidget {
  final String projectId;

  const ProfessionalProjectDetailsScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<ProfessionalProjectDetailsScreen> createState() =>
      _ProfessionalProjectDetailsScreenState();
}

class _ProfessionalProjectDetailsScreenState
    extends State<ProfessionalProjectDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _repository = AiComplianceRepository();
  AiProjectModel? _project;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedBlockIndex = 0;
  Timer? _pollingTimer;
  late final AnimationController _borderAnimController;

  static const List<String> _disciplines = [
    'architectural',
    'structural',
    'mechanical',
    'electrical',
  ];

  static const List<String> _buildingClasses = [
    'Class A (Complex & Public Buildings)',
    'Class B (Residential & Commercial)',
    'Class C (Minor & Temporary Buildings)',
  ];

  @override
  void initState() {
    super.initState();
    _borderAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _loadDetails();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _borderAnimController.dispose();
    super.dispose();
  }

  bool get _hasProcessingDrawings {
    if (_project == null) return false;
    for (final block in _project!.blocks) {
      for (final drawing in block.drawings) {
        if (drawing.currentVersion != null &&
            drawing.currentVersion!.isProcessing) {
          return true;
        }
      }
    }
    return false;
  }

  bool get _isAnalysing =>
      _project != null &&
      (_project!.totalFloorAreaSqm <= 0 || _hasProcessingDrawings);

  void _syncPolling() {
    if (_isAnalysing) {
      if (_pollingTimer == null || !_pollingTimer!.isActive) {
        _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
          try {
            final p = await _repository.getProjectDetails(widget.projectId);
            if (mounted) {
              setState(() {
                _project = p;
                if (_selectedBlockIndex >= p.blocks.length) {
                  _selectedBlockIndex =
                      p.blocks.isEmpty ? 0 : p.blocks.length - 1;
                }
              });
              if (!_isAnalysing) {
                _pollingTimer?.cancel();
              }
            }
          } catch (_) {}
        });
      }
    } else {
      _pollingTimer?.cancel();
    }
  }

  Future<void> _loadDetails({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final p = await _repository.getProjectDetails(widget.projectId);
      if (mounted) {
        setState(() {
          _project = p;
          if (_selectedBlockIndex >= p.blocks.length) {
            _selectedBlockIndex = p.blocks.isEmpty ? 0 : p.blocks.length - 1;
          }
          _isLoading = false;
        });
        _syncPolling();
      }
    } catch (e) {
      if (mounted && !silent) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
          _isLoading = false;
        });
      }
    }
  }

  void _openCopilot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfessionalCopilotSheet(
        initialContextTitle:
            'Project: ${_project?.name ?? widget.projectId}',
        initialContextDescription:
            'Reference: ${_project?.referenceNumber ?? ""}, Class: ${_project?.occupancyClass ?? ""}, Blocks: ${_project?.blocks.length ?? 0}, GFA: ${_project?.totalFloorAreaSqm ?? 0} m²',
      ),
    );
  }

  Future<void> _showEditProjectDialog(AiProjectModel project) async {
    final nameCtrl = TextEditingController(text: project.name);
    String occupancy = _buildingClasses.contains(project.occupancyClass)
        ? project.occupancyClass!
        : _buildingClasses[1];
    String status = project.status;
    bool isPublic = project.isPublic;

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text(
            'Edit Project Settings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Project Name *',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: occupancy,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Building Class',
                  ),
                  items: _buildingClasses
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => occupancy = v);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: ['draft', 'in_progress', 'compliant', 'non_compliant']
                          .contains(status)
                      ? status
                      : 'draft',
                  decoration: const InputDecoration(
                    labelText: 'Project Status',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'draft', child: Text('Draft')),
                    DropdownMenuItem(
                        value: 'in_progress', child: Text('In Progress')),
                    DropdownMenuItem(
                        value: 'compliant', child: Text('Compliant')),
                    DropdownMenuItem(
                        value: 'non_compliant', child: Text('Non-Compliant')),
                  ],
                  onChanged: (v) {
                    if (v != null) setDialogState(() => status = v);
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Publicly Joinable via Share Token',
                    style: TextStyle(fontSize: 13),
                  ),
                  value: isPublic,
                  activeColor: AppTheme.primaryGreen,
                  onChanged: (v) => setDialogState(() => isPublic = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                try {
                  await _repository.updateProject(
                    projectId: project.id,
                    name: nameCtrl.text.trim(),
                    occupancyClass: occupancy,
                    isPublic: isPublic,
                    status: status,
                  );
                  if (context.mounted) Navigator.pop(context, true);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString().replaceAll('Exception:', '').trim(),
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );

    if (updated == true) _loadDetails();
  }

  Future<void> _showBlockDialog({AiBlockModel? existingBlock}) async {
    final isEdit = existingBlock != null;
    final nameCtrl = TextEditingController(text: existingBlock?.name ?? '');
    final descCtrl =
        TextEditingController(text: existingBlock?.description ?? '');

    final List<Map<String, TextEditingController>> floorRows = [];
    if (isEdit && existingBlock.floors.isNotEmpty) {
      for (final f in existingBlock.floors) {
        floorRows.add({
          'number': TextEditingController(text: f.floorNumber.toString()),
          'name': TextEditingController(text: f.floorName),
          'area': TextEditingController(
            text: f.grossFloorAreaSqm > 0
                ? f.grossFloorAreaSqm.toStringAsFixed(1)
                : '0',
          ),
        });
      }
    } else if (!isEdit) {
      floorRows.add({
        'number': TextEditingController(text: '0'),
        'name': TextEditingController(text: 'Ground Floor'),
        'area': TextEditingController(text: '0'),
      });
    }

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            isEdit ? 'Edit Block: ${existingBlock.name}' : 'Add Building Block',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Block Name *',
                      hintText: 'e.g. Block A - Commercial Podium',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'e.g. Retail & Office Wing',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'FLOOR SCHEDULE (JSONB)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            final nextNum = floorRows.length;
                            floorRows.add({
                              'number':
                                  TextEditingController(text: '$nextNum'),
                              'name': TextEditingController(
                                text: nextNum == 0
                                    ? 'Ground Floor'
                                    : 'Floor $nextNum',
                              ),
                              'area': TextEditingController(text: '0'),
                            });
                          });
                        },
                        icon: const Icon(Icons.add, size: 15),
                        label: const Text(
                          'Add Floor',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Note: Uploading an Architectural drawing automatically updates this floor schedule from the PDF sheets.',
                    style: TextStyle(fontSize: 10, color: AppTheme.textLight),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(floorRows.length, (idx) {
                    final row = floorRows[idx];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 46,
                            child: TextField(
                              controller: row['number'],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      signed: true),
                              style: const TextStyle(fontSize: 12),
                              decoration: const InputDecoration(
                                labelText: '#',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: row['name'],
                              style: const TextStyle(fontSize: 12),
                              decoration: const InputDecoration(
                                labelText: 'Floor Name',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: row['area'],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              style: const TextStyle(fontSize: 12),
                              decoration: const InputDecoration(
                                labelText: 'GFA (m²)',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: AppTheme.danger,
                              size: 18,
                            ),
                            onPressed: () {
                              setDialogState(() {
                                floorRows.removeAt(idx);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final List<Map<String, dynamic>> floorsPayload = [];
                for (int i = 0; i < floorRows.length; i++) {
                  final r = floorRows[i];
                  final numVal =
                      int.tryParse(r['number']!.text.trim()) ?? i;
                  final nameVal = r['name']!.text.trim().isNotEmpty
                      ? r['name']!.text.trim()
                      : (numVal == 0 ? 'Ground Floor' : 'Floor $numVal');
                  final areaVal =
                      double.tryParse(r['area']!.text.trim()) ?? 0.0;
                  floorsPayload.add({
                    'floor_number': numVal,
                    'floor_name': nameVal,
                    'name': nameVal,
                    'gross_floor_area_sqm': areaVal,
                  });
                }

                try {
                  if (isEdit) {
                    await _repository.updateBlock(
                      blockId: existingBlock.id,
                      name: nameCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      floors: floorsPayload,
                    );
                  } else {
                    await _repository.createBlock(
                      projectId: widget.projectId,
                      name: nameCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      floors: floorsPayload,
                    );
                  }
                  if (context.mounted) Navigator.pop(context, true);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString().replaceAll('Exception:', '').trim(),
                        ),
                      ),
                    );
                  }
                }
              },
              child: Text(isEdit ? 'Save Block' : 'Add Block'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) _loadDetails();
  }

  Future<void> _confirmDeleteBlock(AiBlockModel block) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Block?'),
        content: Text(
          'Are you sure you want to delete "${block.name}" and all its uploaded drawings? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _repository.deleteBlock(block.id);
        setState(() {
          _selectedBlockIndex = 0;
        });
        _loadDetails();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception:', '').trim()),
            ),
          );
        }
      }
    }
  }

  Future<void> _showBatchFloorsDialog(AiBlockModel block) async {
    final startCtrl = TextEditingController(text: '0');
    final endCtrl = TextEditingController(text: '4');

    final created = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Batch Generate Floors — ${block.name}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the lowest floor index (e.g. -1 for Basement, 0 for Ground Floor) and highest floor index.',
              style: TextStyle(fontSize: 12, color: AppTheme.textLight),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(signed: true),
                    decoration:
                        const InputDecoration(labelText: 'From Floor'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: endCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'To Floor'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final start = int.tryParse(startCtrl.text.trim()) ?? 0;
              final end = int.tryParse(endCtrl.text.trim()) ?? 1;
              try {
                await _repository.batchCreateFloors(
                  blockId: block.id,
                  startFloor: start,
                  endFloor: end,
                );
                if (context.mounted) Navigator.pop(context, true);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString().replaceAll('Exception:', '').trim(),
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (created == true) _loadDetails();
  }

  void _showDrawingFindingsSheet(
    AiBlockModel block,
    String discipline,
    AiDrawingModel drawing,
  ) {
    final version = drawing.currentVersion;
    final discrepancies = version?.complianceResult?.discrepancies ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        builder: (context, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${block.name} • ${discipline.toUpperCase()} (v${version?.versionNumber ?? 1})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            version?.originalName ?? 'drawing.pdf',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (drawing.versions.length > 1) ...[
                      const Text(
                        'VERSION HISTORY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryGreen,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: drawing.versions.map((v) {
                          final isCurrent = v.id == version?.id;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? AppTheme.primaryGreen
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.primaryGreen.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              'v${v.versionNumber} (${v.status.toUpperCase()})',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isCurrent
                                    ? Colors.white
                                    : AppTheme.textDark,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      'DETECTED DISCREPANCIES (${discrepancies.length})',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryGreen,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (discrepancies.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.verified,
                              color: AppTheme.primaryGreen,
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No regulatory discrepancies detected for this drawing version.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...discrepancies.map((d) => _buildDiscrepancyTile(d)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscrepancyTile(DiscrepancyModel d) {
    final isError = d.severity.toUpperCase() == 'ERROR' ||
        d.severity.toUpperCase() == 'HIGH' ||
        d.severity.toUpperCase() == 'CRITICAL';
    final color = isError ? AppTheme.danger : Colors.orange.shade800;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  d.ruleName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  d.severity.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (d.clauseReference != null && d.clauseReference!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Clause: ${d.clauseReference}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            d.description,
            style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
          ),
          if (d.requiredValue != null || d.observedValue != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                if (d.requiredValue != null)
                  Expanded(
                    child: Text(
                      'Required: ${d.requiredValue}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (d.observedValue != null)
                  Expanded(
                    child: Text(
                      'Observed: ${d.observedValue}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_project?.name ?? 'Project Workspace'),
        actions: [
          if (_project != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Project Settings',
              onPressed: () => _showEditProjectDialog(_project!),
            ),
            IconButton(
              icon: const Icon(Icons.analytics_outlined),
              tooltip: 'Consolidated Compliance Report',
              onPressed: () =>
                  context.push('/professional/projects/${_project!.id}/report'),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDetails,
          ),
        ],
        bottom: _isAnalysing
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: Colors.transparent,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          _buildBody(),
          CopilotFloatingAssistant(onTap: _openCopilot),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
      );
    }

    if (_errorMessage != null || _project == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.danger),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? 'Project not found',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final project = _project!;
    final blocks = project.blocks;
    final currentBlock =
        blocks.isNotEmpty ? blocks[_selectedBlockIndex] : null;
    final currencyFmt = NumberFormat('#,##0', 'en_US');

    return RefreshIndicator(
      onRefresh: _loadDetails,
      color: AppTheme.primaryGreen,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Live Polling Notice when any drawing is processing
          if (_hasProcessingDrawings) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F3E6D),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: const [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: AppTheme.accentGold,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AI Compliance Audit in progress... Automatically refreshing drawing status & floor areas.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 1. Project Header & Share Token Banner
          AnimatedBuilder(
            animation: _borderAnimController,
            builder: (context, child) {
              if (!_isAnalysing) return child!;
              return Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.5),
                  gradient: SweepGradient(
                    colors: const [
                      AppTheme.primaryGreen,
                      AppTheme.accentGold,
                      Colors.white,
                      AppTheme.accentGold,
                      AppTheme.primaryGreen,
                    ],
                    stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                    transform: GradientRotation(
                      _borderAnimController.value * 2 * math.pi,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentGold.withOpacity(0.35),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryGreen, Color(0xFF004d26)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                project.referenceNumber,
                                style: const TextStyle(
                                  color: AppTheme.accentGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            if (_isAnalysing) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGold.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.accentGold.withOpacity(0.6),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    SizedBox(
                                      width: 8,
                                      height: 8,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        color: AppTheme.accentGold,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'analysing..',
                                      style: TextStyle(
                                        color: AppTheme.accentGold,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: project.shareToken),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Share Token copied to clipboard!'),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.copy, size: 13, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Copy Share Token',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    project.occupancyClass ?? 'General Building',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PROJECT GFA',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isAnalysing && project.totalFloorAreaSqm <= 0
                                    ? 'Analysing.. (0 m²)'
                                    : '${currencyFmt.format(project.totalFloorAreaSqm)} m²',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          color: Colors.white24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'EST. STATUTORY FEE',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'UGX ${currencyFmt.format(project.estimatedStatutoryFeeUgx)}',
                                style: const TextStyle(
                                  color: AppTheme.accentGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGold,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () => context
                          .push('/professional/projects/${project.id}/report'),
                      icon: const Icon(Icons.verified_outlined, size: 18),
                      label: const Text(
                        'View Consolidated Compliance Report & Fees',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Blocks Tabs Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'BUILDING BLOCKS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryGreen,
                  letterSpacing: 1,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showBlockDialog(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  'Add Block',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (blocks.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('No blocks created yet.'),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showBlockDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Block'),
                  ),
                ],
              ),
            )
          else ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(blocks.length, (i) {
                  final b = blocks[i];
                  final selected = i == _selectedBlockIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        '${b.name} (${b.drawings.length}/4)',
                      ),
                      selected: selected,
                      selectedColor: AppTheme.primaryGreen,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppTheme.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedBlockIndex = i),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 14),

            // 3. Selected Block Details, Floor Schedule (JSONB), and Discipline Drawings
            if (currentBlock != null) ...[
              _buildSelectedBlockHeaderCard(currentBlock, blocks.length > 1),
              const SizedBox(height: 16),
              _buildBlockFloorScheduleCard(currentBlock),
              const SizedBox(height: 16),
              _buildBlockDrawingsSection(currentBlock),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedBlockHeaderCard(
    AiBlockModel block,
    bool canDelete,
  ) {
    final currencyFmt = NumberFormat('#,##0.#', 'en_US');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.domain,
              color: AppTheme.primaryGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  block.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppTheme.textDark,
                  ),
                ),
                if (block.description != null &&
                    block.description!.trim().isNotEmpty)
                  Text(
                    block.description!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textLight,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  'Block GFA: ${currencyFmt.format(block.totalFloorAreaSqm)} m²  •  ${block.floors.length} ${block.floors.length == 1 ? "Floor" : "Floors"}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_note,
              color: AppTheme.primaryGreen,
            ),
            tooltip: 'Edit Block & Floor Schedule',
            onPressed: () => _showBlockDialog(existingBlock: block),
          ),
          if (canDelete)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppTheme.danger,
              ),
              tooltip: 'Delete Block',
              onPressed: () => _confirmDeleteBlock(block),
            ),
        ],
      ),
    );
  }

  Widget _buildBlockFloorScheduleCard(AiBlockModel block) {
    final areaFmt = NumberFormat('#,##0.#', 'en_US');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.layers_outlined,
                    size: 16,
                    color: AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'FLOOR SCHEDULE (${block.floors.length})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryGreen,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _showBatchFloorsDialog(block),
                    child: const Text(
                      'Batch Generate',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _showBlockDialog(existingBlock: block),
                    child: const Text(
                      'Edit Floors',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (block.floors.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No floor schedule defined yet. Upload an Architectural drawing to auto-detect floors from PDF sheets, or tap "Edit Floors".',
                style: TextStyle(fontSize: 11, color: AppTheme.textLight),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: block.floors.map((floor) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        floor.floorName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      if (floor.grossFloorAreaSqm > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${areaFmt.format(floor.grossFloorAreaSqm)} m²',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildBlockDrawingsSection(AiBlockModel block) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ENGINEERING DRAWINGS — ${block.name.toUpperCase()}',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryGreen,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Upload multi-sheet PDF/CAD drawings per discipline. Uploading a new file automatically increments the version (v1 → v2) and triggers AI compliance auditing.',
          style: TextStyle(fontSize: 11, color: AppTheme.textLight),
        ),
        const SizedBox(height: 10),
        ..._disciplines.map((disc) => _buildDisciplineCard(block, disc)),
      ],
    );
  }

  Widget _buildDisciplineCard(AiBlockModel block, String disc) {
    final drawing = block.getDrawingForDiscipline(disc);
    final version = drawing?.currentVersion;
    final hasUploaded = version != null;
    final isProcessing = version?.isProcessing ?? false;
    final isFailed = version?.isFailed ?? false;
    final compliance = version?.complianceResult;
    final overallStatus = compliance?.overallStatus ?? version?.status ?? '';
    final discrepanciesCount = compliance?.discrepancies.length ?? 0;

    Color statusColor = Colors.grey;
    String badgeText = 'NOT UPLOADED';

    if (hasUploaded) {
      if (isProcessing) {
        statusColor = Colors.blue;
        badgeText = 'v${version.versionNumber} • ANALYSING...';
      } else if (isFailed) {
        statusColor = AppTheme.danger;
        badgeText = 'v${version.versionNumber} • FAILED';
      } else if (overallStatus == 'COMPLIANT') {
        statusColor = AppTheme.primaryGreen;
        badgeText = 'v${version.versionNumber} • COMPLIANT';
      } else if (overallStatus == 'NON_COMPLIANT') {
        statusColor = AppTheme.danger;
        badgeText =
            'v${version.versionNumber} • $discrepanciesCount VIOLATIONS';
      } else {
        statusColor = Colors.orange.shade800;
        badgeText = 'v${version.versionNumber} • ${overallStatus.toUpperCase()}';
      }
    }

    IconData discIcon;
    switch (disc) {
      case 'architectural':
        discIcon = Icons.architecture;
        break;
      case 'structural':
        discIcon = Icons.foundation;
        break;
      case 'mechanical':
        discIcon = Icons.plumbing;
        break;
      case 'electrical':
      default:
        discIcon = Icons.electrical_services;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasUploaded
              ? statusColor.withOpacity(0.35)
              : Colors.grey.shade200,
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
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(discIcon, color: statusColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          disc.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        if (disc == 'architectural') ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'EXTRACTS GFA & FLOORS',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasUploaded
                          ? version.originalName
                          : 'No $disc drawing uploaded for ${block.name}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (isFailed &&
              version?.errorMessage != null &&
              version!.errorMessage!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              version.errorMessage!,
              style: const TextStyle(fontSize: 11, color: AppTheme.danger),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (hasUploaded && drawing != null)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () =>
                      _showDrawingFindingsSheet(block, disc, drawing),
                  icon: const Icon(Icons.fact_check_outlined, size: 15),
                  label: Text(
                    'Findings (${compliance?.discrepancies.length ?? 0})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () async {
                  final uploaded = await context.push<bool>(
                    '/professional/drawings/upload',
                    extra: {
                      'blockId': block.id,
                      'blockName': block.name,
                      'discipline': disc,
                      'currentVersionNumber': version?.versionNumber ?? 0,
                    },
                  );
                  if (uploaded == true) {
                    _loadDetails();
                  }
                },
                icon: const Icon(Icons.upload_file, size: 15),
                label: Text(
                  hasUploaded
                      ? 'Upload v${version.versionNumber + 1}'
                      : 'Upload v1',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
