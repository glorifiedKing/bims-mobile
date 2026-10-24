import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../models/quick_audit_model.dart';
import '../../repositories/ai_compliance_repository.dart';
import '../copilot/copilot_floating_assistant.dart';
import '../copilot/professional_copilot_sheet.dart';

class ProfessionalQuickAuditResultScreen extends StatefulWidget {
  final String auditId;

  const ProfessionalQuickAuditResultScreen({super.key, required this.auditId});

  @override
  State<ProfessionalQuickAuditResultScreen> createState() =>
      _ProfessionalQuickAuditResultScreenState();
}

class _ProfessionalQuickAuditResultScreenState
    extends State<ProfessionalQuickAuditResultScreen> {
  final _repository = AiComplianceRepository();
  QuickAuditModel? _audit;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchAudit();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchAudit() async {
    try {
      final res = await _repository.getQuickAudit(widget.auditId);
      if (mounted) {
        setState(() {
          _audit = res;
          _isLoading = false;
        });

        if (res.isProcessing) {
          _startPolling();
        } else {
          _pollingTimer?.cancel();
        }
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

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final res = await _repository.getQuickAudit(widget.auditId);
        if (mounted) {
          setState(() {
            _audit = res;
          });
          if (!res.isProcessing) {
            timer.cancel();
          }
        }
      } catch (_) {}
    });
  }

  void _openCopilot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfessionalCopilotSheet(
        initialContextTitle: 'Quick Audit: ${_audit?.originalName ?? widget.auditId}',
        initialContextDescription: 'Discipline: ${_audit?.discipline.toUpperCase() ?? ""}, Area: ${_audit?.grossFloorAreaSqm} m², Violations: ${_audit?.discrepancies.length ?? 0}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0', 'en_US');

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Compliance Audit Report'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchAudit),
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
                'Failed to load audit results\n $_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textDark),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchAudit,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final audit = _audit!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        // Live Processing banner
        if (audit.isProcessing) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade800, Colors.blue.shade600],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: const [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'AI Compliance Engine Analyzing Drawing...',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Executing Pre-flight scale detection, vector geometry measurement, and pgvector RAG clause verification.',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ] else if (audit.isFailed) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.danger.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.danger),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppTheme.danger,
                  size: 40,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Audit Analysis Failed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.danger,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  audit.errorMessage ??
                      'Pre-flight check rejected this document.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ] else ...[
          // Completed Verdict Card
          _buildVerdictCard(audit),
          const SizedBox(height: 20),
        ],

        // KPI Metrics Grid
        const Text(
          'MEASUREMENT & STATUTORY SUMMARY',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryGreen,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricBox(
                title: 'GROSS FLOOR AREA',
                value: '${audit.grossFloorAreaSqm} m²',
                icon: Icons.square_foot,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricBox(
                title: 'STATUTORY FEE (EST.)',
                value: 'UGX ${audit.estimatedStatutoryFeeUgx}',
                icon: Icons.payments_outlined,
                color: AppTheme.accentGold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricBox(
                title: 'DISCIPLINE',
                value: audit.discipline.toUpperCase(),
                icon: Icons.engineering,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricBox(
                title: 'OCCUPANCY CLASS',
                value: audit.occupancyClass ?? 'General',
                icon: Icons.domain,
                color: Colors.indigo,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
        // Discrepancies and Findings
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'REGULATORY FINDINGS & VIOLATIONS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryGreen,
                letterSpacing: 1,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: audit.discrepancies.isEmpty
                    ? AppTheme.primaryGreen.withOpacity(0.1)
                    : AppTheme.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ' DETECTED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: audit.discrepancies.isEmpty
                      ? AppTheme.primaryGreen
                      : AppTheme.danger,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (audit.discrepancies.isEmpty && !audit.isProcessing) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
            ),
            child: Row(
              children: const [
                Icon(Icons.verified, color: AppTheme.primaryGreen, size: 36),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '100% Statutory Conformance',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'No statutory violations detected against the Uganda National Building Code standards for this discipline.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          ...audit.discrepancies.map((d) => _buildDiscrepancyCard(d)),
        ],

        const SizedBox(height: 24),
        // Consult AI Copilot action banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00331a), AppTheme.primaryGreen],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.accentGold, width: 1.5),
          ),
          child: Row(
            children: [
              const Text('🤖', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Ask AI Copilot About This Drawing',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Consult Eng. Kigozi, Arch. Namubiru, or Inspector Okello about these findings.',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
                onPressed: _openCopilot,
                child: const Text(
                  'ASK',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerdictCard(QuickAuditModel audit) {
    final isCompliant = audit.isCompliant;
    final color = isCompliant ? AppTheme.primaryGreen : AppTheme.danger;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompliant ? Icons.check_circle : Icons.warning,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCompliant
                          ? 'COMPLIANT SUBMISSION'
                          : 'VIOLATIONS DETECTED',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: color,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      audit.originalName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDiscrepancyCard(DiscrepancyModel d) {
    Color sevColor;
    switch (d.severity) {
      case 'critical':
        sevColor = Colors.purple;
        break;
      case 'high':
        sevColor = AppTheme.danger;
        break;
      case 'medium':
        sevColor = Colors.orange;
        break;
      default:
        sevColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
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
                  d.ruleName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: sevColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: sevColor.withOpacity(0.3)),
                ),
                child: Text(
                  d.severity.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: sevColor,
                  ),
                ),
              ),
            ],
          ),
          if (d.clauseReference != null && d.clauseReference!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Uganda Code: ${d.clauseReference ?? ""}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            d.roomOrGrid ?? "",
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textDark,
              height: 1.3,
            ),
          ),
          if (d.observedValue != null || d.requiredValue != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (d.observedValue != null)
                    Expanded(
                      child: Text(
                        'Observed: ${d.observedValue ?? ""}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (d.requiredValue != null)
                    Expanded(
                      child: Text(
                        'Statutory Limit: ${d.requiredValue ?? ""}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
