import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/bco_repository.dart';
import '../../models/express_penalty_invoice_model.dart';
import 'bco_express_penalty_invoices_event.dart';
import 'bco_express_penalty_invoices_state.dart';

class BcoExpressPenaltyInvoicesBloc extends Bloc<BcoExpressPenaltyInvoicesEvent, BcoExpressPenaltyInvoicesState> {
  final BcoRepository repository;
  int _currentPage = 1;
  String _currentFilter = 'ALL';

  BcoExpressPenaltyInvoicesBloc({required this.repository}) : super(BcoExpressPenaltyInvoicesInitial()) {
    on<FetchBcoExpressPenaltyInvoices>(_onFetch);
    on<LoadMoreBcoExpressPenaltyInvoices>(_onLoadMore);
    on<ChangeBcoExpressPenaltyInvoicesFilter>(_onChangeFilter);
  }

  Future<void> _onFetch(FetchBcoExpressPenaltyInvoices event, Emitter<BcoExpressPenaltyInvoicesState> emit) async {
    if (event.isRefresh) {
      _currentPage = 1;
    }
    
    emit(BcoExpressPenaltyInvoicesLoading(const [], isFirstFetch: _currentPage == 1));

    try {
      final result = await repository.getExpressPenaltyInvoices(page: _currentPage, filter: _currentFilter);
      emit(BcoExpressPenaltyInvoicesLoaded(
        result['invoices'] as List<ExpressPenaltyInvoiceModel>,
        result['hasReachedMax'] as bool,
        _currentFilter,
      ));
    } catch (e) {
      emit(BcoExpressPenaltyInvoicesError(e.toString()));
    }
  }

  Future<void> _onLoadMore(LoadMoreBcoExpressPenaltyInvoices event, Emitter<BcoExpressPenaltyInvoicesState> emit) async {
    if (state is BcoExpressPenaltyInvoicesLoaded) {
      final currentState = state as BcoExpressPenaltyInvoicesLoaded;
      if (currentState.hasReachedMax) return;

      try {
        _currentPage++;
        final result = await repository.getExpressPenaltyInvoices(page: _currentPage, filter: _currentFilter);
        final newInvoices = result['invoices'] as List<ExpressPenaltyInvoiceModel>;
        
        emit(BcoExpressPenaltyInvoicesLoaded(
          [...currentState.invoices, ...newInvoices],
          result['hasReachedMax'] as bool,
          _currentFilter,
        ));
      } catch (e) {
        emit(BcoExpressPenaltyInvoicesError(e.toString()));
      }
    }
  }

  Future<void> _onChangeFilter(ChangeBcoExpressPenaltyInvoicesFilter event, Emitter<BcoExpressPenaltyInvoicesState> emit) async {
    _currentFilter = event.filter;
    _currentPage = 1;
    add(FetchBcoExpressPenaltyInvoices(isRefresh: true));
  }
}
