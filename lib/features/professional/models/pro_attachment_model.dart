class ProAttachmentModel {
  final int id;
  final String code;
  final String particulars;
  final String? applicationRef;
  final String attachmentType;
  final String attachmentFile;
  final String status;
  final String createdAt;
  final String updatedAt;

  ProAttachmentModel({
    required this.id,
    required this.code,
    required this.particulars,
    this.applicationRef,
    required this.attachmentType,
    required this.attachmentFile,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProAttachmentModel.fromJson(Map<String, dynamic> json) {
    return ProAttachmentModel(
      id: json['id'] as int,
      code: json['code'] as String? ?? '',
      particulars: json['particulars'] as String? ?? '',
      applicationRef: json['application_ref'] as String?,
      attachmentType: json['attachment_type'] as String? ?? '',
      attachmentFile: json['attachment_file'] as String? ?? '',
      status: json['status'] as String? ?? 'UNLINKED',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'particulars': particulars,
      'application_ref': applicationRef,
      'attachment_type': attachmentType,
      'attachment_file': attachmentFile,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
