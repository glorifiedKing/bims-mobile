class BcoWhistleblowModel {
  final String reference;
  final String feedbackType;
  final String name;
  final String email;
  final String phone;
  final String administrativeUnitType;
  final String administrativeUnitName;
  final String location;
  final String description;
  final String createdAt;

  BcoWhistleblowModel({
    required this.reference,
    required this.feedbackType,
    required this.name,
    required this.email,
    required this.phone,
    required this.administrativeUnitType,
    required this.administrativeUnitName,
    required this.location,
    required this.description,
    required this.createdAt,
  });

  factory BcoWhistleblowModel.fromJson(Map<String, dynamic> json) {
    return BcoWhistleblowModel(
      reference: json['reference']?.toString() ?? '',
      feedbackType: json['feedback_type']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      administrativeUnitType: json['administrative_unit_type']?.toString() ?? '',
      administrativeUnitName: json['administrative_unit_name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
