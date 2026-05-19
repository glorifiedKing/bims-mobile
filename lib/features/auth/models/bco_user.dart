class BcoUser {
  final String names;
  final String email;
  final String? phone;
  final String role;
  final int roleId;
  final int administrativeUnitTypeId;
  final int administrativeUnitId;
  final int administrativeDivisionId;
  final String administrativeUnitType;
  final String administrativeUnitName;
  final String createdOn;
  final String updatedOn;

  BcoUser({
    required this.names,
    required this.email,
    this.phone,
    required this.role,
    required this.roleId,
    required this.administrativeUnitTypeId,
    required this.administrativeUnitId,
    required this.administrativeDivisionId,
    required this.administrativeUnitType,
    required this.administrativeUnitName,
    required this.createdOn,
    required this.updatedOn,
  });

  factory BcoUser.fromJson(Map<String, dynamic> json) {
    return BcoUser(
      names: json['names'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? '',
      roleId: json['role_id'] ?? 0,
      administrativeUnitTypeId: json['administrative_unit_type_id'] ?? 0,
      administrativeUnitId: json['administrative_unit_id'] ?? 0,
      administrativeDivisionId: json['administrative_division_id'] ?? 0,
      administrativeUnitType: json['administrative_unit_type'] ?? '',
      administrativeUnitName: json['administrative_unit_name'] ?? '',
      createdOn: json['created_on'] ?? '',
      updatedOn: json['updated_on'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'names': names,
      'email': email,
      'phone': phone,
      'role': role,
      'role_id': roleId,
      'administrative_unit_type_id': administrativeUnitTypeId,
      'administrative_unit_id': administrativeUnitId,
      'administrative_division_id': administrativeDivisionId,
      'administrative_unit_type': administrativeUnitType,
      'administrative_unit_name': administrativeUnitName,
      'created_on': createdOn,
      'updated_on': updatedOn,
    };
  }
}
