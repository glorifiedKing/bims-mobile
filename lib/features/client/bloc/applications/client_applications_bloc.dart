import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/application_model.dart';
import '../../repositories/client_repository.dart';
import 'client_applications_event.dart';
import 'client_applications_state.dart';

class ClientApplicationsBloc
    extends Bloc<ClientApplicationsEvent, ClientApplicationsState> {
  final ClientRepository _repository;
  int _currentPage = 1;
  bool _isFetching = false;
  String _currentFilter = 'ALL';

  ClientApplicationsBloc({required ClientRepository repository})
    : _repository = repository,
      super(ClientApplicationsInitial()) {
    on<FetchClientApplications>(_onFetchClientApplications);
    on<LoadMoreClientApplications>(_onLoadMoreClientApplications);
    on<ChangeClientApplicationsFilter>(_onChangeClientApplicationsFilter);
  }

  Future<void> _onChangeClientApplicationsFilter(
    ChangeClientApplicationsFilter event,
    Emitter<ClientApplicationsState> emit,
  ) async {
    if (_currentFilter == event.filter) return;
    _currentFilter = event.filter;

    emit(ClientApplicationsLoading());
    _currentPage = 1;
    _isFetching = true;
    try {
      final response = await _repository.getApplications(
        page: _currentPage,
        status: _currentFilter == 'ALL' ? null : _currentFilter,
      );
      final apps = response['applications'] as List<ApplicationModel>;
      final hasReachedMax = response['hasReachedMax'] as bool;

      emit(
        ClientApplicationsLoaded(
          applications: apps,
          hasReachedMax: hasReachedMax,
          selectedFilter: _currentFilter,
        ),
      );
    } catch (e) {
      emit(ClientApplicationsError(e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onFetchClientApplications(
    FetchClientApplications event,
    Emitter<ClientApplicationsState> emit,
  ) async {
    emit(ClientApplicationsLoading());
    _currentPage = 1;
    _isFetching = true;
    try {
      final response = await _repository.getApplications(
        page: _currentPage,
        status: _currentFilter == 'ALL' ? null : _currentFilter,
      );
      final apps = response['applications'] as List<ApplicationModel>;
      final hasReachedMax = response['hasReachedMax'] as bool;

      emit(
        ClientApplicationsLoaded(
          applications: apps,
          hasReachedMax: hasReachedMax,
          selectedFilter: _currentFilter,
        ),
      );
    } catch (e) {
      emit(ClientApplicationsError(e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onLoadMoreClientApplications(
    LoadMoreClientApplications event,
    Emitter<ClientApplicationsState> emit,
  ) async {
    if (_isFetching) return;

    final currentState = state;
    if (currentState is ClientApplicationsLoaded) {
      if (currentState.hasReachedMax) return;

      _isFetching = true;
      try {
        _currentPage++;
        final response = await _repository.getApplications(
          page: _currentPage,
          status: _currentFilter == 'ALL' ? null : _currentFilter,
        );
        final apps = response['applications'] as List<ApplicationModel>;
        final hasReachedMax = response['hasReachedMax'] as bool;

        if (apps.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          emit(
            currentState.copyWith(
              applications: List.of(currentState.applications)..addAll(apps),
              hasReachedMax: hasReachedMax,
              selectedFilter: _currentFilter,
            ),
          );
        }
      } catch (e) {
        emit(ClientApplicationsError(e.toString()));
      } finally {
        _isFetching = false;
      }
    }
  }
}
