class BcoInspectionModel {
  final String applicationKey;
  final String inspectionRef;
  final String applicantName;
  final String applicantEmail;
  final String applicantPhone;
  final String location;
  final DateTime start;
  final DateTime end;
  final String inspectionType;
  final String preInspectionNotes;
  final String inspectionStatus;
  final DateTime createdAt;

  BcoInspectionModel({
    required this.applicationKey,
    required this.inspectionRef,
    required this.applicantName,
    required this.applicantEmail,
    required this.applicantPhone,
    required this.location,
    required this.start,
    required this.end,
    required this.inspectionType,
    required this.preInspectionNotes,
    required this.inspectionStatus,
    required this.createdAt,
  });

  factory BcoInspectionModel.fromJson(Map<String, dynamic> json) {
    return BcoInspectionModel(
      applicationKey: json['application_key']?.toString() ?? '',
      inspectionRef: json['inspection_ref']?.toString() ?? '',
      applicantName: json['applicant_name']?.toString() ?? '',
      applicantEmail: json['applicant_email']?.toString() ?? '',
      applicantPhone: json['applicant_phone']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      start: _parseDateTime(json['start']),
      end: _parseDateTime(json['end']),
      inspectionType: json['inspection_type']?.toString() ?? '',
      preInspectionNotes: json['pre_inspection_notes']?.toString() ?? '',
      inspectionStatus: json['inspection_status']?.toString() ?? '',
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  bool get isPending => inspectionStatus.toUpperCase() == 'PENDING';
  bool get isCompleted => inspectionStatus.toUpperCase() == 'COMPLETED';
  bool get isRescheduled => inspectionStatus.toUpperCase() == 'RE-SCHEDULED';
}
