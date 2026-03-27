import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/client_repository.dart';
import 'client_permit_details_event.dart';
import 'client_permit_details_state.dart';

class ClientPermitDetailsBloc
    extends Bloc<ClientPermitDetailsEvent, ClientPermitDetailsState> {
  final ClientRepository _repository;

  ClientPermitDetailsBloc({required ClientRepository repository})
    : _repository = repository,
      super(ClientPermitDetailsInitial()) {
    on<FetchClientPermitDetails>(_onFetchClientPermitDetails);
  }

  Future<void> _onFetchClientPermitDetails(
    FetchClientPermitDetails event,
    Emitter<ClientPermitDetailsState> emit,
  ) async {
    emit(ClientPermitDetailsLoading());
    try {
      final permitDetails = await _repository.getPermitDetails(event.serialNo);
      emit(ClientPermitDetailsLoaded(permitDetails));
    } catch (e) {
      emit(ClientPermitDetailsError(e.toString()));
    }
  }
}
