import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../repositories/ai_compliance_repository.dart';
import '../copilot/copilot_floating_assistant.dart';
import '../copilot/professional_copilot_sheet.dart';

class ProfessionalProjectReportScreen extends StatefulWidget {
  final String projectId;

  const ProfessionalProjectReportScreen({super.key, required this.projectId});

  @override
  State<ProfessionalProjectReportScreen> createState() =>
      _ProfessionalProjectReportScreenState();
}

class _ProfessionalProjectReportScreenState
    extends State<ProfessionalProjectReportScreen> {
  final _repository = AiComplianceRepository();
  Map<String, dynamic>? _report;
  bool _isLoading = true;
  String? _errorMessage;

  // Discipline filter state: empty set = All Disciplines (default)
  final Set<String> _selectedDisciplines = {};
  bool _showTableFormat = true;

  static const List<String> _allDisciplines = [
    'architectural',
    'structural',
    'mechanical',
    'electrical',
  ];

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
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
    final floorAnalysis =
        _report?['floor_area_analysis'] as Map<String, dynamic>? ?? {};
    final totalGfa =
        floorAnalysis['total_project_floor_area_sqm'] ??
        _report?['gross_floor_area_sqm'] ??
        0;
    final totalFee =
        floorAnalysis['estimated_statutory_fee_ugx'] ??
        _report?['estimated_statutory_fee_ugx'] ??
        0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfessionalCopilotSheet(
        initialContextTitle:
            'Consolidated Project Audit (${_report?['reference_number'] ?? widget.projectId})',
        initialContextDescription:
            'Status: ${_report?['overall_compliance_status'] ?? ""}, Total Area: $totalGfa m², Statutory Fee: UGX $totalFee',
      ),
    );
  }

  void _toggleDisciplineFilter(String? discipline) {
    setState(() {
      if (discipline == null) {
        _selectedDisciplines.clear();
      } else {
        final norm = discipline.toLowerCase();
        if (_selectedDisciplines.contains(norm)) {
          _selectedDisciplines.remove(norm);
        } else {
          _selectedDisciplines.add(norm);
        }
      }
    });
  }

  void _showBlockFloorAreaBreakdownSheet(
    Map<String, dynamic> floorAnalysis,
    NumberFormat currencyFmt,
  ) {
    final blocks = (floorAnalysis['blocks'] as List<dynamic>?) ?? [];
    final totalGfa =
        double.tryParse(
          floorAnalysis['total_project_floor_area_sqm']?.toString() ?? '0',
        ) ??
        0.0;
    final feeRate =
        double.tryParse(
          floorAnalysis['statutory_fee_rate_per_sqm_ugx']?.toString() ?? '0',
        ) ??
        0.0;
    final estFee =
        double.tryParse(
          floorAnalysis['estimated_statutory_fee_ugx']?.toString() ?? '0',
        ) ??
        0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
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
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.domain_verification,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Block & Floor Area Breakdown',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            'Rate: UGX ${currencyFmt.format(feeRate)} / m²  •  Total Fee: UGX ${currencyFmt.format(estFee)}',
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
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryGreen.withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TOTAL PROJECT GFA',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${currencyFmt.format(totalGfa)} m²',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'EST. STATUTORY FEE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'UGX ${currencyFmt.format(estFee)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.accentGold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...blocks.map((b) {
                      final blockMap = b as Map<String, dynamic>;
                      final blockName = blockMap['name']?.toString() ?? 'Block';
                      final blockArea =
                          double.tryParse(
                            blockMap['total_floor_area_sqm']?.toString() ?? '0',
                          ) ??
                          0.0;
                      final floors =
                          (blockMap['floors'] as List<dynamic>?) ?? [];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                                Text(
                                  blockName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  '${currencyFmt.format(blockArea)} m²',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 18),
                            if (floors.isEmpty)
                              const Text(
                                'No floor details recorded yet.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textLight,
                                ),
                              )
                            else
                              ...floors.map((f) {
                                final fMap = f as Map<String, dynamic>;
                                final fName =
                                    fMap['floor_name']?.toString() ?? 'Floor';
                                final fNum =
                                    fMap['floor_number']?.toString() ?? '0';
                                final fArea =
                                    double.tryParse(
                                      fMap['gross_floor_area_sqm']
                                              ?.toString() ??
                                          '0',
                                    ) ??
                                    0.0;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '#$fNum • $fName',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                      Text(
                                        '${currencyFmt.format(fArea)} m²',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat('#,##0', 'en_US');

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Consolidated Compliance Report'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadReport),
        ],
      ),
      body: Stack(
        children: [
          _buildBody(currencyFmt),
          CopilotFloatingAssistant(onTap: _openCopilot),
        ],
      ),
    );
  }

  Widget _buildBody(NumberFormat currencyFmt) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
      );
    }

    if (_errorMessage != null || _report == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.danger),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? 'No report available',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadReport,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final report = _report!;
    final overallStatus =
        (report['overall_compliance_status'] ??
                report['overall_project_status'])
            ?.toString() ??
        'PENDING';
    final isCompliant = overallStatus == 'COMPLIANT';
    final statusColor = isCompliant
        ? AppTheme.primaryGreen
        : (overallStatus == 'NON_COMPLIANT' ? AppTheme.danger : Colors.orange);

    final floorAnalysis =
        report['floor_area_analysis'] as Map<String, dynamic>? ?? {};
    final totalGfa =
        double.tryParse(
          (floorAnalysis['total_project_floor_area_sqm'] ??
                      report['gross_floor_area_sqm'])
                  ?.toString() ??
              '0',
        ) ??
        0.0;
    final feeUgx =
        double.tryParse(
          (floorAnalysis['estimated_statutory_fee_ugx'] ??
                      report['estimated_statutory_fee_ugx'])
                  ?.toString() ??
              '0',
        ) ??
        0.0;

    final auditSummary = report['audit_summary'] as Map<String, dynamic>? ?? {};
    final totalDrawings =
        auditSummary['total_drawings'] ?? report['total_drawings'] ?? 0;
    final processedDrawings = auditSummary['processed_drawings'] ?? 0;

    final disciplineBreakdown =
        report['discipline_breakdown'] as Map<String, dynamic>? ?? {};
    final allDiscrepancies = (report['discrepancies'] as List<dynamic>?) ?? [];

    // Filter discrepancies by selected disciplines
    final filteredDiscrepancies = _selectedDisciplines.isEmpty
        ? allDiscrepancies
        : allDiscrepancies.where((item) {
            if (item is Map) {
              final disc = (item['discipline']?.toString() ?? '').toLowerCase();
              return _selectedDisciplines.contains(disc);
            }
            return false;
          }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // 1. Overall Verdict Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.5), width: 2),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: statusColor.withOpacity(0.12),
                child: Icon(
                  isCompliant ? Icons.verified : Icons.warning_amber_rounded,
                  color: statusColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overallStatus.replaceAll('_', ' '),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${report['project_name'] ?? "Building Project"} (${report['reference_number'] ?? ""})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Audited $processedDrawings of $totalDrawings drawings  •  ${report['occupancy_class'] ?? "Class B"}',
                      style: const TextStyle(
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
        const SizedBox(height: 16),

        // 2. Statutory Area & Fee Summary (Tappable for Block/Floor breakdown)
        Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showBlockFloorAreaBreakdownSheet(
                  floorAnalysis,
                  currencyFmt,
                ),
                child: _buildKpiCard(
                  label: 'CUMULATIVE GFA',
                  value: '${currencyFmt.format(totalGfa)} m²',
                  subtitle: 'Tap for block & floor schedule',
                  icon: Icons.square_foot,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showBlockFloorAreaBreakdownSheet(
                  floorAnalysis,
                  currencyFmt,
                ),
                child: _buildKpiCard(
                  label: 'ESTIMATED PLAN FEE',
                  value: 'UGX ${currencyFmt.format(feeUgx)}',
                  subtitle: 'Uganda Building Control Act',
                  icon: Icons.payments_outlined,
                  color: AppTheme.accentGold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // 3. Discipline Breakdown Summary Cards
        const Text(
          'DISCIPLINE COMPLIANCE SUMMARY',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryGreen,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.3,
          children: _allDisciplines.map((disc) {
            final dStats =
                disciplineBreakdown[disc] as Map<String, dynamic>? ?? {};
            final submitted = dStats['total'] ?? 0;
            final violations = dStats['failed'] ?? 0;
            final isSelected = _selectedDisciplines.contains(disc);

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _toggleDisciplineFilter(disc),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryGreen.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryGreen
                        : Colors.grey.shade200,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          disc.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: violations > 0
                                ? AppTheme.danger.withOpacity(0.12)
                                : AppTheme.primaryGreen.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$violations issues',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: violations > 0
                                  ? AppTheme.danger
                                  : AppTheme.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$submitted drawing(s) submitted',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // 4. Filter Bar & View Toggle for Discrepancies
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CONSOLIDATED DISCREPANCIES (${filteredDiscrepancies.length}/${allDiscrepancies.length})',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryGreen,
                letterSpacing: 0.8,
              ),
            ),
            Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Table View',
                  icon: Icon(
                    Icons.table_chart_outlined,
                    size: 18,
                    color: _showTableFormat
                        ? AppTheme.primaryGreen
                        : Colors.grey,
                  ),
                  onPressed: () => setState(() => _showTableFormat = true),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Card View',
                  icon: Icon(
                    Icons.view_agenda_outlined,
                    size: 18,
                    color: !_showTableFormat
                        ? AppTheme.primaryGreen
                        : Colors.grey,
                  ),
                  onPressed: () => setState(() => _showTableFormat = false),
                ),
              ],
            ),
          ],
        ),

        // Multi-select Discipline Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text('All (${allDiscrepancies.length})'),
                  selected: _selectedDisciplines.isEmpty,
                  selectedColor: AppTheme.primaryGreen,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _selectedDisciplines.isEmpty
                        ? Colors.white
                        : AppTheme.textDark,
                  ),
                  onSelected: (_) => _toggleDisciplineFilter(null),
                ),
              ),
              ..._allDisciplines.map((disc) {
                final count = allDiscrepancies.where((item) {
                  if (item is Map) {
                    return (item['discipline']?.toString() ?? '')
                            .toLowerCase() ==
                        disc;
                  }
                  return false;
                }).length;
                final isSelected = _selectedDisciplines.contains(disc);
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(
                      '${disc[0].toUpperCase()}${disc.substring(1)} ($count)',
                    ),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryGreen,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.textDark,
                    ),
                    onSelected: (_) => _toggleDisciplineFilter(disc),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 10),

        if (filteredDiscrepancies.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryGreen,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDisciplines.isEmpty
                        ? 'Zero regulatory violations detected across all submitted drawings.'
                        : 'No discrepancies found for the selected discipline filter(s).',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          )
        else if (_showTableFormat)
          _buildTabularDiscrepancies(filteredDiscrepancies)
        else
          ...filteredDiscrepancies.map(
            (d) => _buildDiscrepancyCard(d as Map<String, dynamic>),
          ),
      ],
    );
  }

  Widget _buildTabularDiscrepancies(List<dynamic> discrepancies) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
          dataRowMinHeight: 56,
          dataRowMaxHeight: 96,
          columnSpacing: 16,
          columns: const [
            DataColumn(
              label: Text(
                'BLOCK / DISCIPLINE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'ELEMENT / LOCATION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'UGANDA STATUTORY CITATION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'REQUIRED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'OBSERVED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'SEVERITY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.blueGrey,
                ),
              ),
            ),
          ],
          rows: discrepancies.map((raw) {
            final item = raw as Map<String, dynamic>;
            final blockName = item['block']?.toString() ?? 'Block';
            final disc = (item['discipline']?.toString() ?? 'N/A')
                .toUpperCase();
            final version = item['version']?.toString() ?? '1';
            final element =
                (item['element_id'] ??
                        item['room_or_grid'] ??
                        item['rule_name'] ??
                        'General')
                    .toString();
            final desc = item['description']?.toString() ?? '';
            final citation =
                (item['clause_reference'] ??
                        item['rule_id'] ??
                        'Uganda Building Code')
                    .toString();
            final requiredVal = item['required_value']?.toString() ?? '—';
            final observedVal = item['observed_value']?.toString() ?? '—';
            final severity = (item['severity']?.toString() ?? 'ERROR')
                .toUpperCase();
            final isError =
                severity == 'ERROR' ||
                severity == 'CRITICAL' ||
                severity == 'HIGH';
            final sevColor = isError ? AppTheme.danger : Colors.orange.shade800;

            return DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          blockName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: AppTheme.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$disc • v$version',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 190,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          element,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: AppTheme.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (desc.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            desc,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textLight,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 150,
                    child: Text(
                      citation,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 110,
                    child: Text(
                      requiredVal,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGreen,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 110,
                    child: Text(
                      observedVal,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.danger,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: sevColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      severity,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: sevColor,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDiscrepancyCard(Map<String, dynamic> item) {
    final severity = (item['severity']?.toString() ?? 'ERROR').toUpperCase();
    final isError =
        severity == 'ERROR' || severity == 'CRITICAL' || severity == 'HIGH';
    final sevColor = isError ? AppTheme.danger : Colors.orange.shade800;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: sevColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${item['block'] ?? "Block"} • ${(item['discipline'] ?? "").toString().toUpperCase()} (v${item['version'] ?? 1})',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: sevColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  severity,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: sevColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item['rule_name']?.toString() ??
                item['clause_reference']?.toString() ??
                'Code Violation',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppTheme.textDark,
            ),
          ),
          if (item['clause_reference'] != null) ...[
            const SizedBox(height: 3),
            Text(
              'Citation: ${item['clause_reference']}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            item['description']?.toString() ?? '',
            style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
          ),
          if (item['required_value'] != null ||
              item['observed_value'] != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (item['required_value'] != null)
                    Expanded(
                      child: Text(
                        'Required: ${item['required_value']}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  if (item['observed_value'] != null)
                    Expanded(
                      child: Text(
                        'Observed: ${item['observed_value']}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.danger,
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

  Widget _buildKpiCard({
    required String label,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(bottom: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
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
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
