import 'dart:typed_data';

abstract class ProfessionalAttachmentsEvent {}

class FetchProfessionalAttachments extends ProfessionalAttachmentsEvent {
  final String? status;
  final String? type;

  FetchProfessionalAttachments({this.status, this.type});
}

class LoadMoreProfessionalAttachments extends ProfessionalAttachmentsEvent {}

class FetchProfessionalAttachmentTypes extends ProfessionalAttachmentsEvent {}

class UploadProfessionalAttachment extends ProfessionalAttachmentsEvent {
  final int attachmentType;
  final String reference;
  final String particulars;
  final String clientDetails;
  final String? documentPath;
  final Uint8List? documentBytes;
  final String? fileName;

  UploadProfessionalAttachment({
    required this.attachmentType,
    required this.reference,
    required this.particulars,
    required this.clientDetails,
    this.documentPath,
    this.documentBytes,
    this.fileName,
  });
}

class EditProfessionalAttachment extends ProfessionalAttachmentsEvent {
  final int id;
  final int attachmentType;
  final String reference;
  final String particulars;
  final String clientDetails;
  final String? documentPath;
  final Uint8List? documentBytes;
  final String? fileName;

  EditProfessionalAttachment({
    required this.id,
    required this.attachmentType,
    required this.reference,
    required this.particulars,
    required this.clientDetails,
    this.documentPath,
    this.documentBytes,
    this.fileName,
  });
}
