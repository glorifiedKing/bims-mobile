import 'package:flutter_bloc/flutter_bloc.dart';
import 'bco_application_attachments_event.dart';
import 'bco_application_attachments_state.dart';
import '../../repositories/bco_repository.dart';

class BcoApplicationAttachmentsBloc extends Bloc<BcoApplicationAttachmentsEvent, BcoApplicationAttachmentsState> {
  final BcoRepository repository;
  
  BcoApplicationAttachmentsBloc({required this.repository}) : super(BcoApplicationAttachmentsInitial()) {
    on<FetchBcoApplicationAttachments>(_onFetchAttachments);
    on<LoadMoreBcoApplicationAttachments>(_onLoadMoreAttachments);
  }

  Future<void> _onFetchAttachments(FetchBcoApplicationAttachments event, Emitter<BcoApplicationAttachmentsState> emit) async {
    emit(BcoApplicationAttachmentsLoading());
    try {
      final result = await repository.getApplicationAttachments(event.applicationKey, page: 1);
      emit(BcoApplicationAttachmentsLoaded(
        attachments: result['attachments'],
        hasReachedMax: result['hasReachedMax'],
        currentPage: 1,
      ));
    } catch (e) {
      emit(BcoApplicationAttachmentsError(e.toString()));
    }
  }

  Future<void> _onLoadMoreAttachments(LoadMoreBcoApplicationAttachments event, Emitter<BcoApplicationAttachmentsState> emit) async {
    if (state is BcoApplicationAttachmentsLoaded) {
      final currentState = state as BcoApplicationAttachmentsLoaded;
      if (currentState.hasReachedMax) return;

      try {
        final nextPage = currentState.currentPage + 1;
        final result = await repository.getApplicationAttachments(event.applicationKey, page: nextPage);
        final newAttachments = result['attachments'] as List;

        emit(currentState.copyWith(
          attachments: [...currentState.attachments, ...newAttachments],
          hasReachedMax: result['hasReachedMax'],
          currentPage: nextPage,
        ));
      } catch (e) {
        emit(BcoApplicationAttachmentsError(e.toString()));
      }
    }
  }
}
