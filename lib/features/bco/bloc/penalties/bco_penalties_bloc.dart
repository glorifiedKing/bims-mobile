import 'package:flutter_bloc/flutter_bloc.dart';
import 'bco_penalties_event.dart';
import 'bco_penalties_state.dart';
import '../../repositories/bco_repository.dart';

class BcoPenaltiesBloc extends Bloc<BcoPenaltiesEvent, BcoPenaltiesState> {
  final BcoRepository repository;

  BcoPenaltiesBloc({required this.repository}) : super(BcoPenaltiesInitial()) {
    on<FetchBcoPenalties>(_onFetchBcoPenalties);
    on<LoadMoreBcoPenalties>(_onLoadMoreBcoPenalties);
  }

  Future<void> _onFetchBcoPenalties(
    FetchBcoPenalties event,
    Emitter<BcoPenaltiesState> emit,
  ) async {
    try {
      if (!event.isRefresh && state is! BcoPenaltiesLoaded) {
        emit(BcoPenaltiesLoading());
      }

      final result = await repository.getExpressPenalties(
        page: 1,
        status: event.status,
      );

      emit(BcoPenaltiesLoaded(
        penalties: result['penalties'],
        hasReachedMax: result['hasReachedMax'],
        currentPage: 1,
        currentFilter: event.status,
      ));
    } catch (e) {
      emit(BcoPenaltiesError(e.toString()));
    }
  }

  Future<void> _onLoadMoreBcoPenalties(
    LoadMoreBcoPenalties event,
    Emitter<BcoPenaltiesState> emit,
  ) async {
    final currentState = state;
    if (currentState is BcoPenaltiesLoaded && !currentState.hasReachedMax) {
      try {
        final nextPage = currentState.currentPage + 1;
        final result = await repository.getExpressPenalties(
          page: nextPage,
          status: currentState.currentFilter,
        );

        emit(currentState.copyWith(
          penalties: List.of(currentState.penalties)..addAll(result['penalties']),
          hasReachedMax: result['hasReachedMax'],
          currentPage: nextPage,
        ));
      } catch (e) {
        emit(BcoPenaltiesError(e.toString()));
      }
    }
  }
}
