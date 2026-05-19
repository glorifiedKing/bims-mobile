class ExpressPenaltyInvoiceModel {
  final String referencedOffenceSerial;
  final String offenderName;
  final String offenderPhone;
  final String offenceName;
  final String offenceEnactment;
  final String prn;
  final String searchCode;
  final String amount;
  final String status;
  final String created;
  final String expires;
  final Map<String, dynamic>? documents;

  ExpressPenaltyInvoiceModel({
    required this.referencedOffenceSerial,
    required this.offenderName,
    required this.offenderPhone,
    required this.offenceName,
    required this.offenceEnactment,
    required this.prn,
    required this.searchCode,
    required this.amount,
    required this.status,
    required this.created,
    required this.expires,
    this.documents,
  });

  factory ExpressPenaltyInvoiceModel.fromJson(Map<String, dynamic> json) {
    return ExpressPenaltyInvoiceModel(
      referencedOffenceSerial:
          json['referenced_offence_serial']?.toString() ?? '',
      offenderName: json['offender_name']?.toString() ?? '',
      offenderPhone: json['offender_phone']?.toString() ?? '',
      offenceName: json['offence_name']?.toString() ?? '',
      offenceEnactment: json['offence_enactment']?.toString() ?? '',
      prn: json['prn']?.toString() ?? '',
      searchCode: json['search_code']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0.00',
      status: json['status']?.toString() ?? 'PENDING',
      created: json['created']?.toString() ?? '',
      expires: json['expires']?.toString() ?? '',
      documents: json['documents'] as Map<String, dynamic>?,
    );
  }
}
