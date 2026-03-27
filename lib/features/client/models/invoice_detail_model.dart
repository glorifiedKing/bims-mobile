class InvoiceDetailModel {
  final String prn;
  final String searchCode;
  final String declarationType;
  final String assessmentAmount;
  final String inspectionFees;
  final String landscapingFees;
  final bool paid;
  final String created;
  final String expires;
  final String datePaid;
  final InvoiceApplication application;
  final InvoiceBuilding building;
  final InvoiceAdministrativeUnit administrativeUnit;
  final InvoiceApplicant applicant;

  InvoiceDetailModel({
    required this.prn,
    required this.searchCode,
    required this.declarationType,
    required this.assessmentAmount,
    required this.inspectionFees,
    required this.landscapingFees,
    required this.paid,
    required this.created,
    required this.expires,
    required this.datePaid,
    required this.application,
    required this.building,
    required this.administrativeUnit,
    required this.applicant,
  });

  factory InvoiceDetailModel.fromJson(Map<String, dynamic> json) {
    return InvoiceDetailModel(
      prn: json['prn'] ?? '',
      searchCode: json['search_code'] ?? '',
      declarationType: json['declaration_type'] ?? '',
      assessmentAmount: json['assessment_amount'] ?? '0.00',
      inspectionFees: json['inspection_fees'] ?? '0.00',
      landscapingFees: json['landscaping_fees'] ?? '0.00',
      paid: json['paid'] ?? false,
      created: json['created'] ?? '',
      expires: json['expires'] ?? '',
      datePaid: json['date_paid'] ?? '',
      application: InvoiceApplication.fromJson(json['application'] ?? {}),
      building: InvoiceBuilding.fromJson(json['building'] ?? {}),
      administrativeUnit: InvoiceAdministrativeUnit.fromJson(
        json['administrative_unit'] ?? {},
      ),
      applicant: InvoiceApplicant.fromJson(json['applicant'] ?? {}),
    );
  }
}

class InvoiceApplication {
  final String applicationKey;
  final String applicationType;

  InvoiceApplication({
    required this.applicationKey,
    required this.applicationType,
  });

  factory InvoiceApplication.fromJson(Map<String, dynamic> json) {
    return InvoiceApplication(
      applicationKey: json['application_key'] ?? '',
      applicationType: json['application_type'] ?? '',
    );
  }
}

class InvoiceBuilding {
  final String operation;
  final String classification;
  final String purpose;
  final String location;
  final int builtUpArea;

  InvoiceBuilding({
    required this.operation,
    required this.classification,
    required this.purpose,
    required this.location,
    required this.builtUpArea,
  });

  factory InvoiceBuilding.fromJson(Map<String, dynamic> json) {
    return InvoiceBuilding(
      operation: json['operation'] ?? '',
      classification: json['classification'] ?? '',
      purpose: json['purpose'] ?? '',
      location: json['location'] ?? '',
      builtUpArea: json['built_up_area'] ?? 0,
    );
  }
}

class InvoiceAdministrativeUnit {
  final String type;
  final String name;

  InvoiceAdministrativeUnit({required this.type, required this.name});

  factory InvoiceAdministrativeUnit.fromJson(Map<String, dynamic> json) {
    return InvoiceAdministrativeUnit(
      type: json['type'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class InvoiceApplicant {
  final String name;
  final String phone;
  final String email;
  final String nin;
  final String type;

  InvoiceApplicant({
    required this.name,
    required this.phone,
    required this.email,
    required this.nin,
    required this.type,
  });

  factory InvoiceApplicant.fromJson(Map<String, dynamic> json) {
    return InvoiceApplicant(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      nin: json['nin'] ?? '',
      type: json['type'] ?? '',
    );
  }
}
