import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../bloc/whistleblow_details/bco_whistleblow_details_bloc.dart';
import '../bloc/whistleblow_details/bco_whistleblow_details_event.dart';
import '../bloc/whistleblow_details/bco_whistleblow_details_state.dart';
import '../models/bco_whistleblow_model.dart';

class BcoWhistleblowDetailsScreen extends StatefulWidget {
  final String reference;
  const BcoWhistleblowDetailsScreen({super.key, required this.reference});

  @override
  State<BcoWhistleblowDetailsScreen> createState() => _BcoWhistleblowDetailsScreenState();
}

class _BcoWhistleblowDetailsScreenState extends State<BcoWhistleblowDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BcoWhistleblowDetailsBloc>().add(FetchBcoWhistleblowDetails(widget.reference));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Report Details', style: TextStyle(fontSize: 16)),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<BcoWhistleblowDetailsBloc, BcoWhistleblowDetailsState>(
        builder: (context, state) {
          if (state is BcoWhistleblowDetailsLoading || state is BcoWhistleblowDetailsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BcoWhistleblowDetailsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)),
                  TextButton(
                    onPressed: () {
                      context.read<BcoWhistleblowDetailsBloc>().add(FetchBcoWhistleblowDetails(widget.reference));
                    },
                    child: const Text('Retry'),
                  )
                ],
              ),
            );
          }

          if (state is BcoWhistleblowDetailsLoaded) {
            final report = state.whistleblow;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4F4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          report.feedbackType,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.danger,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        report.description.isNotEmpty ? report.description : 'No description provided.',
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 15),
                      const Divider(),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Date Reported:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                            report.createdAt.replaceAll('T', ' ').split('.').first,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Location Details
                const Text(
                  'LOCATION DETAILS',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, letterSpacing: 1),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(Icons.location_on, 'Location', report.location),
                      const SizedBox(height: 15),
                      _buildDetailRow(Icons.map, 'Admin Unit', '${report.administrativeUnitType} - ${report.administrativeUnitName}'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Contact Details
                const Text(
                  'CONTACT DETAILS',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, letterSpacing: 1),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(Icons.person, 'Name', report.name),
                      const SizedBox(height: 15),
                      _buildDetailRow(Icons.phone, 'Phone', report.phone),
                      const SizedBox(height: 15),
                      _buildDetailRow(Icons.email, 'Email', report.email.isNotEmpty ? report.email : 'N/A'),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
