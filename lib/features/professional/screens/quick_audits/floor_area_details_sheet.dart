import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../models/quick_audit_model.dart';

class FloorAreaDetailsSheet extends StatelessWidget {
  final QuickAuditModel audit;

  const FloorAreaDetailsSheet({
    super.key,
    required this.audit,
  });

  static void show(BuildContext context, QuickAuditModel audit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FloorAreaDetailsSheet(audit: audit),
    );
  }

  String _formatArea(double val) {
    if (val % 1 == 0) {
      return NumberFormat('#,##0', 'en_US').format(val.toInt());
    }
    return NumberFormat('#,##0.0', 'en_US').format(val);
  }

  String _formatCurrency(double val) {
    return NumberFormat('#,##0', 'en_US').format(val);
  }

  String _formatSource(String? rawSource) {
    if (rawSource == null || rawSource.isEmpty) return 'Multimodal Plan Engine';
    return rawSource
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;
    final topPadding = mediaQuery.padding.top;

    final maxHeight = screenHeight - topPadding - 20;
    final sheetHeight = (screenHeight * 0.88).clamp(320.0, maxHeight);

    final metrics = audit.floorAreaMetrics;
    final totalGfa = audit.grossFloorAreaSqm > 0
        ? audit.grossFloorAreaSqm
        : (metrics?.grossFloorAreaSqm ?? 0.0);
    final floors = metrics?.floors ?? [];
    final totalRooms = metrics?.roomBreakdown ?? [];
    final confidencePercent = ((metrics?.confidenceScore ?? 0.95) * 100).toInt();

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Material(
        color: AppTheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: sheetHeight,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Sheet Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryGreen.withOpacity(0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.domain_verification,
                          color: AppTheme.primaryGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gross Floor Area Schedule',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textDark,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              audit.originalName,
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
                      IconButton(
                        icon: const Icon(Icons.close, color: AppTheme.textLight),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                // Sheet Body (Scrollable)
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                    children: [
                      // Total GFA & Fee Hero Card
                      _buildHeroCard(
                        totalGfa: totalGfa,
                        netInternalArea: metrics?.netInternalAreaSqm,
                        confidencePercent: confidencePercent,
                        source: metrics?.source,
                        floorsCount: floors.isNotEmpty
                            ? floors.length
                            : (metrics?.cumulatedFloorsCount ?? 1),
                      ),

                      const SizedBox(height: 20),

                      // Section Title: Floors
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'MEASURED BUILDING LEVELS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryGreen,
                              letterSpacing: 1,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              floors.isNotEmpty
                                  ? '${floors.length} LEVELS DETECTED'
                                  : 'SINGLE SHEET / OVERVIEW',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Floors List or Single Level View
                      if (floors.isNotEmpty) ...[
                        ...floors.map(
                          (floor) => _buildFloorCard(
                            floor: floor,
                            buildingTotalGfa: totalGfa,
                          ),
                        ),
                      ] else ...[
                        _buildSingleLevelCard(
                          totalGfa: totalGfa,
                          rooms: totalRooms,
                        ),
                      ],

                      // Top-level Room Breakdown if floors array wasn't populated but rooms were
                      if (floors.isEmpty && totalRooms.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildRoomsScheduleCard(totalRooms),
                      ],

                      const SizedBox(height: 20),

                      // Regulatory Context & Formula Basis Card
                      _buildStatutoryContextCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard({
    required double totalGfa,
    required double? netInternalArea,
    required int confidencePercent,
    required String? source,
    required int floorsCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL GROSS FLOOR AREA (GFA)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _formatArea(totalGfa),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryGreen,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'm²',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    if (netInternalArea != null && netInternalArea > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Net Internal Area (NIA): ${_formatArea(netInternalArea)} m²',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.layers,
                      size: 14,
                      color: AppTheme.primaryGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$floorsCount ${floorsCount == 1 ? "Level" : "Levels"}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),

          // Secondary Info Grid
          Row(
            children: [
              Expanded(
                child: _buildHeroStat(
                  label: 'STATUTORY PLAN FEE',
                  value: audit.estimatedStatutoryFeeUgx > 0
                      ? 'UGX ${_formatCurrency(audit.estimatedStatutoryFeeUgx)}'
                      : 'Exempt / Included',
                  valueColor: AppTheme.accentGold,
                  icon: Icons.payments_outlined,
                ),
              ),
              Container(width: 1, height: 36, color: const Color(0xFFF1F5F9)),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHeroStat(
                  label: 'OCCUPANCY CLASS',
                  value: audit.occupancyClass ?? 'General Building',
                  valueColor: AppTheme.textDark,
                  icon: Icons.apartment,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          // Badge Row: AI Confidence & Source
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, size: 12, color: AppTheme.primaryGreen),
                    const SizedBox(width: 4),
                    Text(
                      '$confidencePercent% AI Confidence',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatSource(source),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat({
    required String label,
    required String value,
    required Color valueColor,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFloorCard({
    required FloorMetricItemModel floor,
    required double buildingTotalGfa,
  }) {
    final floorGfa = floor.grossFloorAreaSqm ?? 0.0;
    final percentage = buildingTotalGfa > 0
        ? ((floorGfa / buildingTotalGfa) * 100).clamp(0.0, 100.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Theme(
            data: ThemeData(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: false,
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.layers_outlined,
              color: AppTheme.primaryGreen,
              size: 20,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  floor.floorName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              if (floor.page != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    'Sheet P.${floor.page}',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_formatArea(floorGfa)} m²',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}% of total',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (percentage / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade100,
                  color: AppTheme.primaryGreen,
                  minHeight: 5,
                ),
              ),
              if (floor.netInternalAreaSqm != null &&
                  floor.netInternalAreaSqm! > 0) ...[
                const SizedBox(height: 4),
                Text(
                  'Net Internal: ${_formatArea(floor.netInternalAreaSqm!)} m²',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ],
          ),
          children: [
            const Divider(height: 16, color: Color(0xFFF1F5F9)),
            Row(
              children: [
                const Icon(
                  Icons.meeting_room_outlined,
                  size: 13,
                  color: AppTheme.textLight,
                ),
                const SizedBox(width: 6),
                Text(
                  floor.roomBreakdown.isNotEmpty
                      ? 'Detected Spaces (${floor.roomBreakdown.length})'
                      : 'No isolated room schedule detected',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (floor.roomBreakdown.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: floor.roomBreakdown.map((room) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          room.cleanName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                        if (room.areaSqm != null && room.areaSqm! > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${_formatArea(room.areaSqm!)} m²',
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
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Gross area derived from outer boundary vectors and title block schedule.',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textLight,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  ),
);
  }

  Widget _buildSingleLevelCard({
    required double totalGfa,
    required List<RoomBreakdownModel> rooms,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Single Level Drawing Plan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              Text(
                '${_formatArea(totalGfa)} m²',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'This architectural drawing represents a single floor plan layout. All room measurements contribute directly to the total building area.',
            style: TextStyle(fontSize: 11, color: AppTheme.textLight, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsScheduleCard(List<RoomBreakdownModel> rooms) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.grid_view_rounded,
                size: 16,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(width: 8),
              Text(
                'Identified Rooms Schedule (${rooms.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: rooms.map((room) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      room.cleanName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    if (room.areaSqm != null && room.areaSqm! > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_formatArea(room.areaSqm!)} m²',
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

  Widget _buildStatutoryContextCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Uganda Statutory Measurement Basis',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Gross Floor Area (GFA) is measured to the outer face of external walls in accordance with the Uganda Building Control Regulations. Statutory plan review fees are calculated based on cumulated GFA across all approved architectural levels.',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
