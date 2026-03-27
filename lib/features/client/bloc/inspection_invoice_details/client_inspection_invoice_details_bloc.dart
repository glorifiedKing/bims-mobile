import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/client_repository.dart';
import 'client_inspection_invoice_details_event.dart';
import 'client_inspection_invoice_details_state.dart';

class ClientInspectionInvoiceDetailsBloc extends Bloc<ClientInspectionInvoiceDetailsEvent, ClientInspectionInvoiceDetailsState> {
  final ClientRepository repository;
  
  ClientInspectionInvoiceDetailsBloc({required this.repository}) : super(ClientInspectionInvoiceDetailsInitial()) {
    on<FetchClientInspectionInvoiceDetails>(_onFetchDetails);
  }

  Future<void> _onFetchDetails(FetchClientInspectionInvoiceDetails event, Emitter<ClientInspectionInvoiceDetailsState> emit) async {
    emit(ClientInspectionInvoiceDetailsLoading());
    try {
      final invoice = await repository.getInspectionInvoiceDetails(event.prn);
      emit(ClientInspectionInvoiceDetailsLoaded(invoice));
    } catch (e) {
      emit(ClientInspectionInvoiceDetailsError(e.toString()));
    }
  }
}
