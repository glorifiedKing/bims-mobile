class AuditTrailModel {
  final String date;
  final String comment;

  AuditTrailModel({
    required this.date,
    required this.comment,
  });

  factory AuditTrailModel.fromJson(Map<String, dynamic> json) {
    return AuditTrailModel(
      date: json['date']?.toString() ?? '',
      comment: json['comment']?.toString() ?? '',
    );
  }
}
