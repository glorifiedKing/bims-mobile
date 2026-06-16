class ProAttachmentTypeModel {
  final int id;
  final String title;
  final String applicationType;

  ProAttachmentTypeModel({
    required this.id,
    required this.title,
    required this.applicationType,
  });

  factory ProAttachmentTypeModel.fromJson(Map<String, dynamic> json) {
    return ProAttachmentTypeModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      applicationType: json['application_type'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'application_type': applicationType,
    };
  }
}
