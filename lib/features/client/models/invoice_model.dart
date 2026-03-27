class InvoiceModel {
  final String applicationKey;
  final String prn;
  final String searchCode;
  final String declarationType;
  final String assessmentAmount;
  final String inspectionFees;
  final String landscapingFees;
  final String paymentStatus;
  final String created;
  final String expires;
  final Map<String, dynamic>? documents;

  InvoiceModel({
    required this.applicationKey,
    required this.prn,
    required this.searchCode,
    required this.declarationType,
    required this.assessmentAmount,
    required this.inspectionFees,
    required this.landscapingFees,
    required this.paymentStatus,
    required this.created,
    required this.expires,
    this.documents,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      applicationKey: json['application_key'] ?? '',
      prn: json['prn'] ?? '',
      searchCode: json['search_code'] ?? '',
      declarationType: json['declaration_type'] ?? '',
      assessmentAmount: json['assessment_amount'] ?? '0.00',
      inspectionFees: json['inspection_fees'] ?? '0.00',
      landscapingFees: json['landscaping_fees'] ?? '0.00',
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      created: json['created'] ?? '',
      expires: json['expires'] ?? '',
      documents: json['documents'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'application_key': applicationKey,
      'prn': prn,
      'search_code': searchCode,
      'declaration_type': declarationType,
      'assessment_amount': assessmentAmount,
      'inspection_fees': inspectionFees,
      'landscaping_fees': landscapingFees,
      'payment_status': paymentStatus,
      'created': created,
      'expires': expires,
      'documents': documents,
    };
  }
}
