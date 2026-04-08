class BcoApplicationAttachmentModel {
  final String name;
  final String created;
  final String fileUrl;

  const BcoApplicationAttachmentModel({
    required this.name,
    required this.created,
    required this.fileUrl,
  });

  factory BcoApplicationAttachmentModel.fromJson(Map<String, dynamic> json) {
    return BcoApplicationAttachmentModel(
      name: json['name'] ?? '',
      created: json['created'] ?? '',
      fileUrl: json['document']?['file'] ?? '',
    );
  }
}
