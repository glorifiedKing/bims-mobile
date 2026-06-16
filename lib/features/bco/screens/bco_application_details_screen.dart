import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../core/repositories/auxiliary_repository.dart';
import '../bloc/application_details/bco_application_details_bloc.dart';
import '../bloc/application_details/bco_application_details_event.dart';
import '../bloc/application_details/bco_application_details_state.dart';
import '../bloc/create_inspection/bco_create_inspection_bloc.dart';
import '../bloc/create_inspection/bco_create_inspection_event.dart';
import '../bloc/create_inspection/bco_create_inspection_state.dart';
import '../models/audit_trail_model.dart';
import '../../../core/models/auxiliary/inspection_type.dart';

class BcoApplicationDetailsScreen extends StatefulWidget {
  final String applicationKey;

  const BcoApplicationDetailsScreen({super.key, required this.applicationKey});

  @override
  State<BcoApplicationDetailsScreen> createState() =>
      _BcoApplicationDetailsScreenState();
}

class _BcoApplicationDetailsScreenState
    extends State<BcoApplicationDetailsScreen>
    with SingleTickerProviderStateMixin {
  // Review form
  String _selectedStatus = 'APPROVED';
  final TextEditingController _commentController = TextEditingController();

  // Expandable FAB
  bool _fabExpanded = false;
  late AnimationController _fabAnimController;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _fabRotateAnimation;
  List<InspectionType> inspectionTypes = [];

  @override
  void initState() {
    super.initState();
    context.read<BcoApplicationDetailsBloc>().add(
      FetchBcoApplicationDetails(widget.applicationKey),
    );

    loadAuxiliaryData();

    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fabScaleAnimation = CurvedAnimation(
      parent: _fabAnimController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _fabRotateAnimation = Tween<double>(
      begin: 0,
      end: 0.125,
    ).animate(_fabAnimController);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  void loadAuxiliaryData() {
    final auxRepo = context.read<AuxiliaryRepository>();
    inspectionTypes = auxRepo.getInspectionTypes();
  }

  void _toggleFab() {
    setState(() => _fabExpanded = !_fabExpanded);
    if (_fabExpanded) {
      _fabAnimController.forward();
    } else {
      _fabAnimController.reverse();
    }
  }

  void _closeFab() {
    if (_fabExpanded) {
      setState(() => _fabExpanded = false);
      _fabAnimController.reverse();
    }
  }

  void _showReviewDialog() {
    _closeFab();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Review Application',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Select Status'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    items: const [
                      DropdownMenuItem(
                        value: 'APPROVED',
                        child: Text('Approve'),
                      ),
                      DropdownMenuItem(
                        value: 'REJECTED',
                        child: Text('Reject'),
                      ),
                      DropdownMenuItem(value: 'DEFERRED', child: Text('Defer')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        if (val != null) _selectedStatus = val;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text('Comment'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Enter review comments here...',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BcoApplicationDetailsBloc>().add(
                        ReviewBcoApplication(
                          applicationKey: widget.applicationKey,
                          status: _selectedStatus,
                          comment: _commentController.text.trim(),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('SUBMIT REVIEW'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showScheduleInspectionDialog() {
    _closeFab();

    int? selectedTypeId;
    DateTime? startDt;
    DateTime? endDt;
    final instructionsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    String _formatDt(DateTime? dt) => dt != null
        ? DateFormat('EEE, dd MMM yyyy — hh:mm a').format(dt)
        : 'Not selected';

    String _apiFormatDt(DateTime dt) =>
        DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);

    Future<DateTime?> _pickDt(BuildContext ctx, DateTime? initial) async {
      final date = await showDatePicker(
        context: ctx,
        initialDate: initial ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        builder: (c, child) => Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        ),
      );
      if (date == null || !ctx.mounted) return null;
      final time = await showTimePicker(
        context: ctx,
        initialTime: TimeOfDay.now(),
        builder: (c, child) => Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        ),
      );
      if (time == null) return null;
      return DateTime(date.year, date.month, date.day, time.hour, time.minute);
    }

    // ValueNotifier lets the BlocListener trigger a rebuild inside the sheet
    final errorNotifier = ValueNotifier<String?>(null);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return BlocListener<BcoCreateInspectionBloc, BcoCreateInspectionState>(
          listener: (ctx, state) {
            if (state is BcoCreateInspectionSuccess) {
              Navigator.pop(sheetContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Inspection scheduled successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<BcoCreateInspectionBloc>().add(
                ResetCreateInspection(),
              );
            } else if (state is BcoCreateInspectionError) {
              // Show error inside the sheet — snackbars are hidden behind it
              errorNotifier.value = state.message;
              context.read<BcoCreateInspectionBloc>().add(
                ResetCreateInspection(),
              );
            }
          },
          child: StatefulBuilder(
            builder: (ctx, setSheetState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  top: 24,
                  left: 20,
                  right: 20,
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: ValueListenableBuilder<String?>(
                      valueListenable: errorNotifier,
                      builder: (_, errorMsg, child) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Error banner (shown inline when API call fails)
                            if (errorMsg != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  border: Border.all(
                                    color: Colors.red.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        errorMsg,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => errorNotifier.value = null,
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            // Header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.event_note,
                                    color: AppTheme.primaryGreen,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Schedule Inspection',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Application: #${widget.applicationKey}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const Divider(height: 24),

                            // Inspection type
                            const Text(
                              'Inspection Type *',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<int>(
                              value: selectedTypeId,
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
                              hint: const Text(
                                'Select type',
                                style: TextStyle(fontSize: 13),
                              ),
                              items: inspectionTypes
                                  .map(
                                    (t) => DropdownMenuItem<int>(
                                      value: t.id,
                                      child: Text(t.name),
                                    ),
                                  )
                                  .toList(),
                              validator: (v) =>
                                  v == null ? 'Please select a type' : null,
                              onChanged: (val) =>
                                  setSheetState(() => selectedTypeId = val),
                            ),
                            const SizedBox(height: 16),

                            // Start datetime
                            const Text(
                              'Start Date & Time *',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final dt = await _pickDt(ctx, startDt);
                                if (dt != null)
                                  setSheetState(() => startDt = dt);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 13,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: startDt == null
                                        ? Colors.grey.shade300
                                        : AppTheme.primaryGreen,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      size: 16,
                                      color: startDt != null
                                          ? AppTheme.primaryGreen
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _formatDt(startDt),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: startDt != null
                                            ? Colors.black87
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // End datetime
                            const Text(
                              'End Date & Time *',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final dt = await _pickDt(ctx, endDt ?? startDt);
                                if (dt != null) setSheetState(() => endDt = dt);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 13,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: endDt == null
                                        ? Colors.grey.shade300
                                        : AppTheme.accentGold,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      size: 16,
                                      color: endDt != null
                                          ? AppTheme.accentGold
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _formatDt(endDt),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: endDt != null
                                            ? Colors.black87
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Instructions
                            const Text(
                              'Pre-Inspection Instructions',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: instructionsController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText:
                                    'Enter any pre-inspection instructions...',
                                hintStyle: const TextStyle(fontSize: 13),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.all(14),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Submit button
                            BlocBuilder<
                              BcoCreateInspectionBloc,
                              BcoCreateInspectionState
                            >(
                              builder: (ctx, state) {
                                final isLoading =
                                    state is BcoCreateInspectionLoading;
                                return ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          if (selectedTypeId == null) {
                                            errorNotifier.value =
                                                "Please select an inspection type";
                                            return;
                                          }
                                          if (startDt == null ||
                                              endDt == null) {
                                            errorNotifier.value =
                                                "Please select start and end date/time";
                                            return;
                                          }
                                          context
                                              .read<BcoCreateInspectionBloc>()
                                              .add(
                                                SubmitCreateInspection(
                                                  inspectionTypeId:
                                                      selectedTypeId!,
                                                  applicationKey:
                                                      widget.applicationKey,
                                                  start: _apiFormatDt(startDt!),
                                                  end: _apiFormatDt(endDt!),
                                                  preInspectionInstructions:
                                                      instructionsController
                                                          .text
                                                          .trim(),
                                                ),
                                              );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'SCHEDULE INSPECTION',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                          ],
                        ); // Column
                      }, // ValueListenableBuilder builder
                    ), // ValueListenableBuilder
                  ), // SingleChildScrollView
                ), // Form
              ); // Padding
            }, // StatefulBuilder builder
          ), // StatefulBuilder
        ); // BlocListener
      }, // showModalBottomSheet builder
    ); // showModalBottomSheet
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Application Details',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: AppTheme.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<BcoApplicationDetailsBloc, BcoApplicationDetailsState>(
        listener: (context, state) {
          if (state is BcoApplicationDetailsLoaded) {
            if (state.reviewSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Review submitted successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<BcoApplicationDetailsBloc>().add(
                FetchBcoApplicationDetails(widget.applicationKey),
              );
            } else if (state.reviewError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.reviewError}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is BcoApplicationDetailsLoading ||
              state is BcoApplicationDetailsInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BcoApplicationDetailsError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state is BcoApplicationDetailsLoaded) {
            final details = state.details;
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionCard(
                        title: 'General Information',
                        children: [
                          _buildDetailRow(
                            'Tracking No',
                            details.applicationKey,
                          ),
                          _buildDetailRow('Type', details.applicationType),
                          _buildDetailRow(
                            'Status',
                            (details.status ?? 'Unknown').toUpperCase(),
                          ),
                          _buildDetailRow(
                            'Location',
                            details.administrativeUnitName,
                          ),
                          _buildDetailRow(
                            'Area (sqm)',
                            details.totalSquareMetres.toString(),
                          ),
                          _buildDetailRow('Submitted', details.created),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildSectionCard(
                        title: 'Applicant Details',
                        children: [
                          _buildDetailRow('Name', details.applicant.name),
                          _buildDetailRow('Phone', details.applicant.phone),
                          _buildDetailRow('Email', details.applicant.email),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildSectionCard(
                        title: 'Attachments',
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.description,
                              color: AppTheme.primaryGreen,
                            ),
                            title: const Text(
                              'View Application Documents',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              context.push(
                                '/bco/applications/${widget.applicationKey}/attachments',
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildAuditTrailSection(state.auditTrail),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                if (state.isReviewing)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                // Dismiss tap-outside overlay when fab is expanded
                if (_fabExpanded)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _closeFab,
                      child: Container(color: Colors.transparent),
                    ),
                  ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton:
          BlocBuilder<BcoApplicationDetailsBloc, BcoApplicationDetailsState>(
            builder: (context, state) {
              if (state is BcoApplicationDetailsLoaded) {
                final isApproved =
                    (state.details.status ?? '').toUpperCase() == 'APPROVED';
                if (isApproved) return const SizedBox.shrink();

                return _buildExpandableFab();
              }
              return const SizedBox.shrink();
            },
          ),
    );
  }

  Widget _buildExpandableFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Sub-buttons (shown when expanded)
        AnimatedBuilder(
          animation: _fabScaleAnimation,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Schedule Inspection button
                ScaleTransition(
                  scale: _fabScaleAnimation,
                  child: Opacity(
                    opacity: _fabScaleAnimation.value,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Label
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A237E),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Schedule Inspection',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton.small(
                          heroTag: 'fab_schedule',
                          backgroundColor: const Color(0xFF1A237E),
                          onPressed: _showScheduleInspectionDialog,
                          child: const Icon(
                            Icons.event_note,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Review button
                // ScaleTransition(
                //   scale: _fabScaleAnimation,
                //   child: Opacity(
                //     opacity: _fabScaleAnimation.value,
                //     child: Row(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         Container(
                //           padding: const EdgeInsets.symmetric(
                //             horizontal: 12,
                //             vertical: 6,
                //           ),
                //           decoration: BoxDecoration(
                //             color: AppTheme.accentGold,
                //             borderRadius: BorderRadius.circular(8),
                //             boxShadow: [
                //               BoxShadow(
                //                 color: Colors.black.withOpacity(0.2),
                //                 blurRadius: 6,
                //                 offset: const Offset(0, 3),
                //               ),
                //             ],
                //           ),
                //           child: const Text(
                //             'Review Application',
                //             style: TextStyle(
                //               color: Colors.white,
                //               fontSize: 12,
                //               fontWeight: FontWeight.bold,
                //             ),
                //           ),
                //         ),
                //         const SizedBox(width: 8),
                //         FloatingActionButton.small(
                //           heroTag: 'fab_review',
                //           backgroundColor: AppTheme.accentGold,
                //           onPressed: _showReviewDialog,
                //           child: const Icon(
                //             Icons.rate_review,
                //             color: Colors.white,
                //             size: 20,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                const SizedBox(height: 10),
              ],
            );
          },
        ),

        // Main FAB
        RotationTransition(
          turns: _fabRotateAnimation,
          child: FloatingActionButton(
            heroTag: 'fab_main',
            onPressed: _toggleFab,
            backgroundColor: AppTheme.primaryGreen,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildAuditTrailSection(List<AuditTrailModel> trails) {
    if (trails.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Text(
            'Audit Trail',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
          const Divider(height: 24, thickness: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: trails.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final trail = trails[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trail.date,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trail.comment,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () {
                context.read<BcoApplicationDetailsBloc>().add(
                  LoadMoreBcoAuditTrail(widget.applicationKey),
                );
              },
              child: const Text(
                'Load More Comments',
                style: TextStyle(color: AppTheme.primaryGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
          const Divider(height: 24, thickness: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
