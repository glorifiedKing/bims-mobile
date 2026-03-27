class PermitModel {
  final String permitNo;
  final String serialNo;
  final String type;
  final String buildingClassification;
  final String administrativeUnitType;
  final String administrativeUnitName;
  final String location;
  final String issuedDate;
  final String expiresDate;
  final Map<String, dynamic>? documents;

  PermitModel({
    required this.permitNo,
    required this.serialNo,
    required this.type,
    required this.buildingClassification,
    required this.administrativeUnitType,
    required this.administrativeUnitName,
    required this.location,
    required this.issuedDate,
    required this.expiresDate,
    this.documents,
  });

  factory PermitModel.fromJson(Map<String, dynamic> json) {
    return PermitModel(
      permitNo: json['permit_number'] ?? json['permitNo'] ?? '',
      serialNo: json['permit_serial'] ?? json['serialNo'] ?? '',
      type: json['permit_type'] ?? json['type'] ?? 'Permit',
      buildingClassification: json['building_classification'] ?? '',
      administrativeUnitType: json['administrative_unit_type'] ?? '',
      administrativeUnitName: json['administrative_unit_name'] ?? '',
      location: json['location'] ?? '',
      issuedDate: json['permit_issue_date'] ?? json['issuedDate'] ?? '',
      expiresDate:
          json['permit_expiry_date'] ??
          json['expiresDate'] ??
          '', // 'Permanent' for Occupation Permits
      documents: json['documents'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'permit_number': permitNo,
      'permit_serial': serialNo,
      'permit_type': type,
      'building_classification': buildingClassification,
      'administrative_unit_type': administrativeUnitType,
      'administrative_unit_name': administrativeUnitName,
      'location': location,
      'permit_issue_date': issuedDate,
      'permit_expiry_date': expiresDate,
      'documents': documents,
    };
  }
}
