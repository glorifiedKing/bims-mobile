import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../models/ai_project_model.dart';
import '../../repositories/ai_compliance_repository.dart';
import '../copilot/copilot_floating_assistant.dart';
import '../copilot/professional_copilot_sheet.dart';

class ProfessionalProjectsScreen extends StatefulWidget {
  const ProfessionalProjectsScreen({super.key});

  @override
  State<ProfessionalProjectsScreen> createState() =>
      _ProfessionalProjectsScreenState();
}

class _ProfessionalProjectsScreenState
    extends State<ProfessionalProjectsScreen> {
  final _repository = AiComplianceRepository();
  List<AiProjectModel> _projects = [];
  bool _isLoading = true;
  String? _errorMessage;

  static const List<String> _buildingClasses = [
    'Class A (Complex & Public Buildings)',
    'Class B (Residential & Commercial)',
    'Class C (Minor & Temporary Buildings)',
  ];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final list = await _repository.getProjects();
      if (mounted) {
        setState(() {
          _projects = list;
          _isLoading = false;
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

  void _openCopilot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProfessionalCopilotSheet(
        initialContextTitle: 'Collaborative Building Projects',
        initialContextDescription:
            'Multi-discipline project compliance, block & floor structures, and NBRB statutory rules.',
      ),
    );
  }

  Future<void> _showCreateProjectDialog() async {
    final nameCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    String occupancy = _buildingClasses[1]; // Class B default
    bool isPublic = false;

    final created = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Create New Building Project',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Project Name *',
                    hintText: 'e.g. Acacia Mall Extension',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: refCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Reference Number (Optional)',
                    hintText: 'Auto-generated if left blank',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: occupancy,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Building Class (Uganda Building Control Act)',
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
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Publicly Joinable via Token',
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
                  final project = await _repository.createProject(
                    name: nameCtrl.text.trim(),
                    referenceNumber: refCtrl.text.trim(),
                    occupancyClass: occupancy,
                    isPublic: isPublic,
                  );
                  if (context.mounted) {
                    Navigator.pop(context, true);
                    context.push('/professional/projects/${project.id}');
                  }
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
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (created == true) {
      _loadProjects();
    }
  }

  Future<void> _showJoinByTokenDialog() async {
    final tokenCtrl = TextEditingController();
    String selectedRole = 'architect';

    final joined = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Join Existing Project',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Avoid duplicate submissions! Enter the project share token provided by the project owner or lead consultant.',
                style: TextStyle(fontSize: 12, color: AppTheme.textLight),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: tokenCtrl,
                decoration: const InputDecoration(
                  labelText: 'Project Share Token *',
                  prefixIcon: Icon(Icons.vpn_key_outlined),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration:
                    const InputDecoration(labelText: 'Your Discipline Role'),
                items: const [
                  DropdownMenuItem(
                    value: 'architect',
                    child: Text('Architect'),
                  ),
                  DropdownMenuItem(
                    value: 'structural_eng',
                    child: Text('Structural Engineer'),
                  ),
                  DropdownMenuItem(
                    value: 'mep_eng',
                    child: Text('MEP Engineer'),
                  ),
                  DropdownMenuItem(
                    value: 'reviewer',
                    child: Text('Compliance Reviewer'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setDialogState(() => selectedRole = v);
                },
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
                if (tokenCtrl.text.trim().isEmpty) return;
                try {
                  final project = await _repository.joinProjectByToken(
                    tokenCtrl.text.trim(),
                    role: selectedRole,
                  );
                  if (context.mounted) {
                    Navigator.pop(context, true);
                    context.push('/professional/projects/${project.id}');
                  }
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
              child: const Text('Join Project'),
            ),
          ],
        ),
      ),
    );

    if (joined == true) {
      _loadProjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Building Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add_outlined),
            tooltip: 'Join via Share Token',
            onPressed: _showJoinByTokenDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        onPressed: _showCreateProjectDialog,
        icon: const Icon(Icons.add_business),
        label: const Text(
          'New Project',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.danger),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProjects,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProjects,
      color: AppTheme.primaryGreen,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Top action bar: Create vs Join
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showJoinByTokenDialog,
                  icon: const Icon(Icons.vpn_key_outlined, size: 18),
                  label: const Text('Join via Token'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryGreen,
                    side: const BorderSide(color: AppTheme.primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showCreateProjectDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create Project'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_projects.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: const [
                  Icon(
                    Icons.apartment,
                    size: 56,
                    color: AppTheme.primaryGreen,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No Collaborative Projects Yet',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Create a multi-block project or join an existing team using a share token to manage Architectural, Structural, Mechanical, and Electrical drawings together.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                  ),
                ],
              ),
            )
          else
            ..._projects.map((p) => _buildProjectCard(p)),
        ],
      ),
    );
  }

  Widget _buildProjectCard(AiProjectModel project) {
    final currencyFmt = NumberFormat('#,##0', 'en_US');
    final isCompliant = project.status == 'compliant';
    final statusColor = isCompliant
        ? AppTheme.primaryGreen
        : (project.status == 'non_compliant' ? AppTheme.danger : Colors.orange);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          await context.push('/professional/projects/${project.id}');
          _loadProjects();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      project.referenceNumber,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      project.status.toUpperCase().replaceAll('_', ' '),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                project.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                project.occupancyClass ?? 'General Building',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                ),
              ),
              if (project.totalFloorAreaSqm > 0 ||
                  project.estimatedStatutoryFeeUgx > 0) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.square_foot,
                        size: 14,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${currencyFmt.format(project.totalFloorAreaSqm)} m²',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.payments_outlined,
                        size: 14,
                        color: AppTheme.accentGold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'UGX ${currencyFmt.format(project.estimatedStatutoryFeeUgx)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Divider(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.domain,
                        size: 15,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${project.blocksCount} ${project.blocksCount == 1 ? "Block" : "Blocks"}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
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
                          context.push(
                            '/professional/projects/${project.id}/report',
                          );
                        },
                        icon: const Icon(
                          Icons.analytics_outlined,
                          size: 14,
                          color: AppTheme.primaryGreen,
                        ),
                        label: const Text(
                          'Report',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 13,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
