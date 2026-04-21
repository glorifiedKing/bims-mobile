class ProfessionalProfile {
  final String name;
  final String email;
  final String phone;
  final String registrationNo;
  final String profession;
  final String discipline;
  final String createdOn;
  final String updatedOn;

  ProfessionalProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.registrationNo,
    required this.profession,
    required this.discipline,
    required this.createdOn,
    required this.updatedOn,
  });

  factory ProfessionalProfile.fromJson(Map<String, dynamic> json) {
    return ProfessionalProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      registrationNo: json['registration_no'] ?? '',
      profession: json['profession'] ?? '',
      discipline: json['discipline'] ?? '',
      createdOn: json['created_on'] ?? '',
      updatedOn: json['updated_on'] ?? '',
    );
  }
}
