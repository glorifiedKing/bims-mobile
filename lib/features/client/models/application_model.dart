class ApplicationModel {
  final String id; // trackingNo
  final String status;
  final String location;
  final String type;
  final String
  submittedDate; // This could be parsed to DateTime in the future if needed
  final String estCompletion;
  final double progress; // 0.0 to 1.0

  ApplicationModel({
    required this.id,
    required this.status,
    required this.location,
    required this.type,
    required this.submittedDate,
    required this.estCompletion,
    required this.progress,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id:
          json['application_key']?.toString() ??
          json['trackingNo']?.toString() ??
          json['id']?.toString() ??
          '',
      status: json['status'] ?? 'Unknown',
      location:
          json['location'] ??
          json['administrative_unit_name'] ??
          'Unknown Location',
      type: json['application_type'] ?? json['type'] ?? 'Application',
      submittedDate:
          json['created'] ?? json['created_on'] ?? json['submittedDate'] ?? '',
      estCompletion:
          json['updated'] ?? json['update_on'] ?? json['estCompletion'] ?? '',
      progress: _calculateProgress(json['status']?.toString() ?? ''),
    );
  }

  static double _calculateProgress(String status) {
    String s = status.toUpperCase();
    if (s == 'APPROVED' || s == 'COMPLETED') return 1.0;
    if (s == 'IN-REVIEW' || s == 'REVIEW') return 0.75;
    if (s == 'PENDING PAYMENT') return 0.5;
    if (s == 'INCOMPLETE' || s == 'DRAFT') return 0.25;
    return 0.1;
  }

  Map<String, dynamic> toJson() {
    return {
      'trackingNo': id,
      'status': status,
      'location': location,
      'type': type,
      'submittedDate': submittedDate,
      'estCompletion': estCompletion,
      'progress': progress,
    };
  }
}
