import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../core/repositories/auxiliary_repository.dart';
import '../bloc/inspection_details/bco_inspection_details_bloc.dart';
import '../bloc/inspection_details/bco_inspection_details_event.dart';
import '../bloc/inspection_details/bco_inspection_details_state.dart';
import '../models/bco_inspection_model.dart';

class BcoInspectionDetailsScreen extends StatefulWidget {
  final String reference;
  const BcoInspectionDetailsScreen({super.key, required this.reference});

  @override
  State<BcoInspectionDetailsScreen> createState() =>
      _BcoInspectionDetailsScreenState();
}

class _BcoInspectionDetailsScreenState
    extends State<BcoInspectionDetailsScreen> {
  // Update form
  int? _selectedStatusId;
  final TextEditingController _postNotesController = TextEditingController();
  DateTime? _newStart;
  DateTime? _newEnd;

  @override
  void initState() {
    super.initState();
    context.read<BcoInspectionDetailsBloc>().add(
      FetchBcoInspectionDetails(widget.reference),
    );
  }

  @override
  void dispose() {
    _postNotesController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) =>
      DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);

  String _displayDateTime(DateTime dt) =>
      DateFormat('EEE, dd MMM yyyy — hh:mm a').format(dt);

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: (isStart ? _newStart : _newEnd) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primaryGreen,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primaryGreen,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;

    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (isStart) {
        _newStart = combined;
      } else {
        _newEnd = combined;
      }
    });
  }

  void _submitUpdate(BcoInspectionModel inspection) {
    if (_selectedStatusId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a status'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<BcoInspectionDetailsBloc>().add(
      UpdateBcoInspection(
        reference: widget.reference,
        statusId: _selectedStatusId!,
        applicationKey: inspection.applicationKey,
        start: _newStart != null ? _formatDateTime(_newStart!) : null,
        end: _newEnd != null ? _formatDateTime(_newEnd!) : null,
        postInspectionComments: _postNotesController.text.trim().isNotEmpty
            ? _postNotesController.text.trim()
            : null,
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'RE-SCHEDULED':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F0),
      appBar: AppBar(
        title: const Text(
          'Inspection Details',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: AppTheme.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: BlocConsumer<BcoInspectionDetailsBloc, BcoInspectionDetailsState>(
        listener: (context, state) {
          if (state is BcoInspectionDetailsLoaded) {
            if (state.updateSuccess == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Inspection updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Reset form
              setState(() {
                _selectedStatusId = null;
                _postNotesController.clear();
                _newStart = null;
                _newEnd = null;
              });
            } else if (state.updateError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.updateError}'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 10),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is BcoInspectionDetailsLoading ||
              state is BcoInspectionDetailsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BcoInspectionDetailsError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<BcoInspectionDetailsBloc>()
                        .add(FetchBcoInspectionDetails(widget.reference)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is BcoInspectionDetailsLoaded) {
            return _buildBody(state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBody(BcoInspectionDetailsLoaded state) {
    final inspection = state.inspection;
    final statusColor = _statusColor(inspection.inspectionStatus);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header card
              _buildHeaderCard(inspection, statusColor),
              const SizedBox(height: 14),

              // Applicant info
              _buildSectionCard(
                title: 'Applicant',
                icon: Icons.person_outline,
                children: [
                  _infoRow('Name', inspection.applicantName),
                  _infoRow('Email', inspection.applicantEmail),
                  _infoRow('Phone', inspection.applicantPhone),
                ],
              ),
              const SizedBox(height: 14),

              // Schedule info
              _buildSectionCard(
                title: 'Schedule',
                icon: Icons.schedule,
                children: [
                  _infoRow('Start', _displayDateTime(inspection.start)),
                  _infoRow('End', _displayDateTime(inspection.end)),
                  _infoRow('Location', inspection.location),
                  _infoRow('Type', inspection.inspectionType),
                ],
              ),
              const SizedBox(height: 14),

              // Pre-inspection notes
              if (inspection.preInspectionNotes.isNotEmpty) ...[
                _buildSectionCard(
                  title: 'Pre-Inspection Notes',
                  icon: Icons.notes,
                  children: [
                    Text(
                      inspection.preInspectionNotes,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],

              // Update section (only for PENDING)
              if (inspection.isPending) _buildUpdateSection(inspection),

              const SizedBox(height: 80),
            ],
          ),
        ),
        if (state.isUpdating)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildHeaderCard(BcoInspectionModel inspection, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00331a), AppTheme.primaryGreen],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${inspection.applicationKey}',
                style: const TextStyle(
                  color: AppTheme.accentGold,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.5)),
                ),
                child: Text(
                  inspection.inspectionStatus,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor == Colors.orange
                        ? Colors.orange[200]
                        : statusColor == Colors.green
                        ? Colors.greenAccent[200]
                        : Colors.lightBlueAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            inspection.inspectionType,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 13),
              const SizedBox(width: 6),
              Text(
                DateFormat('EEE, dd MMM yyyy').format(inspection.start),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, color: Colors.white70, size: 13),
              const SizedBox(width: 6),
              Text(
                '${DateFormat('hh:mm a').format(inspection.start)} – ${DateFormat('hh:mm a').format(inspection.end)}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateSection(BcoInspectionModel inspection) {
    final auxRepo = context.read<AuxiliaryRepository>();
    final statuses = auxRepo.getInspectionStatuses().where((s) {
      final name = s.name.toUpperCase();
      return name == 'COMPLETED' || name == 'RE-SCHEDULED';
    }).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentGold.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.edit_note, color: AppTheme.accentGold, size: 20),
              SizedBox(width: 8),
              Text(
                'Update Inspection',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),

          // Status dropdown
          const Text(
            'New Status',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<int>(
            value: _selectedStatusId,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              isDense: true,
            ),
            hint: const Text('Select status', style: TextStyle(fontSize: 13)),
            items: statuses
                .map(
                  (s) =>
                      DropdownMenuItem<int>(value: s.id, child: Text(s.name)),
                )
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedStatusId = val;
              });
            },
          ),
          const SizedBox(height: 16),

          // Start override
          const Text(
            'Override Start (optional)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _pickDateTime(true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 16,
                    color: AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _newStart != null
                        ? _displayDateTime(_newStart!)
                        : 'Keep current start',
                    style: TextStyle(
                      fontSize: 13,
                      color: _newStart != null ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // End override
          const Text(
            'Override End (optional)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _pickDateTime(false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 16,
                    color: AppTheme.accentGold,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _newEnd != null
                        ? _displayDateTime(_newEnd!)
                        : 'Keep current end',
                    style: TextStyle(
                      fontSize: 13,
                      color: _newEnd != null ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Post-inspection notes
          const Text(
            'Post-Inspection Comments',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _postNotesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter post-inspection comments...',
              hintStyle: const TextStyle(fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 20),

          // Submit
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _submitUpdate(inspection),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'SUBMIT UPDATE',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
