class ApplicationDetailModel {
  final String applicationKey;
  final String applicationType;
  final String buildingClassification;
  final String buildingOperation;
  final String buildingPurpose;
  final String administrativeUnitType;
  final String administrativeUnitName;
  final double totalSquareMetres;
  final String created;
  final String updated;
  final String? expires;
  final String? status;
  final Applicant applicant;
  final ProfessionalsEngaged professionalsEngaged;
  final List<dynamic>
  auditTrail; // Adjust type if audit trail structure is known later

  ApplicationDetailModel({
    required this.applicationKey,
    required this.applicationType,
    required this.buildingClassification,
    required this.buildingOperation,
    required this.buildingPurpose,
    required this.administrativeUnitType,
    required this.administrativeUnitName,
    required this.totalSquareMetres,
    required this.created,
    required this.updated,
    this.expires,
    this.status,
    required this.applicant,
    required this.professionalsEngaged,
    required this.auditTrail,
  });

  factory ApplicationDetailModel.fromJson(Map<String, dynamic> json) {
    return ApplicationDetailModel(
      applicationKey: json['application_key'] ?? '',
      applicationType: json['application_type'] ?? '',
      buildingClassification: json['building_classification'] ?? '',
      buildingOperation: json['building_operation'] ?? '',
      buildingPurpose: json['building_purpose'] ?? '',
      administrativeUnitType: json['administrative_unit_type'] ?? '',
      administrativeUnitName: json['administrative_unit_name'] ?? '',
      totalSquareMetres: (json['total_square_metres'] ?? 0).toDouble(),
      created: json['created'] ?? '',
      updated: json['updated'] ?? '',
      expires: json['expires'],
      status: json['status'],
      applicant: Applicant.fromJson(json['applicant'] ?? {}),
      professionalsEngaged: ProfessionalsEngaged.fromJson(
        json['professionals_engaged'] ?? {},
      ),
      auditTrail: json['audit_trail'] ?? [],
    );
  }
}

class Applicant {
  final String name;
  final String phone;
  final String email;
  final String tin;
  final String nin;

  Applicant({
    required this.name,
    required this.phone,
    required this.email,
    required this.tin,
    required this.nin,
  });

  factory Applicant.fromJson(Map<String, dynamic> json) {
    return Applicant(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      tin: json['tin'] ?? '',
      nin: json['nin'] ?? '',
    );
  }
}

class ProfessionalsEngaged {
  final Professional? architect;
  final List<dynamic>? structuralEngineer; // Can be object or array
  final Professional? quantitySurveyor;
  final List<dynamic>? servicesEngineerMechanical;
  final List<dynamic>? servicesEngineerElectrical;

  ProfessionalsEngaged({
    this.architect,
    this.structuralEngineer,
    this.quantitySurveyor,
    this.servicesEngineerMechanical,
    this.servicesEngineerElectrical,
  });

  factory ProfessionalsEngaged.fromJson(Map<String, dynamic> json) {
    // Some endpoints return empty array [] instead of null or empty object when empty
    // So conditionally parse them. For our data model, let's try to extract common properties if it's a map.
    return ProfessionalsEngaged(
      architect: _parseProfessional(json['architect']),
      structuralEngineer: json['structural_engineer'] is List
          ? json['structural_engineer']
          : null,
      quantitySurveyor: _parseProfessional(json['quantity_surveyor']),
      servicesEngineerMechanical: json['services_engineer_mechanical'] is List
          ? json['services_engineer_mechanical']
          : null,
      servicesEngineerElectrical: json['services_engineer_electrical'] is List
          ? json['services_engineer_electrical']
          : null,
    );
  }

  static Professional? _parseProfessional(dynamic json) {
    if (json is Map<String, dynamic> && json.isNotEmpty) {
      return Professional.fromJson(json);
    }
    return null;
  }
}

class Professional {
  final String regNo;
  final String name;
  final String address;

  Professional({
    required this.regNo,
    required this.name,
    required this.address,
  });

  factory Professional.fromJson(Map<String, dynamic> json) {
    return Professional(
      regNo: json['reg_no']?.toString() ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
    );
  }
}
