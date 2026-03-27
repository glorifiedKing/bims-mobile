class PermitDetailModel {
  final String permitNumber;
  final String permitSerial;
  final String permitType;
  final PermitBuilding building;
  final PermitAdministrativeUnit administrativeUnit;
  final PermitApplicant applicant;
  final PermitProfessionals professionalsEngaged;
  final String approvalFeesPaid;
  final String permitIssueDate;
  final String permitExpiryDate;
  final String link;

  PermitDetailModel({
    required this.permitNumber,
    required this.permitSerial,
    required this.permitType,
    required this.building,
    required this.administrativeUnit,
    required this.applicant,
    required this.professionalsEngaged,
    required this.approvalFeesPaid,
    required this.permitIssueDate,
    required this.permitExpiryDate,
    required this.link,
  });

  factory PermitDetailModel.fromJson(Map<String, dynamic> json) {
    return PermitDetailModel(
      permitNumber: json['permit_number'] ?? '',
      permitSerial: json['permit_serial'] ?? '',
      permitType: json['permit_type'] ?? '',
      building: PermitBuilding.fromJson(json['building'] ?? {}),
      administrativeUnit: PermitAdministrativeUnit.fromJson(
        json['administrative_unit'] ?? {},
      ),
      applicant: PermitApplicant.fromJson(json['applicant'] ?? {}),
      professionalsEngaged: PermitProfessionals.fromJson(
        json['professionals_engaged'] ?? {},
      ),
      approvalFeesPaid: json['approval_fees_paid'] ?? '',
      permitIssueDate: json['permit_issue_date'] ?? '',
      permitExpiryDate: json['permit_expiry_date'] ?? '',
      link: json['link'] ?? '',
    );
  }
}

class PermitBuilding {
  final String operation;
  final String classification;
  final String purpose;
  final String location;
  final String plotNo;
  final String blockNo;
  final String street;
  final int builtUpArea;

  PermitBuilding({
    required this.operation,
    required this.classification,
    required this.purpose,
    required this.location,
    required this.plotNo,
    required this.blockNo,
    required this.street,
    required this.builtUpArea,
  });

  factory PermitBuilding.fromJson(Map<String, dynamic> json) {
    return PermitBuilding(
      operation: json['operation'] ?? '',
      classification: json['classification'] ?? '',
      purpose: json['purpose'] ?? '',
      location: json['location'] ?? '',
      plotNo: json['plot_no'] ?? '',
      blockNo: json['block_no'] ?? '',
      street: json['street'] ?? '',
      builtUpArea: json['built_up_area'] ?? 0,
    );
  }
}

class PermitAdministrativeUnit {
  final String type;
  final String name;

  PermitAdministrativeUnit({required this.type, required this.name});

  factory PermitAdministrativeUnit.fromJson(Map<String, dynamic> json) {
    return PermitAdministrativeUnit(
      type: json['type'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class PermitApplicant {
  final String name;
  final String phone;
  final String email;
  final String tin;
  final String nin;
  final String type;

  PermitApplicant({
    required this.name,
    required this.phone,
    required this.email,
    required this.tin,
    required this.nin,
    required this.type,
  });

  factory PermitApplicant.fromJson(Map<String, dynamic> json) {
    return PermitApplicant(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      tin: json['tin'] ?? '',
      nin: json['nin'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

class PermitProfessionals {
  final PermitProfessional? architect;
  final PermitProfessional? structuralEngineer;
  final PermitProfessional? quantitySurveyor;
  final PermitProfessional? mechanicalEngineer;
  final PermitProfessional? electricalEngineer;

  PermitProfessionals({
    this.architect,
    this.structuralEngineer,
    this.quantitySurveyor,
    this.mechanicalEngineer,
    this.electricalEngineer,
  });

  factory PermitProfessionals.fromJson(Map<String, dynamic> json) {
    return PermitProfessionals(
      architect: _parseProfessional(json['architect']),
      structuralEngineer: _parseProfessional(json['structural_engineer']),
      quantitySurveyor: _parseProfessional(json['quantity_surveyor']),
      mechanicalEngineer: _parseProfessional(
        json['services_engineer_mechanical'],
      ),
      electricalEngineer: _parseProfessional(
        json['services_engineer_electrical'],
      ),
    );
  }

  static PermitProfessional? _parseProfessional(dynamic data) {
    if (data == null || data is List) return null; // API returns [] if empty
    if (data is Map<String, dynamic>) {
      return PermitProfessional.fromJson(data);
    }
    return null;
  }
}

class PermitProfessional {
  final String regNo;
  final String name;
  final String address;
  final String discipline;

  PermitProfessional({
    required this.regNo,
    required this.name,
    required this.address,
    required this.discipline,
  });

  factory PermitProfessional.fromJson(Map<String, dynamic> json) {
    return PermitProfessional(
      regNo: json['reg_no'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      discipline: json['discipline'] ?? '',
    );
  }
}
