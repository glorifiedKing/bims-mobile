import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/client_repository.dart';
import 'client_application_details_event.dart';
import 'client_application_details_state.dart';

class ClientApplicationDetailsBloc
    extends Bloc<ClientApplicationDetailsEvent, ClientApplicationDetailsState> {
  final ClientRepository _repository;

  ClientApplicationDetailsBloc({required ClientRepository repository})
    : _repository = repository,
      super(ClientApplicationDetailsInitial()) {
    on<FetchClientApplicationDetails>(_onFetchClientApplicationDetails);
  }

  Future<void> _onFetchClientApplicationDetails(
    FetchClientApplicationDetails event,
    Emitter<ClientApplicationDetailsState> emit,
  ) async {
    emit(ClientApplicationDetailsLoading());
    try {
      final details = await _repository.getApplicationDetails(
        event.applicationKey,
      );
      emit(ClientApplicationDetailsLoaded(details));
    } catch (e) {
      emit(ClientApplicationDetailsError(e.toString()));
    }
  }
}
