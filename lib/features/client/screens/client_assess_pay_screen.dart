import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/models/auxiliary/payment_mode.dart';
import '../../../core/repositories/auxiliary_repository.dart';
import '../bloc/assessment/client_assessment_bloc.dart';
import '../bloc/assessment/client_assessment_event.dart';
import '../bloc/assessment/client_assessment_state.dart';
import '../repositories/client_repository.dart';
import '../models/assessment_model.dart';

class ClientAssessPayScreen extends StatefulWidget {
  final String applicationKey;

  const ClientAssessPayScreen({super.key, required this.applicationKey});

  @override
  State<ClientAssessPayScreen> createState() => _ClientAssessPayScreenState();
}

class _ClientAssessPayScreenState extends State<ClientAssessPayScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPaymentModeId;
  List<PaymentMode> _paymentModes = [];

  @override
  void initState() {
    super.initState();
    _paymentModes = context.read<AuxiliaryRepository>().getPaymentModes();
    context.read<ClientAssessmentBloc>().add(
      FetchAssessment(widget.applicationKey),
    );
  }

  void _generatePrn(AssessmentModel assessment) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ClientAssessmentBloc>().add(
        GeneratePrn(
          applicationKey: widget.applicationKey,
          data: {
            'amount': assessment.assessment.totalDue,
            'paymentMode': _selectedPaymentModeId,
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        title: const Text(
          'ASSESS & PAY',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: BlocConsumer<ClientAssessmentBloc, ClientAssessmentState>(
        listener: (context, state) {
          if (state is ClientAssessmentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ClientAssessmentPrnGenerated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PRN Generated Successfully!')),
            );
            // Redirect to invoice details with PRN
            context.go('/client/invoices/${state.prn}');
          }
        },
        builder: (context, state) {
          if (state is ClientAssessmentLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ClientAssessmentLoaded) {
            return _buildContent(state.assessmentModel);
          } else if (state is ClientAssessmentError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ClientAssessmentBloc>().add(
                        FetchAssessment(widget.applicationKey),
                      );
                    },
                    child: const Text('Retry'),
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

  Widget _buildContent(AssessmentModel model) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('APPLICATION DETAILS'),
            _buildDetailRow(
              'Application Type',
              model.application.applicationType,
            ),
            _buildDetailRow(
              'Applicant Name',
              model.application.nameOfApplicant,
            ),
            _buildDetailRow('Operation', model.application.buildingOperation),
            _buildDetailRow('Purpose', model.application.buildingPurpose),
            _buildDetailRow(
              'Authority',
              '${model.application.administrativeUnit} (${model.application.administrativeUnitType})',
            ),
            _buildDetailRow('Total SQM', model.application.totalSQM.toString()),

            const SizedBox(height: 24),
            _buildSectionHeader('ASSESSMENT DETAILS'),
            _buildDetailRow('Assessment Type', model.assessment.assessmentType),
            _buildDetailRow(
              'Scrutiny Rate / SQM',
              CurrencyFormatter.formatUgx(
                double.tryParse(model.assessment.rateScrutinyPerSQM) ?? 0,
              ),
            ),
            _buildDetailRow(
              'Inspection Rate / SQM',
              CurrencyFormatter.formatUgx(
                double.tryParse(model.assessment.rateInspectionPerSQM) ?? 0,
              ),
            ),
            _buildDetailRow(
              'Scrutiny Fees',
              CurrencyFormatter.formatUgx(
                double.tryParse(model.assessment.scrutinyFees.toString()) ?? 0,
              ),
            ),
            _buildDetailRow(
              'Inspection Fees',
              CurrencyFormatter.formatUgx(
                double.tryParse(model.assessment.inspectionFees.toString()) ??
                    0,
              ),
            ),

            const Divider(height: 32, thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL DUE',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  CurrencyFormatter.formatUgx(
                    double.tryParse(model.assessment.totalDue.toString()) ?? 0,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.accentGold,
                  ),
                ),
              ],
            ),
            if (model.assessment.totalDue <= 0.0) ...[
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'No pending fees to pay',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
            if (model.assessment.totalDue > 0.0) ...[
              const SizedBox(height: 32),
              const Text(
                'PAYMENT MODE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
                hint: const Text('Select Payment Mode'),
                value: _selectedPaymentModeId,
                items: _paymentModes.map((mode) {
                  return DropdownMenuItem(
                    value: mode.id.toString(),
                    child: Text(mode.name),
                  );
                }).toList(),
                validator: (val) =>
                    val == null ? 'Please select a payment mode' : null,
                onChanged: (val) {
                  setState(() => _selectedPaymentModeId = val);
                },
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _generatePrn(model),
                  child: const Text(
                    'GENERATE PRN',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.primaryGreen,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
