class ExpressPenaltyModel {
  final String reference;
  final String offenceEnactment;
  final String offenceName;
  final String offenderName;
  final String offenderSex;
  final int offenderAge;
  final String offenderPhone;
  final String location;
  final String buildingClass;
  final String administrativeUnitType;
  final String administrativeUnitName;
  final String postalAddress;
  final String buildingPermitNumber;
  final String occupationPermitNumber;
  final String squareMetres;
  final String amount;
  final String status;
  final String dateOfOffence;
  final String issuedBy;
  final String createdAt;
  final String updatedAt;
  final PenaltyInvoiceModel? invoice;

  ExpressPenaltyModel({
    required this.reference,
    required this.offenceEnactment,
    required this.offenceName,
    required this.offenderName,
    required this.offenderSex,
    required this.offenderAge,
    required this.offenderPhone,
    required this.location,
    required this.buildingClass,
    required this.administrativeUnitType,
    required this.administrativeUnitName,
    required this.postalAddress,
    required this.buildingPermitNumber,
    required this.occupationPermitNumber,
    required this.squareMetres,
    required this.amount,
    required this.status,
    required this.dateOfOffence,
    required this.issuedBy,
    required this.createdAt,
    required this.updatedAt,
    this.invoice,
  });

  factory ExpressPenaltyModel.fromJson(Map<String, dynamic> json) {
    return ExpressPenaltyModel(
      reference: json['reference']?.toString() ?? '',
      offenceEnactment: json['offence_enactment']?.toString() ?? '',
      offenceName: json['offence_name']?.toString() ?? '',
      offenderName: json['offender_name']?.toString() ?? '',
      offenderSex: json['offender_sex']?.toString() ?? '',
      offenderAge: json['offender_age'] != null ? int.tryParse(json['offender_age'].toString()) ?? 0 : 0,
      offenderPhone: json['offender_phone']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      buildingClass: json['building_class']?.toString() ?? '',
      administrativeUnitType: json['administrative_unit_type']?.toString() ?? '',
      administrativeUnitName: json['administrative_unit_name']?.toString() ?? '',
      postalAddress: json['postal_address']?.toString() ?? '',
      buildingPermitNumber: json['building_permit_number']?.toString() ?? '',
      occupationPermitNumber: json['occupation_permit_number']?.toString() ?? '',
      squareMetres: json['square_metres']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      dateOfOffence: json['date_of_offence']?.toString() ?? '',
      issuedBy: json['issued_by']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      invoice: json['invoice'] != null
          ? PenaltyInvoiceModel.fromJson(json['invoice'])
          : null,
    );
  }
}

class PenaltyInvoiceModel {
  final String file;
  final String prn;
  final String searchCode;
  final String expiryDate;

  PenaltyInvoiceModel({
    required this.file,
    required this.prn,
    required this.searchCode,
    required this.expiryDate,
  });

  factory PenaltyInvoiceModel.fromJson(Map<String, dynamic> json) {
    return PenaltyInvoiceModel(
      file: json['file']?.toString() ?? '',
      prn: json['prn']?.toString() ?? '',
      searchCode: json['search_code']?.toString() ?? '',
      expiryDate: json['expiry_date']?.toString() ?? '',
    );
  }
}
