import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/permit_model.dart';
import '../../repositories/client_repository.dart';
import 'client_permits_event.dart';
import 'client_permits_state.dart';

class ClientPermitsBloc extends Bloc<ClientPermitsEvent, ClientPermitsState> {
  final ClientRepository _repository;
  int _currentPage = 1;
  bool _isFetching = false;

  ClientPermitsBloc({required ClientRepository repository})
    : _repository = repository,
      super(ClientPermitsInitial()) {
    on<FetchClientPermits>(_onFetchClientPermits);
    on<LoadMoreClientPermits>(_onLoadMoreClientPermits);
    on<SearchClientPermits>(_onSearchClientPermits);
  }

  void _onSearchClientPermits(
    SearchClientPermits event,
    Emitter<ClientPermitsState> emit,
  ) {
    if (state is ClientPermitsLoaded) {
      final currentState = state as ClientPermitsLoaded;
      emit(currentState.copyWith(searchQuery: event.query));
    }
  }

  Future<void> _onFetchClientPermits(
    FetchClientPermits event,
    Emitter<ClientPermitsState> emit,
  ) async {
    _currentPage = 1;
    String? currentSearchQuery;
    if (state is ClientPermitsLoaded) {
      currentSearchQuery = (state as ClientPermitsLoaded).searchQuery;
    }
    emit(ClientPermitsLoading());
    try {
      final response = await _repository.getPermits(page: _currentPage);
      final permits = response['permits'] as List<PermitModel>;
      final hasReachedMax = response['hasReachedMax'] as bool;
      emit(ClientPermitsLoaded(
        permits: permits,
        hasReachedMax: hasReachedMax,
        searchQuery: currentSearchQuery,
      ));
    } catch (e) {
      emit(ClientPermitsError(e.toString()));
    }
  }

  Future<void> _onLoadMoreClientPermits(
    LoadMoreClientPermits event,
    Emitter<ClientPermitsState> emit,
  ) async {
    final currentState = state;
    if (currentState is ClientPermitsLoaded &&
        !currentState.hasReachedMax &&
        !_isFetching) {
      _isFetching = true;
      _currentPage++;
      try {
        final response = await _repository.getPermits(page: _currentPage);
        final newPermits = response['permits'] as List<PermitModel>;
        final hasReachedMax = response['hasReachedMax'] as bool;
        emit(
          currentState.copyWith(
            permits: List.of(currentState.permits)..addAll(newPermits),
            hasReachedMax: hasReachedMax,
          ),
        );
      } catch (e) {
        _currentPage--;
      }
      _isFetching = false;
    }
  }
}
