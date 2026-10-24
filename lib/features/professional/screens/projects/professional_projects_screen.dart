import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme.dart';
import '../../models/ai_project_model.dart';
import '../../repositories/ai_compliance_repository.dart';
import '../copilot/copilot_floating_assistant.dart';

class ProfessionalProjectsScreen extends StatefulWidget {
  const ProfessionalProjectsScreen({super.key});

  @override
  State<ProfessionalProjectsScreen> createState() =>
      _ProfessionalProjectsScreenState();
}

class _ProfessionalProjectsScreenState
    extends State<ProfessionalProjectsScreen> {
  final _repository = AiComplianceRepository();
  bool _isLoading = true;
  String? _errorMessage;
  List<AiProjectModel> _projects = [];

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

  void _showCreateProjectDialog() {
    final nameController = TextEditingController();
    final refController = TextEditingController();
    String occupancy = 'Class A (Residential)';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.add_business, color: AppTheme.primaryGreen),
              SizedBox(width: 8),
              Text('Create New Project', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Registers project with automated multi-block and floor hierarchy.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Project Name *',
                      hintText: 'e.g. Kampala Heights Commercial Tower',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Project name is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: refController,
                    decoration: const InputDecoration(
                      labelText: 'Reference Number (Optional)',
                      hintText: 'e.g. NBRB-KLA-2026-081',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Occupancy Class', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: occupancy,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'Class A (Residential)', child: Text('Class A (Residential)')),
                      DropdownMenuItem(value: 'Class B (Commercial)', child: Text('Class B (Commercial)')),
                      DropdownMenuItem(value: 'Class C (Assembly)', child: Text('Class C (Assembly)')),
                      DropdownMenuItem(value: 'Class D (Industrial)', child: Text('Class D (Industrial)')),
                      DropdownMenuItem(value: 'Class E (Educational)', child: Text('Class E (Educational)')),
                      DropdownMenuItem(value: 'Class F (Institutional)', child: Text('Class F (Institutional)')),
                    ],
                    onChanged: (v) {
                      if (v != null) setDialogState(() => occupancy = v);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(dialogCtx);
                  setState(() => _isLoading = true);
                  try {
                    final created = await _repository.createProject(
                      name: nameController.text.trim(),
                      referenceNumber: refController.text.trim().isNotEmpty ? refController.text.trim() : null,
                      occupancyClass: occupancy,
                    );
                    _loadProjects();
                    if (mounted) {
                      context.push('/professional/projects/');
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed: '), backgroundColor: AppTheme.danger),
                      );
                      setState(() => _isLoading = false);
                    }
                  }
                }
              },
              child: const Text('CREATE'),
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinProjectDialog() {
    final tokenController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.link, color: AppTheme.accentGold),
            SizedBox(width: 8),
            Text('Join Project via Token', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the secure 32-character anti-duplication token generated by the Project Lead:',
              style: TextStyle(fontSize: 12, color: AppTheme.textLight),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: tokenController,
              decoration: const InputDecoration(
                labelText: 'Share Token',
                hintText: 'Paste token here',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final token = tokenController.text.trim();
              if (token.isEmpty) return;
              Navigator.pop(dialogCtx);
              setState(() => _isLoading = true);
              try {
                final project = await _repository.joinProject(token);
                _loadProjects();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Successfully joined !'), backgroundColor: AppTheme.primaryGreen),
                  );
                  context.push('/professional/projects/');
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Join failed: '), backgroundColor: AppTheme.danger),
                  );
                  setState(() => _isLoading = false);
                }
              }
            },
            child: const Text('JOIN'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('AI Compliance Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.link),
            tooltip: 'Join Project via Token',
            onPressed: _showJoinProjectDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects,
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadProjects,
            color: AppTheme.primaryGreen,
            child: _buildBody(),
          ),
          const CopilotFloatingAssistant(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('NEW PROJECT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        onPressed: _showCreateProjectDialog,
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
              Text(
                'Unable to load projects\n',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadProjects, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_projects.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 40),
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.apartment_outlined, size: 64, color: AppTheme.primaryGreen),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Projects Registered',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 10),
          const Text(
            'Register a multi-tier project estate with blocks, dynamic floors, and 4-discipline CAD drawing management (Architectural, Structural, Mechanical, Electrical).',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textLight, height: 1.4),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create Project'),
                onPressed: _showCreateProjectDialog,
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.link),
                label: const Text('Join via Token'),
                onPressed: _showJoinProjectDialog,
              ),
            ],
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: _projects.length,
      itemBuilder: (context, index) {
        final project = _projects[index];
        return _buildProjectCard(project);
      },
    );
  }

  Widget _buildProjectCard(AiProjectModel project) {
    Color statusColor;
    String statusLabel;
    switch (project.status.toLowerCase()) {
      case 'compliant':
        statusColor = AppTheme.primaryGreen;
        statusLabel = 'COMPLIANT';
        break;
      case 'non_compliant':
        statusColor = AppTheme.danger;
        statusLabel = 'NON-COMPLIANT';
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        statusLabel = 'IN PROGRESS';
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = 'DRAFT';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.push('/professional/projects/');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        project.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.4)),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  project.referenceNumber,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blueGrey),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        project.occupancyClass,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF996500),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.corporate_fare, size: 14, color: AppTheme.primaryGreen),
                        const SizedBox(width: 4),
                        Text(
                          ' Block',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                        ),
                      ],
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
                        'Token: ',
                        style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'monospace'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 14, color: AppTheme.primaryGreen),
                      tooltip: 'Copy Share Token',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: project.shareToken));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Project share token copied to clipboard!')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
