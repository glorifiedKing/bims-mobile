import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/bco_repository.dart';
import 'bco_whistleblows_event.dart';
import 'bco_whistleblows_state.dart';

class BcoWhistleblowsBloc extends Bloc<BcoWhistleblowsEvent, BcoWhistleblowsState> {
  final BcoRepository repository;

  // Filter state
  String? _currentFeedbackType;
  String? _currentAdminUnitId;
  String? _currentSearch;

  BcoWhistleblowsBloc({required this.repository}) : super(BcoWhistleblowsInitial()) {
    on<FetchBcoWhistleblows>(_onFetchBcoWhistleblows);
    on<LoadMoreBcoWhistleblows>(_onLoadMoreBcoWhistleblows);
  }

  Future<void> _onFetchBcoWhistleblows(
    FetchBcoWhistleblows event,
    Emitter<BcoWhistleblowsState> emit,
  ) async {
    if (event.isRefresh) {
      // Retain existing loaded state to show refresh indicator while fetching
    } else {
      emit(BcoWhistleblowsLoading());
    }

    _currentFeedbackType = event.feedbackType;
    _currentAdminUnitId = event.adminUnitId;
    _currentSearch = event.search;

    try {
      final data = await repository.getWhistleblows(
        page: 1,
        feedbackType: _currentFeedbackType,
        adminUnitId: _currentAdminUnitId,
        search: _currentSearch,
      );

      emit(BcoWhistleblowsLoaded(
        whistleblows: data['whistleblows'],
        hasReachedMax: data['hasReachedMax'],
        currentPage: 1,
      ));
    } catch (e) {
      emit(BcoWhistleblowsError(e.toString()));
    }
  }

  Future<void> _onLoadMoreBcoWhistleblows(
    LoadMoreBcoWhistleblows event,
    Emitter<BcoWhistleblowsState> emit,
  ) async {
    final currentState = state;
    if (currentState is BcoWhistleblowsLoaded && !currentState.hasReachedMax) {
      try {
        final nextPage = currentState.currentPage + 1;
        final data = await repository.getWhistleblows(
          page: nextPage,
          feedbackType: _currentFeedbackType,
          adminUnitId: _currentAdminUnitId,
          search: _currentSearch,
        );

        emit(currentState.copyWith(
          whistleblows: List.of(currentState.whistleblows)..addAll(data['whistleblows']),
          hasReachedMax: data['hasReachedMax'],
          currentPage: nextPage,
        ));
      } catch (e) {
        emit(BcoWhistleblowsError(e.toString()));
      }
    }
  }
}
