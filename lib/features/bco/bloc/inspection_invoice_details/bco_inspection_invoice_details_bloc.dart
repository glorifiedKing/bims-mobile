import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/bco_repository.dart';
import 'bco_inspection_invoice_details_event.dart';
import 'bco_inspection_invoice_details_state.dart';

class BcoInspectionInvoiceDetailsBloc extends Bloc<BcoInspectionInvoiceDetailsEvent, BcoInspectionInvoiceDetailsState> {
  final BcoRepository repository;

  BcoInspectionInvoiceDetailsBloc({required this.repository}) : super(BcoInspectionInvoiceDetailsInitial()) {
    on<FetchBcoInspectionInvoiceDetails>(_onFetch);
  }

  Future<void> _onFetch(FetchBcoInspectionInvoiceDetails event, Emitter<BcoInspectionInvoiceDetailsState> emit) async {
    emit(BcoInspectionInvoiceDetailsLoading());
    try {
      final details = await repository.getInspectionInvoiceDetails(event.prn);
      emit(BcoInspectionInvoiceDetailsLoaded(details));
    } catch (e) {
      emit(BcoInspectionInvoiceDetailsError(e.toString()));
    }
  }
}
