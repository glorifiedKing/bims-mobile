class ProApplicationModel {
  final String? applicantKey;
  final String code;
  final String? developerName;
  final String status;
  final String? createdOn;
  final String? updateOn;

  ProApplicationModel({
    this.applicantKey,
    required this.code,
    this.developerName,
    required this.status,
    this.createdOn,
    this.updateOn,
  });

  factory ProApplicationModel.fromJson(Map<String, dynamic> json) {
    return ProApplicationModel(
      applicantKey: json['applicant_key']?.toString(),
      code: json['code']?.toString() ?? 'Unknown',
      developerName: json['developer_name']?.toString(),
      status: json['status']?.toString() ?? 'Unknown',
      createdOn: json['created_on']?.toString(),
      updateOn: json['update_on']?.toString(),
    );
  }
}
