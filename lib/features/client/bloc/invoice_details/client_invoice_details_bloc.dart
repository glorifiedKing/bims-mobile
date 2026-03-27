import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/client_repository.dart';
import 'client_invoice_details_event.dart';
import 'client_invoice_details_state.dart';

class ClientInvoiceDetailsBloc
    extends Bloc<ClientInvoiceDetailsEvent, ClientInvoiceDetailsState> {
  final ClientRepository _repository;

  ClientInvoiceDetailsBloc({required ClientRepository repository})
    : _repository = repository,
      super(ClientInvoiceDetailsInitial()) {
    on<FetchClientInvoiceDetails>(_onFetchClientInvoiceDetails);
  }

  Future<void> _onFetchClientInvoiceDetails(
    FetchClientInvoiceDetails event,
    Emitter<ClientInvoiceDetailsState> emit,
  ) async {
    emit(ClientInvoiceDetailsLoading());
    try {
      final details = await _repository.getInvoiceDetails(event.prn);
      emit(ClientInvoiceDetailsLoaded(details));
    } catch (e) {
      emit(ClientInvoiceDetailsError(e.toString()));
    }
  }
}
