import '../../models/bco_application_attachment_model.dart';

abstract class BcoApplicationAttachmentsState {}

class BcoApplicationAttachmentsInitial extends BcoApplicationAttachmentsState {}

class BcoApplicationAttachmentsLoading extends BcoApplicationAttachmentsState {}

class BcoApplicationAttachmentsLoaded extends BcoApplicationAttachmentsState {
  final List<BcoApplicationAttachmentModel> attachments;
  final bool hasReachedMax;
  final int currentPage;

  BcoApplicationAttachmentsLoaded({
    required this.attachments,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  BcoApplicationAttachmentsLoaded copyWith({
    List<BcoApplicationAttachmentModel>? attachments,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return BcoApplicationAttachmentsLoaded(
      attachments: attachments ?? this.attachments,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class BcoApplicationAttachmentsError extends BcoApplicationAttachmentsState {
  final String message;
  BcoApplicationAttachmentsError(this.message);
}
