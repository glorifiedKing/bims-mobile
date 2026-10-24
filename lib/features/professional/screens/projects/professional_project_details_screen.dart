import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme.dart';
import '../../models/ai_project_model.dart';
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
    extends State<ProfessionalProjectDetailsScreen> {
  final _repository = AiComplianceRepository();
  bool _isLoading = true;
  String? _errorMessage;
  AiProjectModel? _project;
  int _selectedBlockIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchProject();
  }

  Future<void> _fetchProject() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final p = await _repository.getProject(widget.projectId);
      if (mounted) {
        setState(() {
          _project = p;
          _isLoading = false;
          if (_selectedBlockIndex >= p.blocks.length) {
            _selectedBlockIndex = 0;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
          _isLoading = false;
        });
      }
    }
  }

  void _showAddBlockDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Estate Block', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Block Name *',
                hintText: 'e.g. Tower B, West Wing, Annex',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await _repository.createBlock(
                  projectId: widget.projectId,
                  name: name,
                  description: descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : null,
                );
                _fetchProject();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: '), backgroundColor: AppTheme.danger),
                  );
                }
              }
            },
            child: const Text('ADD BLOCK'),
          ),
        ],
      ),
    );
  }

  void _showAddFloorDialog(AiBlockModel block) {
    final numCtrl = TextEditingController(text: '1');
    final nameCtrl = TextEditingController(text: 'Floor 1');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Floor to ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: numCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Floor Number (e.g. 0 for Ground, -1 for Basement)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Floor Name (Optional)',
                hintText: 'e.g. Ground Floor, Mezzanine',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final numVal = int.tryParse(numCtrl.text.trim());
              if (numVal == null) return;
              Navigator.pop(ctx);
              try {
                await _repository.createFloor(
                  blockId: block.id,
                  floorNumber: numVal,
                  name: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : null,
                );
                _fetchProject();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: '), backgroundColor: AppTheme.danger),
                  );
                }
              }
            },
            child: const Text('ADD FLOOR'),
          ),
        ],
      ),
    );
  }

  void _showBatchCreateFloorsDialog(AiBlockModel block) {
    final startCtrl = TextEditingController(text: '1');
    final endCtrl = TextEditingController(text: '5');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.bolt, color: AppTheme.accentGold),
            SizedBox(width: 8),
            Text('Batch Generate Floors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Instantly generate a sequence of building levels (e.g. from -1 to 5):',
              style: TextStyle(fontSize: 12, color: AppTheme.textLight),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Start Floor',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: endCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'End Floor',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final start = int.tryParse(startCtrl.text.trim());
              final end = int.tryParse(endCtrl.text.trim());
              if (start == null || end == null || start > end) return;
              Navigator.pop(ctx);
              try {
                await _repository.batchCreateFloors(
                  blockId: block.id,
                  startFloor: start,
                  endFloor: end,
                );
                _fetchProject();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Batch creation failed: '), backgroundColor: AppTheme.danger),
                  );
                }
              }
            },
            child: const Text('GENERATE'),
          ),
        ],
      ),
    );
  }

  void _openCopilot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfessionalCopilotSheet(
        initialContextTitle: 'Project: ${_project?.name ?? widget.projectId}',
        initialContextDescription: 'Occupancy: ${_project?.occupancyClass ?? "N/A"}, Ref: ${_project?.referenceNumber ?? "N/A"}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_project?.name ?? 'Project Hierarchy'),
        actions: [
          if (_project != null)
            IconButton(
              icon: const Icon(Icons.summarize_outlined),
              tooltip: 'Consolidated Audit Report',
              onPressed: () {
                context.push('/professional/projects//report');
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchProject,
          ),
        ],
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
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.danger),
              const SizedBox(height: 12),
              Text('Unable to load project: ', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _fetchProject, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final project = _project!;
    final blocks = project.blocks;
    final currentBlock = blocks.isNotEmpty && _selectedBlockIndex < blocks.length
        ? blocks[_selectedBlockIndex]
        : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        // Project Overview Card
        _buildProjectHeaderCard(project),
        const SizedBox(height: 20),

        // Block Selector Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ESTATE BLOCKS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryGreen,
                letterSpacing: 1,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Block', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              onPressed: _showAddBlockDialog,
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Blocks Chip List
        SizedBox(
          height: 42,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: blocks.length + 1,
            itemBuilder: (context, idx) {
              if (idx == blocks.length) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: const Icon(Icons.add, size: 16),
                    label: const Text('New Block'),
                    onPressed: _showAddBlockDialog,
                  ),
                );
              }
              final b = blocks[idx];
              final isSelected = idx == _selectedBlockIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(b.name),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryGreen,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedBlockIndex = idx);
                  },
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 24),

        if (currentBlock != null) ...[
          // Floor management header for current block
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ' FLOORS ()',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryGreen,
                  letterSpacing: 1,
                ),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.bolt, size: 14, color: AppTheme.accentGold),
                    label: const Text('Batch', style: TextStyle(fontSize: 11)),
                    onPressed: () => _showBatchCreateFloorsDialog(currentBlock),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('Floor', style: TextStyle(fontSize: 11)),
                    onPressed: () => _showAddFloorDialog(currentBlock),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (currentBlock.floors.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.layers_clear, size: 40, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text('No Floors Configured in '),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.bolt),
                    label: const Text('Batch Generate Ground & Upper Floors'),
                    onPressed: () => _showBatchCreateFloorsDialog(currentBlock),
                  ),
                ],
              ),
            ),
          ] else ...[
            ...currentBlock.floors.map((floor) => _buildFloorCard(currentBlock, floor)),
          ],
        ],
      ],
    );
  }

  Widget _buildProjectHeaderCard(AiProjectModel project) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  project.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                icon: const Icon(Icons.picture_as_pdf, size: 14),
                label: const Text('REPORT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                onPressed: () {
                  context.push('/professional/projects//report');
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(project.referenceNumber, style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  project.occupancyClass,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF996500)),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  project.status.toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              const Icon(Icons.key, size: 13, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Share Token: ',
                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'monospace'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 14, color: AppTheme.primaryGreen),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: project.shareToken));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Project share token copied! Share with collaborators.')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloorCard(AiBlockModel block, AiFloorModel floor) {
    const disciplines = ['architectural', 'structural', 'mechanical', 'electrical'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
            child: Text(
              '',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
            ),
          ),
          title: Text(
            floor.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            'Floor Level ',
            style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  const Text(
                    'ENGINEERING DISCIPLINES',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ...disciplines.map((disc) {
                    final drawing = floor.getDrawingForDiscipline(disc);
                    return _buildDisciplineSlot(block, floor, disc, drawing);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisciplineSlot(
    AiBlockModel block,
    AiFloorModel floor,
    String discipline,
    AiDrawingModel? drawing,
  ) {
    IconData icon;
    String label;
    switch (discipline) {
      case 'architectural':
        icon = Icons.architecture;
        label = 'Architectural';
        break;
      case 'structural':
        icon = Icons.foundation;
        label = 'Structural';
        break;
      case 'mechanical':
        icon = Icons.hvac;
        label = 'Mechanical';
        break;
      default:
        icon = Icons.electric_bolt;
        label = 'Electrical';
    }

    final currentVersion = drawing?.currentVersion;
    final hasDrawing = currentVersion != null;

    Color badgeColor = Colors.grey;
    String badgeText = 'NO DRAWING';
    if (hasDrawing) {
      final status = (currentVersion.complianceResult?.overallStatus ?? currentVersion.status).toUpperCase();
      if (status == 'PASS' || status == 'COMPLIANT') {
        badgeColor = AppTheme.primaryGreen;
        badgeText = 'COMPLIANT';
      } else if (status == 'FAIL' || status == 'NON_COMPLIANT') {
        badgeColor = AppTheme.danger;
        badgeText = 'VIOLATIONS';
      } else if (status == 'PENDING' || status == 'PROCESSING') {
        badgeColor = Colors.blue;
        badgeText = 'ANALYZING...';
      } else {
        badgeColor = Colors.orange;
        badgeText = status;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: hasDrawing ? AppTheme.background : Colors.grey.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    if (hasDrawing) ...[
                      const SizedBox(width: 6),
                      Text(
                        'v',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                      ),
                    ],
                  ],
                ),
                if (hasDrawing && currentVersion.originalName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    currentVersion.originalName!,
                    style: const TextStyle(fontSize: 10, color: AppTheme.textLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: badgeColor.withOpacity(0.4)),
            ),
            child: Text(
              badgeText,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: badgeColor),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(hasDrawing ? Icons.history : Icons.upload_file, size: 18),
            color: AppTheme.primaryGreen,
            tooltip: hasDrawing ? 'Re-upload / Update Version' : 'Upload Drawing',
            onPressed: () async {
              final res = await context.push(
                '/professional/drawings/upload',
                extra: {
                  'floorId': floor.id,
                  'floorName': floor.name,
                  'blockName': block.name,
                  'discipline': discipline,
                  'currentVersionNumber': currentVersion?.versionNumber ?? 0,
                },
              );
              if (res == true && mounted) {
                _fetchProject();
              }
            },
          ),
        ],
      ),
    );
  }
}
