import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme.dart';
import '../bloc/application_details/bco_application_details_bloc.dart';
import '../bloc/application_details/bco_application_details_event.dart';
import '../bloc/application_details/bco_application_details_state.dart';
import '../models/audit_trail_model.dart';

class BcoApplicationDetailsScreen extends StatefulWidget {
  final String applicationKey;

  const BcoApplicationDetailsScreen({super.key, required this.applicationKey});

  @override
  State<BcoApplicationDetailsScreen> createState() => _BcoApplicationDetailsScreenState();
}

class _BcoApplicationDetailsScreenState extends State<BcoApplicationDetailsScreen> {
  String _selectedStatus = 'APPROVED';
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<BcoApplicationDetailsBloc>().add(FetchBcoApplicationDetails(widget.applicationKey));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _showReviewDialog() {
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
                      DropdownMenuItem(value: 'APPROVED', child: Text('Approve')),
                      DropdownMenuItem(value: 'REJECTED', child: Text('Reject')),
                      DropdownMenuItem(value: 'DEFERRED', child: Text('Defer')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        if (val != null) _selectedStatus = val;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text('Comment'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Application Details', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: AppTheme.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<BcoApplicationDetailsBloc, BcoApplicationDetailsState>(
        listener: (context, state) {
          if (state is BcoApplicationDetailsLoaded) {
            if (state.reviewSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review submitted successfully!'), backgroundColor: Colors.green),
              );
              // Refetch details to get updated status and trail
              context.read<BcoApplicationDetailsBloc>().add(FetchBcoApplicationDetails(widget.applicationKey));
            } else if (state.reviewError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.reviewError}'), backgroundColor: Colors.red),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is BcoApplicationDetailsLoading || state is BcoApplicationDetailsInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BcoApplicationDetailsError) {
            return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)));
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
                          _buildDetailRow('Tracking No', details.applicationKey),
                          _buildDetailRow('Type', details.applicationType),
                          _buildDetailRow('Status', (details.status ?? 'Unknown').toUpperCase()),
                          _buildDetailRow('Location', details.administrativeUnitName),
                          _buildDetailRow('Area (sqm)', details.totalSquareMetres.toString()),
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
                      _buildAuditTrailSection(state.auditTrail),
                      const SizedBox(height: 80), // Fab space
                    ],
                  ),
                ),
                if (state.isReviewing)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<BcoApplicationDetailsBloc, BcoApplicationDetailsState>(
        builder: (context, state) {
          if (state is BcoApplicationDetailsLoaded) {
            if ((state.details.status ?? 'Unknown').toUpperCase() != 'APPROVED') {
              return FloatingActionButton.extended(
                onPressed: _showReviewDialog,
                backgroundColor: AppTheme.accentGold,
                icon: const Icon(Icons.rate_review, color: Colors.white),
                label: const Text('REVIEW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              );
            }
          }
          return const SizedBox.shrink();
        },
      ),
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Audit Trail',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
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
                      style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trail.comment,
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
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
                context.read<BcoApplicationDetailsBloc>().add(LoadMoreBcoAuditTrail(widget.applicationKey));
              },
              child: const Text('Load More Comments', style: TextStyle(color: AppTheme.primaryGreen)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
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
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500))),
          Expanded(flex: 3, child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87))),
        ],
      ),
    );
  }
}
