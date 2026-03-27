import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/client_repository.dart';
import 'client_inspection_invoices_event.dart';
import 'client_inspection_invoices_state.dart';

class ClientInspectionInvoicesBloc extends Bloc<ClientInspectionInvoicesEvent, ClientInspectionInvoicesState> {
  final ClientRepository repository;
  
  ClientInspectionInvoicesBloc({required this.repository}) : super(ClientInspectionInvoicesInitial()) {
    on<FetchClientInspectionInvoices>(_onFetch);
    on<LoadMoreClientInspectionInvoices>(_onLoadMore);
    on<ChangeClientInspectionInvoicesFilter>(_onChangeFilter);
    on<SearchClientInspectionInvoices>(_onSearchFilter);
  }

  void _onSearchFilter(SearchClientInspectionInvoices event, Emitter<ClientInspectionInvoicesState> emit) {
    if (state is ClientInspectionInvoicesLoaded) {
      final currentState = state as ClientInspectionInvoicesLoaded;
      emit(currentState.copyWith(searchQuery: event.query));
    }
  }

  Future<void> _onFetch(FetchClientInspectionInvoices event, Emitter<ClientInspectionInvoicesState> emit) async {
    String? currentSearchQuery;
    if (state is ClientInspectionInvoicesLoaded) {
      currentSearchQuery = (state as ClientInspectionInvoicesLoaded).searchQuery;
    }
    emit(ClientInspectionInvoicesLoading());
    try {
      final results = await Future.wait([
        repository.getInspectionInvoices(page: 1, filter: 'ALL'),
        repository.getInspectionInvoicesTotal(),
      ]);
      final invoicesResult = results[0] as Map<String, dynamic>;
      final totalStr = results[1] as String;
      
      emit(ClientInspectionInvoicesLoaded(
        invoices: invoicesResult['invoices'],
        hasReachedMax: invoicesResult['hasReachedMax'],
        selectedFilter: 'ALL',
        currentPage: 1,
        totalUnpaid: totalStr,
        searchQuery: currentSearchQuery,
      ));
    } catch (e) {
      emit(ClientInspectionInvoicesError(e.toString()));
    }
  }

  Future<void> _onLoadMore(LoadMoreClientInspectionInvoices event, Emitter<ClientInspectionInvoicesState> emit) async {
    final currentState = state;
    if (currentState is ClientInspectionInvoicesLoaded && !currentState.hasReachedMax) {
      try {
        final nextPage = currentState.currentPage + 1;
        final result = await repository.getInspectionInvoices(
          page: nextPage,
          filter: currentState.selectedFilter,
        );
        emit(currentState.copyWith(
          invoices: currentState.invoices + result['invoices'],
          hasReachedMax: result['hasReachedMax'],
          currentPage: nextPage,
        ));
      } catch (e) {
        emit(ClientInspectionInvoicesError(e.toString()));
      }
    }
  }

  Future<void> _onChangeFilter(ChangeClientInspectionInvoicesFilter event, Emitter<ClientInspectionInvoicesState> emit) async {
    String? currentTotalUnpaid;
    String? currentSearchQuery;
    if (state is ClientInspectionInvoicesLoaded) {
      currentTotalUnpaid = (state as ClientInspectionInvoicesLoaded).totalUnpaid;
      currentSearchQuery = (state as ClientInspectionInvoicesLoaded).searchQuery;
    }
    emit(ClientInspectionInvoicesLoading());
    try {
      final result = await repository.getInspectionInvoices(
        page: 1,
        filter: event.filter,
      );
      emit(ClientInspectionInvoicesLoaded(
        invoices: result['invoices'],
        hasReachedMax: result['hasReachedMax'],
        selectedFilter: event.filter,
        currentPage: 1,
        totalUnpaid: currentTotalUnpaid,
        searchQuery: currentSearchQuery,
      ));
    } catch (e) {
      emit(ClientInspectionInvoicesError(e.toString()));
    }
  }
}
