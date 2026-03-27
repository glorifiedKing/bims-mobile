import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/bco_repository.dart';
import 'bco_applications_event.dart';
import 'bco_applications_state.dart';

class BcoApplicationsBloc extends Bloc<BcoApplicationsEvent, BcoApplicationsState> {
  final BcoRepository repository;

  BcoApplicationsBloc({required this.repository}) : super(BcoApplicationsInitial()) {
    on<FetchBcoApplications>(_onFetch);
    on<LoadMoreBcoApplications>(_onLoadMore);
  }

  Future<void> _onFetch(FetchBcoApplications event, Emitter<BcoApplicationsState> emit) async {
    emit(BcoApplicationsLoading());
    try {
      final response = await repository.getApplications(page: 1, status: event.status);
      emit(BcoApplicationsLoaded(
        applications: response['applications'],
        hasReachedMax: response['hasReachedMax'],
        currentPage: 1,
        currentFilter: event.status,
      ));
    } catch (e) {
      emit(BcoApplicationsError(e.toString()));
    }
  }

  Future<void> _onLoadMore(LoadMoreBcoApplications event, Emitter<BcoApplicationsState> emit) async {
    final currentState = state;
    if (currentState is BcoApplicationsLoaded && !currentState.hasReachedMax) {
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
        emit(BcoApplicationsError(e.toString()));
      }
    }
  }
}
