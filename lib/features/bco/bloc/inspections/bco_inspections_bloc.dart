import 'package:flutter_bloc/flutter_bloc.dart';
import 'bco_inspections_event.dart';
import 'bco_inspections_state.dart';
import '../../repositories/bco_repository.dart';

class BcoInspectionsBloc extends Bloc<BcoInspectionsEvent, BcoInspectionsState> {
  final BcoRepository repository;

  BcoInspectionsBloc({required this.repository}) : super(BcoInspectionsInitial()) {
    on<FetchBcoInspections>(_onFetchBcoInspections);
    on<LoadMoreBcoInspections>(_onLoadMoreBcoInspections);
  }

  Future<void> _onFetchBcoInspections(
    FetchBcoInspections event,
    Emitter<BcoInspectionsState> emit,
  ) async {
    try {
      if (!event.isRefresh) {
        emit(BcoInspectionsLoading());
      }

      final result = await repository.getInspections(
        page: 1,
        inspectionType: event.inspectionTypeId,
        inspectionStatus: event.inspectionStatusId,
        start: event.start,
        end: event.end,
      );

      emit(BcoInspectionsLoaded(
        inspections: result['inspections'],
        hasReachedMax: result['hasReachedMax'],
        currentPage: 1,
        currentTypeId: event.inspectionTypeId,
        currentStatusId: event.inspectionStatusId,
        currentStart: event.start,
        currentEnd: event.end,
      ));
    } catch (e) {
      emit(BcoInspectionsError(e.toString()));
    }
  }

  Future<void> _onLoadMoreBcoInspections(
    LoadMoreBcoInspections event,
    Emitter<BcoInspectionsState> emit,
  ) async {
    final currentState = state;
    if (currentState is BcoInspectionsLoaded && !currentState.hasReachedMax) {
      try {
        final nextPage = currentState.currentPage + 1;
        final result = await repository.getInspections(
          page: nextPage,
          inspectionType: currentState.currentTypeId,
          inspectionStatus: currentState.currentStatusId,
          start: currentState.currentStart,
          end: currentState.currentEnd,
        );

        emit(currentState.copyWith(
          inspections: List.of(currentState.inspections)
            ..addAll(result['inspections']),
          hasReachedMax: result['hasReachedMax'],
          currentPage: nextPage,
        ));
      } catch (e) {
        emit(BcoInspectionsError(e.toString()));
      }
    }
  }
}
