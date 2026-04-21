class ProApplicationDetailsModel {
  final String applicantKey;
  final String code;
  final String? developerName;
  final String status;
  final String? confirmationDate;
  final String? createdOn;
  final String? updateOn;

  ProApplicationDetailsModel({
    required this.applicantKey,
    required this.code,
    this.developerName,
    required this.status,
    this.confirmationDate,
    this.createdOn,
    this.updateOn,
  });

  factory ProApplicationDetailsModel.fromJson(Map<String, dynamic> json) {
    return ProApplicationDetailsModel(
      applicantKey: json['applicant_key']?.toString() ?? '',
      code: json['code']?.toString() ?? 'Unknown',
      developerName: json['developer_name']?.toString(),
      status: json['status']?.toString() ?? 'Unknown',
      confirmationDate: json['confirmation_date']?.toString() ?? json['comfirmation_date']?.toString(),
      createdOn: json['created_on']?.toString(),
      updateOn: json['update_on']?.toString(),
    );
  }
}
