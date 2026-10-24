import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../models/quick_audit_model.dart';
import '../../repositories/ai_compliance_repository.dart';
import '../copilot/copilot_floating_assistant.dart';

class ProfessionalQuickAuditsScreen extends StatefulWidget {
  const ProfessionalQuickAuditsScreen({super.key});

  @override
  State<ProfessionalQuickAuditsScreen> createState() =>
      _ProfessionalQuickAuditsScreenState();
}

class _ProfessionalQuickAuditsScreenState
    extends State<ProfessionalQuickAuditsScreen> {
  final _repository = AiComplianceRepository();
  bool _isLoading = true;
  String? _errorMessage;
  List<QuickAuditModel> _audits = [];

  @override
  void initState() {
    super.initState();
    _loadAudits();
  }

  Future<void> _loadAudits() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _repository.getQuickAudits();
      if (mounted) {
        setState(() {
          _audits = list;
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

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0', 'en_US');

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Quick Single Drawing Audits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAudits,
            tooltip: 'Refresh list',
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadAudits,
            color: AppTheme.primaryGreen,
            child: _buildBody(currencyFormatter),
          ),
          const CopilotFloatingAssistant(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.upload_file, color: Colors.white),
        label: const Text(
          'NEW QUICK AUDIT',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        onPressed: () async {
          final res = await context.push('/professional/quick-audits/upload');
          if (res == true && mounted) {
            _loadAudits();
          }
        },
      ),
    );
  }

  Widget _buildBody(NumberFormat currencyFormatter) {
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
                'Unable to load audits:\n $_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textDark),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAudits,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_audits.isEmpty) {
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
              child: const Icon(
                Icons.analytics_outlined,
                size: 64,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Quick Audits Yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Upload a single engineering drawing PDF (Architectural, Structural, MEP) to test scale detection, floor area metrics, and statutory Uganda Building Code compliance instantly.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textLight, height: 1.4),
          ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Submit Single Drawing'),
              onPressed: () async {
                final res = await context.push(
                  '/professional/quick-audits/upload',
                );
                if (res == true && mounted) {
                  _loadAudits();
                }
              },
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: _audits.length,
      itemBuilder: (context, index) {
        final audit = _audits[index];
        return _buildAuditCard(audit, currencyFormatter);
      },
    );
  }

  Widget _buildAuditCard(
    QuickAuditModel audit,
    NumberFormat currencyFormatter,
  ) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    final overall = (audit.overallStatus ?? '').toUpperCase();
    if (audit.isProcessing) {
      statusColor = Colors.blue;
      statusLabel = 'ANALYZING...';
      statusIcon = Icons.hourglass_top;
    } else if (overall == 'PASS' || overall == 'COMPLIANT') {
      statusColor = AppTheme.primaryGreen;
      statusLabel = 'COMPLIANT';
      statusIcon = Icons.check_circle;
    } else if (overall == 'FAIL' || overall == 'NON_COMPLIANT') {
      statusColor = AppTheme.danger;
      statusLabel = 'NON-COMPLIANT';
      statusIcon = Icons.cancel;
    } else if (overall == 'WARNING') {
      statusColor = Colors.orange;
      statusLabel = 'WARNING';
      statusIcon = Icons.warning_amber;
    } else {
      statusColor = Colors.grey;
      statusLabel = audit.status.toUpperCase();
      statusIcon = Icons.info_outline;
    }

    final dateStr = audit.createdAt != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(audit.createdAt!)
        : '';

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
            context.push('/professional/quick-audits/${audit.id}');
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
                        audit.originalName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        audit.discipline.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (audit.occupancyClass != null) ...[
                      Flexible(
                        child: Text(
                          audit.occupancyClass!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    const Spacer(),
                    Text(
                      dateStr,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GROSS FLOOR AREA',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ' m²',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ESTIMATED STATUTORY FEE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'UGX ',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'VIOLATIONS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: audit.discrepancies.isEmpty
                                ? AppTheme.primaryGreen
                                : AppTheme.danger,
                          ),
                        ),
                      ],
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
