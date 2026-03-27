class InspectionInvoiceModel {
  final String prn;
  final String searchCode;
  final String referencedPermitSerial;
  final int invoiceAmount;
  final int inspectionFeesYear;
  final String inspectionFeesCoverPeriod;
  final String paymentStatus;
  final String datePaid;
  final String created;
  final String expires;
  final Map<String, dynamic>? documents;

  InspectionInvoiceModel({
    required this.prn,
    required this.searchCode,
    required this.referencedPermitSerial,
    required this.invoiceAmount,
    required this.inspectionFeesYear,
    required this.inspectionFeesCoverPeriod,
    required this.paymentStatus,
    required this.datePaid,
    required this.created,
    required this.expires,
    this.documents,
  });

  factory InspectionInvoiceModel.fromJson(Map<String, dynamic> json) {
    return InspectionInvoiceModel(
      prn: json['prn'] ?? '',
      searchCode: json['search_code'] ?? '',
      referencedPermitSerial: json['referenced_permit_serial'] ?? '',
      invoiceAmount: json['invoice_amount'] ?? 0,
      inspectionFeesYear: json['inspection_fees_year'] ?? 0,
      inspectionFeesCoverPeriod: json['inspection_fees_cover_period'] ?? '',
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      datePaid: json['date_paid'] ?? '',
      created: json['created'] ?? '',
      expires: json['expires'] ?? '',
      documents: json['documents'] as Map<String, dynamic>?,
    );
  }
}
