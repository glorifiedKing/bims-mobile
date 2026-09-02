import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../core/repositories/auxiliary_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSyncing = false;
  Map<String, SyncItemStatus> _syncStatus = {};
  DateTime? _lastSyncTimestamp;
  Map<String, int> _storedCounts = {};

  final Map<String, IconData> _categoryIcons = {
    'admin_unit_types': Icons.category_outlined,
    'admin_units': Icons.location_city_outlined,
    'user_roles': Icons.badge_outlined,
    'building_classifications': Icons.domain_outlined,
    'eps_types': Icons.gavel_outlined,
    'wb_categories': Icons.campaign_outlined,
    'building_purposes': Icons.apartment_outlined,
    'land_tenures': Icons.landscape_outlined,
    'application_types': Icons.assignment_outlined,
    'form_types': Icons.description_outlined,
    'building_operations': Icons.construction_outlined,
    'inspection_types': Icons.fact_check_outlined,
    'inspection_statuses': Icons.rule_outlined,
    'payment_modes': Icons.payments_outlined,
  };

  @override
  void initState() {
    super.initState();
    _loadCurrentStatus();
  }

  void _loadCurrentStatus() {
    final auxRepo = context.read<AuxiliaryRepository>();
    final counts = auxRepo.getStoredCounts();
    final lastSync = auxRepo.getLastSyncTimestamp();

    final Map<String, SyncItemStatus> initialStatus = {};
    for (final def in AuxiliaryRepository.syncItemDefinitions) {
      final key = def['key']!;
      final count = counts[key] ?? 0;
      initialStatus[key] = SyncItemStatus(
        key: key,
        title: def['title']!,
        status: count > 0 ? SyncStatusState.success : SyncStatusState.pending,
        count: count,
      );
    }

    setState(() {
      _syncStatus = initialStatus;
      _lastSyncTimestamp = lastSync;
      _storedCounts = counts;
    });
  }

  Future<void> _startSync() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
    });

    final auxRepo = context.read<AuxiliaryRepository>();

    try {
      final result = await auxRepo.syncAuxiliaryData(
        forceSync: true,
        onProgress: (statusMap) {
          if (mounted) {
            setState(() {
              _syncStatus = statusMap;
            });
          }
        },
      );

      if (mounted) {
        final lastSync = auxRepo.getLastSyncTimestamp();
        final counts = auxRepo.getStoredCounts();

        final int successCount =
            result.values.where((s) => s.status == SyncStatusState.success).length;
        final int failCount =
            result.values.where((s) => s.status == SyncStatusState.failed).length;

        setState(() {
          _isSyncing = false;
          _lastSyncTimestamp = lastSync;
          _storedCounts = counts;
          _syncStatus = result;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: failCount == 0 ? AppTheme.primaryGreen : Colors.orange.shade800,
            content: Text(
              failCount == 0
                  ? 'All $successCount offline data categories downloaded successfully!'
                  : 'Sync finished: $successCount succeeded, $failCount failed.',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.danger,
            content: Text('Error downloading offline data: $e'),
          ),
        );
      }
    }
  }

  int get _totalCachedRecords {
    return _storedCounts.values.fold(0, (sum, count) => sum + count);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Settings & Offline Data',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _startSync,
        color: AppTheme.primaryGreen,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildOverviewCard(),
            const SizedBox(height: 20),
            _buildHeaderSection(),
            const SizedBox(height: 12),
            ...AuxiliaryRepository.syncItemDefinitions.map((def) {
              final key = def['key']!;
              final status = _syncStatus[key] ??
                  SyncItemStatus(
                    key: key,
                    title: def['title']!,
                    status: SyncStatusState.pending,
                  );
              return _buildSyncItemTile(status);
            }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    final dateFormat = DateFormat('MMM d, y • h:mm a');
    final formattedDate = _lastSyncTimestamp != null
        ? dateFormat.format(_lastSyncTimestamp!)
        : 'Never synced';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.cloud_sync,
                  color: AppTheme.primaryGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Offline Data Cache',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Last sync: $formattedDate',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28, color: Color(0xFFF0F0F0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL RECORDS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_totalCachedRecords records cached',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _totalCachedRecords > 0
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _totalCachedRecords > 0
                        ? Colors.green.shade200
                        : Colors.orange.shade200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _totalCachedRecords > 0
                          ? Icons.check_circle_outline
                          : Icons.info_outline,
                      size: 14,
                      color: _totalCachedRecords > 0
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _totalCachedRecords > 0 ? 'Ready for Offline' : 'Incomplete',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _totalCachedRecords > 0
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isSyncing ? null : _startSync,
              icon: _isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download, color: Colors.white),
              label: Text(
                _isSyncing
                    ? 'Downloading Offline Data...'
                    : 'Re-download Data Afresh',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                disabledBackgroundColor: AppTheme.primaryGreen.withOpacity(0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'DATA CATEGORIES (${AuxiliaryRepository.syncItemDefinitions.length})',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
            letterSpacing: 0.8,
          ),
        ),
        if (_isSyncing)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Syncing...',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSyncItemTile(SyncItemStatus status) {
    final icon = _categoryIcons[status.key] ?? Icons.storage_outlined;

    Color badgeBg;
    Color badgeColor;
    Widget statusWidget;
    String statusSubtitle;

    switch (status.status) {
      case SyncStatusState.syncing:
        badgeBg = Colors.blue.shade50;
        badgeColor = Colors.blue.shade700;
        statusSubtitle = 'Downloading...';
        statusWidget = SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.blue.shade700,
          ),
        );
        break;
      case SyncStatusState.success:
        badgeBg = Colors.green.shade50;
        badgeColor = Colors.green.shade700;
        statusSubtitle = '${status.count} items cached';
        statusWidget = Icon(
          Icons.check_circle,
          color: Colors.green.shade600,
          size: 22,
        );
        break;
      case SyncStatusState.failed:
        badgeBg = Colors.red.shade50;
        badgeColor = Colors.red.shade700;
        statusSubtitle = status.errorMessage != null && status.errorMessage!.isNotEmpty
            ? 'Failed: ${status.errorMessage}'
            : 'Download failed';
        statusWidget = Icon(
          Icons.error,
          color: Colors.red.shade600,
          size: 22,
        );
        break;
      case SyncStatusState.pending:
      default:
        badgeBg = Colors.grey.shade100;
        badgeColor = Colors.grey.shade600;
        statusSubtitle = status.count > 0 ? '${status.count} items cached' : 'Not downloaded';
        statusWidget = Icon(
          status.count > 0 ? Icons.check_circle_outline : Icons.cloud_download_outlined,
          color: status.count > 0 ? Colors.green.shade600 : Colors.grey.shade400,
          size: 22,
        );
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status.status == SyncStatusState.failed
              ? Colors.red.shade200
              : const Color(0xFFEEEEEE),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: badgeColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: status.status == SyncStatusState.failed
                        ? Colors.red.shade700
                        : Colors.grey.shade600,
                    fontWeight: status.status == SyncStatusState.failed
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          statusWidget,
        ],
      ),
    );
  }
}
