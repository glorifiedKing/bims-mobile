import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme.dart';
import '../bloc/invoice_details/client_invoice_details_bloc.dart';
import '../bloc/invoice_details/client_invoice_details_event.dart';
import '../bloc/invoice_details/client_invoice_details_state.dart';
import '../../../core/utils/currency_formatter.dart';

class ClientInvoiceDetailsScreen extends StatefulWidget {
  final String prn;

  const ClientInvoiceDetailsScreen({super.key, required this.prn});

  @override
  State<ClientInvoiceDetailsScreen> createState() =>
      _ClientInvoiceDetailsScreenState();
}

class _ClientInvoiceDetailsScreenState
    extends State<ClientInvoiceDetailsScreen> {
  final _keyBottomNav = GlobalKey();

  @override
  void initState() {
    super.initState();
    context.read<ClientInvoiceDetailsBloc>().add(
      FetchClientInvoiceDetails(widget.prn),
    );
  }

  Future<void> _launchExternalUrl(String? url) async {
    if (url == null || url.toString().trim().isEmpty) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Invoice Details',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: AppTheme.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: BlocBuilder<ClientInvoiceDetailsBloc, ClientInvoiceDetailsState>(
        builder: (context, state) {
          if (state is ClientInvoiceDetailsLoading ||
              state is ClientInvoiceDetailsInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ClientInvoiceDetailsError) {
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
                        context.read<ClientInvoiceDetailsBloc>().add(
                          FetchClientInvoiceDetails(widget.prn),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is ClientInvoiceDetailsLoaded) {
            final details = state.invoice;

            Color statusColor = details.paid
                ? const Color(0xFF1E7E34)
                : const Color(0xFFB8860B);
            Color statusBg = details.paid
                ? const Color(0xFFE6F4EA)
                : const Color(0xFFFFF9E6);
            String statusText = details.paid ? 'PAID' : 'PENDING PAYMENT';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'STATUS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: details.paid
                              ? [
                                  OutlinedButton.icon(
                                    onPressed: () => _launchExternalUrl(
                                      details.documents?['receipt'],
                                    ),
                                    icon: const Icon(
                                      Icons.download_rounded,
                                      size: 16,
                                    ),
                                    label: const Text('RECEIPT'),
                                  ),
                                ]
                              : [
                                  OutlinedButton.icon(
                                    onPressed: () => _launchExternalUrl(
                                      details.documents?['invoice'],
                                    ),
                                    icon: const Icon(
                                      Icons.download_rounded,
                                      size: 16,
                                    ),
                                    label: const Text('INVOICE PDF'),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final uri = Uri.parse('tel:*185%23');
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri);
                                      }
                                    },
                                    icon: const Icon(Icons.payment, size: 16),
                                    label: const Text('PAY'),
                                  ),
                                ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildSectionCard(
                    title: 'Payment Information',
                    children: [
                      _buildDetailRow('PRN', details.prn),
                      _buildDetailRow('Search Code', details.searchCode),
                      _buildDetailRow(
                        'Declaration Type',
                        details.declarationType,
                      ),
                      _buildDetailRow(
                        'Assessment Amount',
                        CurrencyFormatter.formatUgx(
                          double.tryParse(details.assessmentAmount) ?? 0,
                        ),
                      ),
                      _buildDetailRow(
                        'Inspection Fees',
                        CurrencyFormatter.formatUgx(
                          double.tryParse(details.inspectionFees) ?? 0,
                        ),
                      ),
                      _buildDetailRow(
                        'Landscaping Fees',
                        CurrencyFormatter.formatUgx(
                          double.tryParse(details.landscapingFees) ?? 0,
                        ),
                      ),
                      _buildDetailRow('Created', details.created),
                      _buildDetailRow('Expires', details.expires),
                      if (details.datePaid.isNotEmpty)
                        _buildDetailRow('Date Paid', details.datePaid),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildSectionCard(
                    title: 'Application Details',
                    children: [
                      _buildDetailRow(
                        'Application Key',
                        details.application.applicationKey,
                      ),
                      _buildDetailRow(
                        'Type',
                        details.application.applicationType,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildSectionCard(
                    title: 'Building Information',
                    children: [
                      _buildDetailRow('Operation', details.building.operation),
                      _buildDetailRow(
                        'Classification',
                        details.building.classification,
                      ),
                      _buildDetailRow('Purpose', details.building.purpose),
                      _buildDetailRow('Location', details.building.location),
                      _buildDetailRow(
                        'Built Up Area',
                        '${details.building.builtUpArea} sqm',
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildSectionCard(
                    title: 'Administrative Unit',
                    children: [
                      _buildDetailRow('Type', details.administrativeUnit.type),
                      _buildDetailRow('Name', details.administrativeUnit.name),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildSectionCard(
                    title: 'Applicant Information',
                    children: [
                      _buildDetailRow('Name', details.applicant.name),
                      _buildDetailRow('Phone', details.applicant.phone),
                      _buildDetailRow('Email', details.applicant.email),
                      _buildDetailRow(
                        'NIN',
                        details.applicant.nin.isEmpty
                            ? 'N/A'
                            : details.applicant.nin,
                      ),
                      _buildDetailRow('Type', details.applicant.type),
                    ],
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        key: _keyBottomNav,
        currentIndex: 2, // Invoices index
        onTap: (index) {
          if (index == 0) context.go('/client/dashboard');
          if (index == 1) context.go('/client/applications');
          if (index == 2) return;
          if (index == 3) context.go('/client/profile');
        },
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Applications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Invoices'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
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
