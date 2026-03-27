import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/bco_repository.dart';
import 'bco_general_invoices_event.dart';
import 'bco_general_invoices_state.dart';

class BcoGeneralInvoicesBloc extends Bloc<BcoGeneralInvoicesEvent, BcoGeneralInvoicesState> {
  final BcoRepository repository;

  BcoGeneralInvoicesBloc({required this.repository}) : super(BcoGeneralInvoicesInitial()) {
    on<FetchBcoGeneralInvoices>(_onFetch);
    on<LoadMoreBcoGeneralInvoices>(_onLoadMore);
    on<ChangeBcoGeneralInvoicesFilter>(_onChangeFilter);
  }

  Future<void> _onFetch(FetchBcoGeneralInvoices event, Emitter<BcoGeneralInvoicesState> emit) async {
    final currentFilter = event.filter ?? (state is BcoGeneralInvoicesLoaded ? (state as BcoGeneralInvoicesLoaded).selectedFilter : 'ALL');
    emit(BcoGeneralInvoicesLoading());
    try {
      final response = await repository.getInvoices(page: 1, filter: currentFilter);
      emit(BcoGeneralInvoicesLoaded(
        invoices: response['invoices'],
        hasReachedMax: response['hasReachedMax'],
        currentPage: 1,
        selectedFilter: currentFilter,
      ));
    } catch (e) {
      emit(BcoGeneralInvoicesError(e.toString()));
    }
  }

  Future<void> _onLoadMore(LoadMoreBcoGeneralInvoices event, Emitter<BcoGeneralInvoicesState> emit) async {
    final currentState = state;
    if (currentState is BcoGeneralInvoicesLoaded && !currentState.hasReachedMax) {
      try {
        final nextPage = currentState.currentPage + 1;
        final response = await repository.getInvoices(
          page: nextPage,
          filter: currentState.selectedFilter,
        );
        emit(currentState.copyWith(
          invoices: List.of(currentState.invoices)..addAll(response['invoices']),
          hasReachedMax: response['hasReachedMax'],
          currentPage: nextPage,
        ));
      } catch (e) {
        emit(BcoGeneralInvoicesError(e.toString()));
      }
    }
  }

  void _onChangeFilter(ChangeBcoGeneralInvoicesFilter event, Emitter<BcoGeneralInvoicesState> emit) {
    if (state is BcoGeneralInvoicesLoaded && (state as BcoGeneralInvoicesLoaded).selectedFilter == event.filter) return;
    add(FetchBcoGeneralInvoices(filter: event.filter, isRefresh: true));
  }
}
