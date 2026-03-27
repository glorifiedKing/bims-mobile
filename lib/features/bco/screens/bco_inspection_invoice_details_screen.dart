import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme.dart';
import '../bloc/inspection_invoice_details/bco_inspection_invoice_details_bloc.dart';
import '../bloc/inspection_invoice_details/bco_inspection_invoice_details_event.dart';
import '../bloc/inspection_invoice_details/bco_inspection_invoice_details_state.dart';
import '../../../core/utils/currency_formatter.dart';

class BcoInspectionInvoiceDetailsScreen extends StatefulWidget {
  final String prn;

  const BcoInspectionInvoiceDetailsScreen({super.key, required this.prn});

  @override
  State<BcoInspectionInvoiceDetailsScreen> createState() => _BcoInspectionInvoiceDetailsScreenState();
}

class _BcoInspectionInvoiceDetailsScreenState extends State<BcoInspectionInvoiceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BcoInspectionInvoiceDetailsBloc>().add(FetchBcoInspectionInvoiceDetails(widget.prn));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Inspection Fees Details', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: AppTheme.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: BlocBuilder<BcoInspectionInvoiceDetailsBloc, BcoInspectionInvoiceDetailsState>(
        builder: (context, state) {
          if (state is BcoInspectionInvoiceDetailsLoading || state is BcoInspectionInvoiceDetailsInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BcoInspectionInvoiceDetailsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 50),
                    const SizedBox(height: 10),
                    Text('Error: ${state.message}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<BcoInspectionInvoiceDetailsBloc>().add(FetchBcoInspectionInvoiceDetails(widget.prn));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is BcoInspectionInvoiceDetailsLoaded) {
            final details = state.details;

            Color statusColor = details.paymentStatus.toUpperCase() == 'PAID' ? const Color(0xFF1E7E34) : const Color(0xFFB8860B);
            Color statusBg = details.paymentStatus.toUpperCase() == 'PAID' ? const Color(0xFFE6F4EA) : const Color(0xFFFFF9E6);
            String statusText = details.paymentStatus.toUpperCase() == 'PAID' ? 'PAID' : 'PENDING PAYMENT';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('STATUS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                        Text(statusText, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: statusColor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildSectionCard(
                    title: 'Invoice Information',
                    children: [
                      _buildDetailRow('PRN', details.prn),
                      _buildDetailRow('Search Code', details.searchCode),
                      _buildDetailRow('Reference Permit', details.referencedPermitSerial),
                      _buildDetailRow('Invoice Amount', CurrencyFormatter.formatUgx(details.invoiceAmount.toDouble())),
                      _buildDetailRow('Cover Period', details.inspectionFeesCoverPeriod),
                      _buildDetailRow('Year', details.inspectionFeesYear.toString()),
                      _buildDetailRow('Created', details.created),
                      _buildDetailRow('Expires', details.expires),
                      if (details.datePaid.isNotEmpty) _buildDetailRow('Date Paid', details.datePaid),
                    ],
                  ),
                  const SizedBox(height: 15),
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
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
