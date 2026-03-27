import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme.dart';
import '../bloc/permit_details/client_permit_details_bloc.dart';
import '../bloc/permit_details/client_permit_details_event.dart';
import '../bloc/permit_details/client_permit_details_state.dart';
import '../models/permit_detail_model.dart';

class ClientPermitDetailsScreen extends StatefulWidget {
  final String? serialNo; // Made optional since we might already have the data
  final PermitDetailModel?
  preloadedPermit; // Caches API payload from public scan

  const ClientPermitDetailsScreen({
    super.key,
    this.serialNo,
    this.preloadedPermit,
  });

  @override
  State<ClientPermitDetailsScreen> createState() =>
      _ClientPermitDetailsScreenState();
}

class _ClientPermitDetailsScreenState extends State<ClientPermitDetailsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.preloadedPermit == null && widget.serialNo != null) {
      context.read<ClientPermitDetailsBloc>().add(
        FetchClientPermitDetails(widget.serialNo!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Permit Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: widget.preloadedPermit != null
          ? _buildContent(widget.preloadedPermit!)
          : BlocBuilder<ClientPermitDetailsBloc, ClientPermitDetailsState>(
              builder: (context, state) {
                if (state is ClientPermitDetailsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                    ),
                  );
                } else if (state is ClientPermitDetailsError) {
                  return _buildErrorState(state.message);
                } else if (state is ClientPermitDetailsLoaded) {
                  return _buildContent(state.permit);
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              'Error loading permit details:\n$message',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (widget.serialNo != null) {
                  context.read<ClientPermitDetailsBloc>().add(
                    FetchClientPermitDetails(widget.serialNo!),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(PermitDetailModel permit) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionCard('Permit Overview', Icons.verified_user, [
          _buildDetailRow('Permit Number', permit.permitNumber),
          _buildDetailRow('Serial Number', permit.permitSerial),
          _buildDetailRow('Type', permit.permitType),
          _buildDetailRow('Issued Date', permit.permitIssueDate),
          _buildDetailRow('Expiry Date', permit.permitExpiryDate),
          _buildDetailRow(
            'Approval Fees',
            '${permit.approvalFeesPaid} UGX',
            highlight: true,
          ),
        ]),
        _buildSectionCard('Building Information', Icons.business, [
          _buildDetailRow('Operation', permit.building.operation),
          _buildDetailRow('Classification', permit.building.classification),
          _buildDetailRow('Purpose', permit.building.purpose),
          _buildDetailRow(
            'Built-up Area',
            '${permit.building.builtUpArea} sqm',
          ),
          _buildDetailRow('Location', permit.building.location),
          if (permit.building.plotNo.isNotEmpty)
            _buildDetailRow('Plot No', permit.building.plotNo),
          if (permit.building.blockNo.isNotEmpty)
            _buildDetailRow('Block No', permit.building.blockNo),
        ]),
        _buildSectionCard('Administrative Unit', Icons.map, [
          _buildDetailRow('Type', permit.administrativeUnit.type),
          _buildDetailRow('Name', permit.administrativeUnit.name),
        ]),
        _buildSectionCard('Applicant Information', Icons.person, [
          _buildDetailRow('Name', permit.applicant.name),
          _buildDetailRow('Type', permit.applicant.type),
          _buildDetailRow('Phone', permit.applicant.phone),
          if (permit.applicant.email.isNotEmpty)
            _buildDetailRow('Email', permit.applicant.email),
          if (permit.applicant.nin.isNotEmpty)
            _buildDetailRow('NIN', permit.applicant.nin),
          if (permit.applicant.tin.isNotEmpty)
            _buildDetailRow('TIN', permit.applicant.tin),
        ]),
        _buildProfessionalsCard(permit.professionalsEngaged),
        const SizedBox(height: 20),
        if (permit.link.isNotEmpty) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download),
              label: const Text('DOWNLOAD PERMIT SECURE LINK'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildProfessionalsCard(PermitProfessionals pros) {
    if (pros.architect == null &&
        pros.structuralEngineer == null &&
        pros.quantitySurveyor == null &&
        pros.mechanicalEngineer == null &&
        pros.electricalEngineer == null) {
      return const SizedBox.shrink();
    }

    List<Widget> children = [];
    if (pros.architect != null) {
      children.add(_buildProfessionalSubSection('Architect', pros.architect!));
    }
    if (pros.structuralEngineer != null) {
      children.add(
        _buildProfessionalSubSection(
          'Structural Engineer',
          pros.structuralEngineer!,
        ),
      );
    }
    if (pros.quantitySurveyor != null) {
      children.add(
        _buildProfessionalSubSection(
          'Quantity Surveyor',
          pros.quantitySurveyor!,
        ),
      );
    }
    if (pros.mechanicalEngineer != null) {
      children.add(
        _buildProfessionalSubSection(
          'Mechanical Engineer',
          pros.mechanicalEngineer!,
        ),
      );
    }
    if (pros.electricalEngineer != null) {
      children.add(
        _buildProfessionalSubSection(
          'Electrical Engineer',
          pros.electricalEngineer!,
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.engineering, color: AppTheme.primaryGreen, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Professionals Engaged',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalSubSection(String role, PermitProfessional pro) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          _buildDetailRow('Name', pro.name),
          _buildDetailRow('Reg No', pro.regNo),
          if (pro.discipline.isNotEmpty)
            _buildDetailRow('Discipline', pro.discipline),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryGreen, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool highlight = false}) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                color: highlight ? AppTheme.primaryGreen : Colors.black87,
                fontSize: 13,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
