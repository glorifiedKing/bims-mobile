class AssessmentModel {
  final ApplicationAssessmentInfo application;
  final AssessmentDetails assessment;

  AssessmentModel({
    required this.application,
    required this.assessment,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      application: ApplicationAssessmentInfo.fromJson(json['application'] ?? {}),
      assessment: AssessmentDetails.fromJson(json['assessement'] ?? json['assessment'] ?? {}),
    );
  }
}

class ApplicationAssessmentInfo {
  final String applicationType;
  final String applicationKey;
  final String nameOfApplicant;
  final String buildingOperation;
  final String buildingPurpose;
  final String administrativeUnit;
  final String administrativeUnitType;
  final dynamic totalSQM;

  ApplicationAssessmentInfo({
    required this.applicationType,
    required this.applicationKey,
    required this.nameOfApplicant,
    required this.buildingOperation,
    required this.buildingPurpose,
    required this.administrativeUnit,
    required this.administrativeUnitType,
    required this.totalSQM,
  });

  factory ApplicationAssessmentInfo.fromJson(Map<String, dynamic> json) {
    return ApplicationAssessmentInfo(
      applicationType: json['applicationType']?.toString() ?? '',
      applicationKey: json['application_key']?.toString() ?? '',
      nameOfApplicant: json['nameOfApplicant']?.toString() ?? '',
      buildingOperation: json['buildingOperation']?.toString() ?? '',
      buildingPurpose: json['buildingPurpose']?.toString() ?? '',
      administrativeUnit: (json['administrativie_unit'] ?? json['administrative_unit'])?.toString() ?? '',
      administrativeUnitType: json['administrative_unit_type']?.toString() ?? '',
      totalSQM: json['totalSQM'],
    );
  }
}

class AssessmentDetails {
  final String assessmentType;
  final String rateScrutinyPerSQM;
  final String rateInspectionPerSQM;
  final dynamic scrutinyFees;
  final dynamic inspectionFees;
  final dynamic totalDue;

  AssessmentDetails({
    required this.assessmentType,
    required this.rateScrutinyPerSQM,
    required this.rateInspectionPerSQM,
    required this.scrutinyFees,
    required this.inspectionFees,
    required this.totalDue,
  });

  factory AssessmentDetails.fromJson(Map<String, dynamic> json) {
    return AssessmentDetails(
      assessmentType: (json['assessementType'] ?? json['assessmentType'])?.toString() ?? '',
      rateScrutinyPerSQM: json['rateScrutinyPerSQM']?.toString() ?? '',
      rateInspectionPerSQM: json['rateInspectionPerSQM']?.toString() ?? '',
      scrutinyFees: json['scrutinyFees'],
      inspectionFees: json['inspectionFees'],
      totalDue: json['totalDue'],
    );
  }
}
