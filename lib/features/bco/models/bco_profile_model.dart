class BcoProfileModel {
  final String names;
  final String email;
  final String? phone;
  final String role;
  final String administrativeUnitType;
  final String administrativeUnitName;
  final String createdOn;
  final String updatedOn;

  BcoProfileModel({
    required this.names,
    required this.email,
    this.phone,
    required this.role,
    required this.administrativeUnitType,
    required this.administrativeUnitName,
    required this.createdOn,
    required this.updatedOn,
  });

  factory BcoProfileModel.fromJson(Map<String, dynamic> json) {
    return BcoProfileModel(
      names: json['names'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? '',
      administrativeUnitType: json['administrative_unit_type'] ?? '',
      administrativeUnitName: json['administrative_unit_name'] ?? '',
      createdOn: json['created_on'] ?? '',
      updatedOn: json['updated_on'] ?? '',
    );
  }
}
