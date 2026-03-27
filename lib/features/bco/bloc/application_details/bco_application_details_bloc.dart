import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/bco_repository.dart';
import 'bco_application_details_event.dart';
import 'bco_application_details_state.dart';

class BcoApplicationDetailsBloc extends Bloc<BcoApplicationDetailsEvent, BcoApplicationDetailsState> {
  final BcoRepository repository;

  BcoApplicationDetailsBloc({required this.repository}) : super(BcoApplicationDetailsInitial()) {
    on<FetchBcoApplicationDetails>(_onFetchDetails);
    on<LoadMoreBcoAuditTrail>(_onLoadMoreAuditTrail);
    on<ReviewBcoApplication>(_onReviewApplication);
  }

  Future<void> _onFetchDetails(FetchBcoApplicationDetails event, Emitter<BcoApplicationDetailsState> emit) async {
    emit(BcoApplicationDetailsLoading());
    try {
      final details = await repository.getApplicationDetails(event.applicationKey);
      final auditData = await repository.getAuditTrail(event.applicationKey, page: 1);
      
      emit(BcoApplicationDetailsLoaded(
        details: details,
        auditTrail: auditData['trails'],
        hasReachedMaxAudit: auditData['hasReachedMax'],
        currentAuditPage: 1,
      ));
    } catch (e) {
      emit(BcoApplicationDetailsError(e.toString()));
    }
  }

  Future<void> _onLoadMoreAuditTrail(LoadMoreBcoAuditTrail event, Emitter<BcoApplicationDetailsState> emit) async {
    final currentState = state;
    if (currentState is BcoApplicationDetailsLoaded && !currentState.hasReachedMaxAudit) {
      try {
        final nextPage = currentState.currentAuditPage + 1;
        final auditData = await repository.getAuditTrail(event.applicationKey, page: nextPage);
        emit(currentState.copyWith(
          auditTrail: List.of(currentState.auditTrail)..addAll(auditData['trails']),
          hasReachedMaxAudit: auditData['hasReachedMax'],
          currentAuditPage: nextPage,
        ));
      } catch (e) {
        // Optional: emit error state or silently ignore and keep current state
      }
    }
  }

  Future<void> _onReviewApplication(ReviewBcoApplication event, Emitter<BcoApplicationDetailsState> emit) async {
    final currentState = state;
    if (currentState is BcoApplicationDetailsLoaded) {
      emit(currentState.copyWith(isReviewing: true, reviewError: null));
      try {
        await repository.reviewApplication(event.applicationKey, event.status, event.comment);
        emit(currentState.copyWith(isReviewing: false, reviewSuccess: true));
      } catch (e) {
        emit(currentState.copyWith(isReviewing: false, reviewError: e.toString()));
      }
    }
  }
}
