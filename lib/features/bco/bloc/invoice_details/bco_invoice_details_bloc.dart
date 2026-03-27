import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/bco_repository.dart';
import 'bco_invoice_details_event.dart';
import 'bco_invoice_details_state.dart';

class BcoInvoiceDetailsBloc extends Bloc<BcoInvoiceDetailsEvent, BcoInvoiceDetailsState> {
  final BcoRepository repository;

  BcoInvoiceDetailsBloc({required this.repository}) : super(BcoInvoiceDetailsInitial()) {
    on<FetchBcoInvoiceDetails>(_onFetch);
  }

  Future<void> _onFetch(FetchBcoInvoiceDetails event, Emitter<BcoInvoiceDetailsState> emit) async {
    emit(BcoInvoiceDetailsLoading());
    try {
      final details = await repository.getInvoiceDetails(event.prn);
      emit(BcoInvoiceDetailsLoaded(details));
    } catch (e) {
      emit(BcoInvoiceDetailsError(e.toString()));
    }
  }
}
