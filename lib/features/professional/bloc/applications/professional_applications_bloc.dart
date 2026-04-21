import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/professional_repository.dart';
import 'professional_applications_event.dart';
import 'professional_applications_state.dart';

class ProfessionalApplicationsBloc extends Bloc<ProfessionalApplicationsEvent, ProfessionalApplicationsState> {
  final ProfessionalRepository repository;

  ProfessionalApplicationsBloc({required this.repository}) : super(ProfessionalApplicationsInitial()) {
    on<FetchProfessionalApplications>(_onFetch);
    on<LoadMoreProfessionalApplications>(_onLoadMore);
  }

  Future<void> _onFetch(FetchProfessionalApplications event, Emitter<ProfessionalApplicationsState> emit) async {
    emit(ProfessionalApplicationsLoading());
    try {
      final response = await repository.getApplications(page: 1, status: event.status);
      emit(ProfessionalApplicationsLoaded(
        applications: response['applications'],
        hasReachedMax: response['hasReachedMax'],
        currentPage: 1,
        currentFilter: event.status,
      ));
    } catch (e) {
      emit(ProfessionalApplicationsError(e.toString()));
    }
  }

  Future<void> _onLoadMore(LoadMoreProfessionalApplications event, Emitter<ProfessionalApplicationsState> emit) async {
    final currentState = state;
    if (currentState is ProfessionalApplicationsLoaded && !currentState.hasReachedMax) {
      try {
        final nextPage = currentState.currentPage + 1;
        final response = await repository.getApplications(
          page: nextPage,
          status: currentState.currentFilter,
        );
        emit(currentState.copyWith(
          applications: List.of(currentState.applications)..addAll(response['applications']),
          hasReachedMax: response['hasReachedMax'],
          currentPage: nextPage,
        ));
      } catch (e) {
        emit(ProfessionalApplicationsError(e.toString()));
      }
    }
  }
}
