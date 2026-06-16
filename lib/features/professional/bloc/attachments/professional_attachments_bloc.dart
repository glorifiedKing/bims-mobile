import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/professional_repository.dart';
import 'professional_attachments_event.dart';
import 'professional_attachments_state.dart';

class ProfessionalAttachmentsBloc extends Bloc<ProfessionalAttachmentsEvent, ProfessionalAttachmentsState> {
  final ProfessionalRepository repository;

  ProfessionalAttachmentsBloc({required this.repository}) : super(ProfessionalAttachmentsInitial()) {
    on<FetchProfessionalAttachments>(_onFetch);
    on<LoadMoreProfessionalAttachments>(_onLoadMore);
    on<FetchProfessionalAttachmentTypes>(_onFetchTypes);
    on<UploadProfessionalAttachment>(_onUpload);
    on<EditProfessionalAttachment>(_onEdit);
  }

  Future<void> _onFetch(FetchProfessionalAttachments event, Emitter<ProfessionalAttachmentsState> emit) async {
    emit(ProfessionalAttachmentsLoading());
    try {
      final response = await repository.getAttachments(
        page: 1,
        status: event.status,
        type: event.type,
      );
      emit(ProfessionalAttachmentsLoaded(
        attachments: response['attachments'],
        hasReachedMax: response['hasReachedMax'],
        currentPage: 1,
        currentStatus: event.status,
        currentType: event.type,
      ));
    } catch (e) {
      emit(ProfessionalAttachmentsError(e.toString()));
    }
  }

  Future<void> _onLoadMore(LoadMoreProfessionalAttachments event, Emitter<ProfessionalAttachmentsState> emit) async {
    final currentState = state;
    if (currentState is ProfessionalAttachmentsLoaded && !currentState.hasReachedMax) {
      try {
        final nextPage = currentState.currentPage + 1;
        final response = await repository.getAttachments(
          page: nextPage,
          status: currentState.currentStatus,
          type: currentState.currentType,
        );
        emit(currentState.copyWith(
          attachments: List.of(currentState.attachments)..addAll(response['attachments']),
          hasReachedMax: response['hasReachedMax'],
          currentPage: nextPage,
        ));
      } catch (e) {
        emit(ProfessionalAttachmentsError(e.toString()));
      }
    }
  }

  Future<void> _onFetchTypes(FetchProfessionalAttachmentTypes event, Emitter<ProfessionalAttachmentsState> emit) async {
    emit(AttachmentTypesLoading());
    try {
      final types = await repository.getAttachmentTypes();
      emit(AttachmentTypesLoaded(types));
    } catch (e) {
      emit(AttachmentTypesError(e.toString()));
    }
  }

  Future<void> _onUpload(UploadProfessionalAttachment event, Emitter<ProfessionalAttachmentsState> emit) async {
    emit(AttachmentSubmissionLoading());
    try {
      await repository.uploadAttachment(
        attachmentType: event.attachmentType,
        reference: event.reference,
        particulars: event.particulars,
        clientDetails: event.clientDetails,
        documentPath: event.documentPath,
        documentBytes: event.documentBytes,
        fileName: event.fileName,
      );
      emit(AttachmentSubmissionSuccess('Attachment uploaded successfully.'));
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      emit(AttachmentSubmissionError(errorMsg));
    }
  }

  Future<void> _onEdit(EditProfessionalAttachment event, Emitter<ProfessionalAttachmentsState> emit) async {
    emit(AttachmentSubmissionLoading());
    try {
      await repository.editAttachment(
        id: event.id,
        attachmentType: event.attachmentType,
        reference: event.reference,
        particulars: event.particulars,
        clientDetails: event.clientDetails,
        documentPath: event.documentPath,
        documentBytes: event.documentBytes,
        fileName: event.fileName,
      );
      emit(AttachmentSubmissionSuccess('Attachment updated successfully.'));
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      emit(AttachmentSubmissionError(errorMsg));
    }
  }
}
