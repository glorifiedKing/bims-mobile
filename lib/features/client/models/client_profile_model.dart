class ClientProfileModel {
  final String names;
  final String email;
  final String tinNumber;
  final String ninNumber;
  final String sex;
  final String phone;
  final String accountType;
  final String createdOn;

  ClientProfileModel({
    required this.names,
    required this.email,
    required this.tinNumber,
    required this.ninNumber,
    required this.sex,
    required this.phone,
    required this.accountType,
    required this.createdOn,
  });

  factory ClientProfileModel.fromJson(Map<String, dynamic> json) {
    return ClientProfileModel(
      names: json['names'] ?? json['name'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      tinNumber: json['tin_number'] ?? json['tinNumber'] ?? '',
      ninNumber: json['nin_number'] ?? json['ninNumber'] ?? 'N/A',
      sex: json['sex'] ?? 'Unknown',
      phone: json['phone'] ?? json['phoneNumber'] ?? 'N/A',
      accountType: json['account_type'] ?? json['accountType'] ?? 'Unknown',
      createdOn: json['created_on'] ?? json['createdOn'] ?? '',
    );
  }
}
