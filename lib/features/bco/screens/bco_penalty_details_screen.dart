import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme.dart';
import '../bloc/penalty_details/bco_penalty_details_bloc.dart';
import '../bloc/penalty_details/bco_penalty_details_event.dart';
import '../bloc/penalty_details/bco_penalty_details_state.dart';

class BcoPenaltyDetailsScreen extends StatefulWidget {
  final String reference;

  const BcoPenaltyDetailsScreen({super.key, required this.reference});

  @override
  State<BcoPenaltyDetailsScreen> createState() => _BcoPenaltyDetailsScreenState();
}

class _BcoPenaltyDetailsScreenState extends State<BcoPenaltyDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BcoPenaltyDetailsBloc>().add(FetchBcoPenaltyDetails(widget.reference));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Penalty Details', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: AppTheme.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<BcoPenaltyDetailsBloc, BcoPenaltyDetailsState>(
        builder: (context, state) {
          if (state is BcoPenaltyDetailsLoading || state is BcoPenaltyDetailsInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BcoPenaltyDetailsError) {
            return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)));
          } else if (state is BcoPenaltyDetailsLoaded) {
            final penalty = state.penalty;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   _buildSectionCard(
                    title: 'General Information',
                    children: [
                      _buildDetailRow('Reference', penalty.reference),
                      _buildDetailRow('Status', penalty.status.toUpperCase()),
                      _buildDetailRow('Amount', 'UGX ${penalty.amount}'),
                      _buildDetailRow('Date Issued', penalty.dateOfOffence),
                      _buildDetailRow('Issued By', penalty.issuedBy),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildSectionCard(
                    title: 'Offence Details',
                    children: [
                      _buildDetailRow('Offence', penalty.offenceName),
                      _buildDetailRow('Enactment', penalty.offenceEnactment),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildSectionCard(
                    title: 'Location Information',
                    children: [
                      _buildDetailRow('Location', penalty.location),
                      _buildDetailRow('Admin Unit', '${penalty.administrativeUnitName} (${penalty.administrativeUnitType})'),
                      _buildDetailRow('Postal Address', penalty.postalAddress),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildSectionCard(
                    title: 'Offender Details',
                    children: [
                      _buildDetailRow('Name', penalty.offenderName),
                      _buildDetailRow('Sex', penalty.offenderSex),
                      _buildDetailRow('Age', penalty.offenderAge.toString()),
                      _buildDetailRow('Phone', penalty.offenderPhone),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildSectionCard(
                    title: 'Building Details',
                    children: [
                      _buildDetailRow('Class', penalty.buildingClass),
                      _buildDetailRow('Permit No', penalty.buildingPermitNumber.isNotEmpty ? penalty.buildingPermitNumber : 'N/A'),
                      _buildDetailRow('Occupation Permit', penalty.occupationPermitNumber.isNotEmpty ? penalty.occupationPermitNumber : 'N/A'),
                      _buildDetailRow('Square Metres', penalty.squareMetres),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
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
