class BcoUser {
  final String fname;
  final String lname;
  final String otherNames;
  final String email;
  final int roleId;
  final int? speciality;
  final int? administrativeUnitType;
  final int? administrativeUnitId;

  BcoUser({
    required this.fname,
    required this.lname,
    required this.otherNames,
    required this.email,
    required this.roleId,
    this.speciality,
    this.administrativeUnitType,
    this.administrativeUnitId,
  });

  factory BcoUser.fromJson(Map<String, dynamic> json) {
    return BcoUser(
      fname: json['fname'] ?? '',
      lname: json['lname'] ?? '',
      otherNames: json['otherNames'] ?? '',
      email: json['email'] ?? '',
      roleId: json['role_id'] ?? 0,
      speciality: json['speciality'],
      administrativeUnitType: json['administrative_unit_type'],
      administrativeUnitId: json['administrative_unit_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fname': fname,
      'lname': lname,
      'otherNames': otherNames,
      'email': email,
      'role_id': roleId,
      'speciality': speciality,
      'administrative_unit_type': administrativeUnitType,
      'administrative_unit_id': administrativeUnitId,
    };
  }
}
