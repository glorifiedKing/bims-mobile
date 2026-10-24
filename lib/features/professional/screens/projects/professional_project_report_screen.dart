import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../repositories/ai_compliance_repository.dart';
import '../copilot/copilot_floating_assistant.dart';
import '../copilot/professional_copilot_sheet.dart';

class ProfessionalProjectReportScreen extends StatefulWidget {
  final String projectId;

  const ProfessionalProjectReportScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<ProfessionalProjectReportScreen> createState() =>
      _ProfessionalProjectReportScreenState();
}

class _ProfessionalProjectReportScreenState
    extends State<ProfessionalProjectReportScreen> {
  final _repository = AiComplianceRepository();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _report;

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _repository.getProjectReport(widget.projectId);
      if (mounted) {
        setState(() {
          _report = res;
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
      builder: (context) => ProfessionalCopilotSheet(
        initialContextTitle: 'Project Consolidated Audit Report',
        initialContextDescription: 'Status: ${_report?['status'] ?? "N/A"}, Area: ${_report?['gross_floor_area'] ?? 0} m²',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0', 'en_US');

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Consolidated Audit Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchReport,
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBody(currencyFormatter),
          CopilotFloatingAssistant(onTap: _openCopilot),
        ],
      ),
    );
  }

  Widget _buildBody(NumberFormat currencyFormatter) {
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
              Text('Unable to generate report: ', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _fetchReport, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final report = _report!;
    final overallStatus = (report['overall_project_status'] ?? 'PENDING').toString().toUpperCase();
    final isCompliant = overallStatus == 'PASS' || overallStatus == 'COMPLIANT';
    final area = (report['gross_floor_area_sqm'] as num?)?.toDouble() ?? 0.0;
    final fee = (report['estimated_statutory_fee_ugx'] as num?)?.toDouble() ?? 0.0;
    final totalDrawings = (report['total_drawings'] as num?)?.toInt() ?? 0;
    final processedDrawings = (report['processed_drawings'] as num?)?.toInt() ?? 0;

    final breakdown = report['discipline_breakdown'] as Map<String, dynamic>? ?? {};
    final discrepancies = report['discrepancies'] as List? ?? [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        // Overall Verdict Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCompliant ? AppTheme.primaryGreen : AppTheme.danger,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                isCompliant ? Icons.verified : Icons.warning_amber_rounded,
                size: 48,
                color: isCompliant ? AppTheme.primaryGreen : AppTheme.danger,
              ),
              const SizedBox(height: 12),
              Text(
                isCompliant ? 'CONSOLIDATED COMPLIANCE: PASS' : 'CONSOLIDATED STATUS: ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isCompliant ? AppTheme.primaryGreen : AppTheme.danger,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                ' of  floor discipline drawings processed',
                style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        const Text(
          'ESTATE COMPLIANCE METRICS',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen, letterSpacing: 1),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard('TOTAL FLOOR AREA', ' m²', Icons.square_foot, AppTheme.primaryGreen),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard('STATUTORY FEES (EST.)', 'UGX ', Icons.payments, AppTheme.accentGold),
            ),
          ],
        ),

        const SizedBox(height: 24),
        const Text(
          'DISCIPLINE BREAKDOWN',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen, letterSpacing: 1),
        ),
        const SizedBox(height: 10),

        ...breakdown.entries.map((e) {
          final discName = e.key.toUpperCase();
          final data = e.value as Map<String, dynamic>? ?? {};
          final total = data['total'] ?? 0;
          final passed = data['passed'] ?? 0;
          final failed = data['failed'] ?? 0;
          final status = (data['status'] ?? 'PENDING').toString().toUpperCase();

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.18)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(discName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text('Drawings:  | Passed:  | Failed: ', style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'PASS'
                        ? AppTheme.primaryGreen.withOpacity(0.12)
                        : (status == 'FAIL' ? AppTheme.danger.withOpacity(0.12) : Colors.grey.withOpacity(0.12)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: status == 'PASS' ? AppTheme.primaryGreen : (status == 'FAIL' ? AppTheme.danger : Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 24),
        Text(
          'CONSOLIDATED STATUTORY FINDINGS ()',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen, letterSpacing: 1),
        ),
        const SizedBox(height: 10),

        if (discrepancies.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
            ),
            child: Row(
              children: const [
                Icon(Icons.check_circle, color: AppTheme.primaryGreen),
                SizedBox(width: 10),
                Expanded(child: Text('All drawings conform to Uganda National Building Code standards.')),
              ],
            ),
          ),
        ] else ...[
          ...discrepancies.map((item) {
            final map = item is Map<String, dynamic> ? item : {};
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    map['rule_name'] ?? map['description'] ?? 'Statutory Violation',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  if (map['clause_reference'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Ref: ',
                      style: const TextStyle(fontSize: 10, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                    ),
                  ],
                  if (map['description'] != null) ...[
                    const SizedBox(height: 4),
                    Text(map['description'], style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                  ],
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(bottom: BorderSide(color: color, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
