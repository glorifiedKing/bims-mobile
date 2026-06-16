import '../../models/pro_attachment_model.dart';
import '../../models/pro_attachment_type_model.dart';

abstract class ProfessionalAttachmentsState {}

class ProfessionalAttachmentsInitial extends ProfessionalAttachmentsState {}

class ProfessionalAttachmentsLoading extends ProfessionalAttachmentsState {}

class ProfessionalAttachmentsLoaded extends ProfessionalAttachmentsState {
  final List<ProAttachmentModel> attachments;
  final bool hasReachedMax;
  final int currentPage;
  final String? currentStatus;
  final String? currentType;

  ProfessionalAttachmentsLoaded({
    required this.attachments,
    required this.hasReachedMax,
    required this.currentPage,
    this.currentStatus,
    this.currentType,
  });

  ProfessionalAttachmentsLoaded copyWith({
    List<ProAttachmentModel>? attachments,
    bool? hasReachedMax,
    int? currentPage,
    String? currentStatus,
    String? currentType,
  }) {
    return ProfessionalAttachmentsLoaded(
      attachments: attachments ?? this.attachments,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      currentStatus: currentStatus ?? this.currentStatus,
      currentType: currentType ?? this.currentType,
    );
  }
}

class ProfessionalAttachmentsError extends ProfessionalAttachmentsState {
  final String message;

  ProfessionalAttachmentsError(this.message);
}

// States for Attachment Types
class AttachmentTypesLoading extends ProfessionalAttachmentsState {}

class AttachmentTypesLoaded extends ProfessionalAttachmentsState {
  final List<ProAttachmentTypeModel> types;

  AttachmentTypesLoaded(this.types);
}

class AttachmentTypesError extends ProfessionalAttachmentsState {
  final String message;

  AttachmentTypesError(this.message);
}

// States for Uploading/Editing
class AttachmentSubmissionLoading extends ProfessionalAttachmentsState {}

class AttachmentSubmissionSuccess extends ProfessionalAttachmentsState {
  final String message;

  AttachmentSubmissionSuccess(this.message);
}

class AttachmentSubmissionError extends ProfessionalAttachmentsState {
  final String message;

  AttachmentSubmissionError(this.message);
}
