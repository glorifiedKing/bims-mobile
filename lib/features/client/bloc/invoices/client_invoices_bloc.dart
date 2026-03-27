import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/invoice_model.dart';
import '../../repositories/client_repository.dart';
import 'client_invoices_event.dart';
import 'client_invoices_state.dart';

class ClientInvoicesBloc
    extends Bloc<ClientInvoicesEvent, ClientInvoicesState> {
  final ClientRepository _repository;
  int _currentPage = 1;
  bool _isFetching = false;

  ClientInvoicesBloc({required ClientRepository repository})
    : _repository = repository,
      super(ClientInvoicesInitial()) {
    on<FetchClientInvoices>(_onFetchClientInvoices);
    on<LoadMoreClientInvoices>(_onLoadMoreClientInvoices);
    on<ChangeClientInvoicesFilter>(_onChangeClientInvoicesFilter);
    on<SearchClientInvoices>(_onSearchClientInvoices);
  }

  void _onSearchClientInvoices(
    SearchClientInvoices event,
    Emitter<ClientInvoicesState> emit,
  ) {
    if (state is ClientInvoicesLoaded) {
      final currentState = state as ClientInvoicesLoaded;
      emit(currentState.copyWith(searchQuery: event.query));
    }
  }

  Future<void> _onFetchClientInvoices(
    FetchClientInvoices event,
    Emitter<ClientInvoicesState> emit,
  ) async {
    _currentPage = 1;
    String currentFilter = 'ALL';
    String? currentSearchQuery;
    if (state is ClientInvoicesLoaded) {
      currentFilter = (state as ClientInvoicesLoaded).selectedFilter;
      currentSearchQuery = (state as ClientInvoicesLoaded).searchQuery;
    }

    emit(ClientInvoicesLoading());
    try {
      final results = await Future.wait([
        _repository.getInvoices(page: _currentPage, filter: currentFilter),
        _repository.getInvoicesTotal(),
      ]);
      final response = results[0] as Map<String, dynamic>;
      final totalStr = results[1] as String;
      final invoices = response['invoices'] as List<InvoiceModel>;
      final hasReachedMax = response['hasReachedMax'] as bool;
      emit(
        ClientInvoicesLoaded(
          invoices: invoices,
          hasReachedMax: hasReachedMax,
          selectedFilter: currentFilter,
          totalUnpaid: totalStr,
          searchQuery: currentSearchQuery,
        ),
      );
    } catch (e) {
      emit(ClientInvoicesError(e.toString()));
    }
  }

  Future<void> _onLoadMoreClientInvoices(
    LoadMoreClientInvoices event,
    Emitter<ClientInvoicesState> emit,
  ) async {
    final currentState = state;
    if (currentState is ClientInvoicesLoaded &&
        !currentState.hasReachedMax &&
        !_isFetching) {
      _isFetching = true;
      _currentPage++;
      try {
        final response = await _repository.getInvoices(
          page: _currentPage,
          filter: currentState.selectedFilter,
        );
        final newInvoices = response['invoices'] as List<InvoiceModel>;
        final hasReachedMax = response['hasReachedMax'] as bool;
        emit(
          currentState.copyWith(
            invoices: List.of(currentState.invoices)..addAll(newInvoices),
            hasReachedMax: hasReachedMax,
          ),
        );
      } catch (e) {
        _currentPage--;
      }
      _isFetching = false;
    }
  }

  Future<void> _onChangeClientInvoicesFilter(
    ChangeClientInvoicesFilter event,
    Emitter<ClientInvoicesState> emit,
  ) async {
    _currentPage = 1;
    String? currentTotalUnpaid;
    String? currentSearchQuery;
    if (state is ClientInvoicesLoaded) {
      currentTotalUnpaid = (state as ClientInvoicesLoaded).totalUnpaid;
      currentSearchQuery = (state as ClientInvoicesLoaded).searchQuery;
    }
    emit(ClientInvoicesLoading());
    try {
      final response = await _repository.getInvoices(
        page: _currentPage,
        filter: event.filter,
      );
      final invoices = response['invoices'] as List<InvoiceModel>;
      final hasReachedMax = response['hasReachedMax'] as bool;
      emit(
        ClientInvoicesLoaded(
          invoices: invoices,
          hasReachedMax: hasReachedMax,
          selectedFilter: event.filter,
          totalUnpaid: currentTotalUnpaid,
          searchQuery: currentSearchQuery,
        ),
      );
    } catch (e) {
      emit(ClientInvoicesError(e.toString()));
    }
  }
}
