import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/theme.dart';
import '../bloc/application_details/client_application_details_bloc.dart';
import '../bloc/application_details/client_application_details_event.dart';
import '../bloc/application_details/client_application_details_state.dart';

class ClientApplicationDetailsScreen extends StatefulWidget {
  final String applicationKey;

  const ClientApplicationDetailsScreen({
    super.key,
    required this.applicationKey,
  });

  @override
  State<ClientApplicationDetailsScreen> createState() =>
      _ClientApplicationDetailsScreenState();
}

class _ClientApplicationDetailsScreenState
    extends State<ClientApplicationDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ClientApplicationDetailsBloc>().add(
      FetchClientApplicationDetails(widget.applicationKey),
    );
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
        elevation: 0,
      ),
      body:
          BlocConsumer<
            ClientApplicationDetailsBloc,
            ClientApplicationDetailsState
          >(
            listener: (context, state) {
              if (state is ClientApplicationDetailsLoaded) {
                if (state.downloadPdfPath != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Download complete. Opening file...'),
                    ),
                  );
                  OpenFilex.open(state.downloadPdfPath!);
                } else if (state.downloadPdfError != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Download failed: ${state.downloadPdfError}',
                      ),
                      backgroundColor: AppTheme.danger,
                    ),
                  );
                }
              }
            },
            builder: (context, state) {
              if (state is ClientApplicationDetailsLoading ||
                  state is ClientApplicationDetailsInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ClientApplicationDetailsError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 50,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Error: ${state.message}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ClientApplicationDetailsBloc>().add(
                              FetchClientApplicationDetails(
                                widget.applicationKey,
                              ),
                            );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (state is ClientApplicationDetailsLoaded) {
                final details = state.application;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: state.isDownloadingPdf
                              ? null
                              : () {
                                  context
                                      .read<ClientApplicationDetailsBloc>()
                                      .add(
                                        DownloadClientApplicationPdf(
                                          details.applicationKey,
                                        ),
                                      );
                                },
                          icon: state.isDownloadingPdf
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.download, size: 20),
                          label: Text(
                            state.isDownloadingPdf
                                ? 'DOWNLOADING...'
                                : 'DOWNLOAD PDF',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildSectionCard(
                        title: 'General Information',
                        children: [
                          _buildDetailRow(
                            'Tracking No',
                            details.applicationKey,
                          ),
                          _buildDetailRow('Type', details.applicationType),
                          _buildDetailRow(
                            'Classification',
                            details.buildingClassification,
                          ),
                          _buildDetailRow(
                            'Operation',
                            details.buildingOperation,
                          ),
                          _buildDetailRow('Purpose', details.buildingPurpose),
                          _buildDetailRow(
                            'Admin Unit Type',
                            details.administrativeUnitType,
                          ),
                          _buildDetailRow(
                            'Location',
                            details.administrativeUnitName,
                          ),
                          _buildDetailRow(
                            'Area (sqm)',
                            details.totalSquareMetres.toString(),
                          ),
                          _buildDetailRow('Created', details.created),
                          _buildDetailRow('Updated', details.updated),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildSectionCard(
                        title: 'Applicant Details',
                        children: [
                          _buildDetailRow('Name', details.applicant.name),
                          _buildDetailRow('Phone', details.applicant.phone),
                          _buildDetailRow('Email', details.applicant.email),
                          _buildDetailRow(
                            'TIN',
                            details.applicant.tin.isEmpty
                                ? 'N/A'
                                : details.applicant.tin,
                          ),
                          _buildDetailRow(
                            'NIN',
                            details.applicant.nin.isEmpty
                                ? 'N/A'
                                : details.applicant.nin,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildSectionCard(
                        title: 'Engaged Professionals',
                        children: [
                          if (details.professionalsEngaged.architect != null)
                            ..._buildProfessionalDetails(
                              'Architect',
                              details.professionalsEngaged.architect!,
                            ),
                          if (details.professionalsEngaged.quantitySurveyor !=
                              null)
                            ..._buildProfessionalDetails(
                              'Quantity Surveyor',
                              details.professionalsEngaged.quantitySurveyor!,
                            ),
                          // Add other professionals as needed from lists
                        ],
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

  List<Widget> _buildProfessionalDetails(String role, dynamic professional) {
    return [
      Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
        child: Text(
          role,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      _buildDetailRow('Name', professional.name),
      _buildDetailRow('Reg No', professional.regNo),
      _buildDetailRow('Address', professional.address),
      const SizedBox(height: 8),
    ];
  }
}
