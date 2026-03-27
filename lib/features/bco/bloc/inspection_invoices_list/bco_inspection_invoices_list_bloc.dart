import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/bco_repository.dart';
import 'bco_inspection_invoices_list_event.dart';
import 'bco_inspection_invoices_list_state.dart';

class BcoInspectionInvoicesListBloc extends Bloc<BcoInspectionInvoicesListEvent, BcoInspectionInvoicesListState> {
  final BcoRepository repository;

  BcoInspectionInvoicesListBloc({required this.repository}) : super(BcoInspectionInvoicesListInitial()) {
    on<FetchBcoInspectionInvoicesList>(_onFetch);
    on<LoadMoreBcoInspectionInvoicesList>(_onLoadMore);
    on<ChangeBcoInspectionInvoicesListFilter>(_onChangeFilter);
  }

  Future<void> _onFetch(FetchBcoInspectionInvoicesList event, Emitter<BcoInspectionInvoicesListState> emit) async {
    final currentFilter = event.filter ?? (state is BcoInspectionInvoicesListLoaded ? (state as BcoInspectionInvoicesListLoaded).selectedFilter : 'ALL');
    emit(BcoInspectionInvoicesListLoading());
    try {
      final response = await repository.getInspectionInvoices(page: 1, filter: currentFilter);
      emit(BcoInspectionInvoicesListLoaded(
        invoices: response['invoices'],
        hasReachedMax: response['hasReachedMax'],
        currentPage: 1,
        selectedFilter: currentFilter,
      ));
    } catch (e) {
      emit(BcoInspectionInvoicesListError(e.toString()));
    }
  }

  Future<void> _onLoadMore(LoadMoreBcoInspectionInvoicesList event, Emitter<BcoInspectionInvoicesListState> emit) async {
    final currentState = state;
    if (currentState is BcoInspectionInvoicesListLoaded && !currentState.hasReachedMax) {
      try {
        final nextPage = currentState.currentPage + 1;
        final response = await repository.getInspectionInvoices(
          page: nextPage,
          filter: currentState.selectedFilter,
        );
        emit(currentState.copyWith(
          invoices: List.of(currentState.invoices)..addAll(response['invoices']),
          hasReachedMax: response['hasReachedMax'],
          currentPage: nextPage,
        ));
      } catch (e) {
        emit(BcoInspectionInvoicesListError(e.toString()));
      }
    }
  }

  void _onChangeFilter(ChangeBcoInspectionInvoicesListFilter event, Emitter<BcoInspectionInvoicesListState> emit) {
    if (state is BcoInspectionInvoicesListLoaded && (state as BcoInspectionInvoicesListLoaded).selectedFilter == event.filter) return;
    add(FetchBcoInspectionInvoicesList(filter: event.filter, isRefresh: true));
  }
}
