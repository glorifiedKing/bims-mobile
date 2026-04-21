import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../bloc/application_details/professional_application_details_bloc.dart';
import '../bloc/application_details/professional_application_details_event.dart';
import '../bloc/application_details/professional_application_details_state.dart';

class ProfessionalApplicationDetailsScreen extends StatefulWidget {
  final String applicationKey;

  const ProfessionalApplicationDetailsScreen({
    super.key,
    required this.applicationKey,
  });

  @override
  State<ProfessionalApplicationDetailsScreen> createState() => _ProfessionalApplicationDetailsScreenState();
}

class _ProfessionalApplicationDetailsScreenState extends State<ProfessionalApplicationDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfessionalApplicationDetailsBloc>().add(
      FetchProfessionalApplicationDetails(widget.applicationKey),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy HH:mm').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Application Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<ProfessionalApplicationDetailsBloc, ProfessionalApplicationDetailsState>(
        builder: (context, state) {
          if (state is ProfessionalApplicationDetailsLoading || state is ProfessionalApplicationDetailsInitial) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          } else if (state is ProfessionalApplicationDetailsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.danger, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load details',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                      onPressed: () {
                        context.read<ProfessionalApplicationDetailsBloc>().add(
                          FetchProfessionalApplicationDetails(widget.applicationKey),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is ProfessionalApplicationDetailsLoaded) {
            final app = state.details;

            Color statusColor = Colors.grey;
            Color statusBg = Colors.grey.shade200;

            if (app.status.toUpperCase() == 'PENDING') {
              statusColor = const Color(0xFFB8860B);
              statusBg = const Color(0xFFFFF9E6);
            } else if (app.status.toUpperCase() == 'NOT CONFIRMED' || app.status.toUpperCase() == 'NOT  CONFIRMED') {
              statusColor = AppTheme.danger;
              statusBg = const Color(0xFFFFEBEB);
            } else if (app.status.toUpperCase() == 'CONFIRMED') {
              statusColor = AppTheme.primaryGreen;
              statusBg = const Color(0xFFE8F5E9);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
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
                              app.code,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                app.status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 20),

                        _buildInfoRow('Developer Name', app.developerName ?? 'Unknown'),
                        const SizedBox(height: 15),
                        _buildInfoRow('Created On', _formatDate(app.createdOn)),
                        const SizedBox(height: 15),
                        _buildInfoRow('Updated On', _formatDate(app.updateOn)),
                        const SizedBox(height: 15),
                        if (app.confirmationDate != null) ...[
                          _buildInfoRow('Confirmed On', _formatDate(app.confirmationDate)),
                          const SizedBox(height: 15),
                        ],
                        _buildInfoRow('Applicant Key', app.applicantKey),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
