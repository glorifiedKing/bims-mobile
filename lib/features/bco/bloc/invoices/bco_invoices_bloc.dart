import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/bco_repository.dart';
import 'bco_invoices_event.dart';
import 'bco_invoices_state.dart';

class BcoInvoicesBloc extends Bloc<BcoInvoicesEvent, BcoInvoicesState> {
  final BcoRepository repository;

  BcoInvoicesBloc({required this.repository}) : super(BcoInvoicesInitial()) {
    on<FetchBcoInvoicesTotal>(_onFetchTotals);
  }

  Future<void> _onFetchTotals(FetchBcoInvoicesTotal event, Emitter<BcoInvoicesState> emit) async {
    emit(BcoInvoicesLoading());
    try {
      final generalTotal = await repository.getGeneralInvoicesTotal();
      final inspectionTotal = await repository.getInspectionInvoicesTotal();
      emit(BcoInvoicesLoaded(generalTotal: generalTotal, inspectionTotal: inspectionTotal));
    } catch (e) {
      emit(BcoInvoicesError(e.toString()));
    }
  }
}
