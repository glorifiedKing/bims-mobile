import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/client_repository.dart';
import 'client_profile_event.dart';
import 'client_profile_state.dart';

class ClientProfileBloc extends Bloc<ClientProfileEvent, ClientProfileState> {
  final ClientRepository _repository;

  ClientProfileBloc({required ClientRepository repository})
    : _repository = repository,
      super(ClientProfileInitial()) {
    on<FetchClientProfile>(_onFetchClientProfile);
    on<UpdateClientProfile>(_onUpdateClientProfile);
  }

  Future<void> _onFetchClientProfile(
    FetchClientProfile event,
    Emitter<ClientProfileState> emit,
  ) async {
    emit(ClientProfileLoading());
    try {
      final profile = await _repository.getClientProfile();
      emit(ClientProfileLoaded(profile));
    } catch (e) {
      emit(ClientProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateClientProfile(
    UpdateClientProfile event,
    Emitter<ClientProfileState> emit,
  ) async {
    emit(ClientProfileUpdateLoading());
    try {
      await _repository.updateClientProfile(event.data);
      emit(ClientProfileUpdateSuccess(requiresLogout: event.requiresLogout));
    } catch (e) {
      emit(ClientProfileUpdateFailure(e.toString()));
    }
  }
}
