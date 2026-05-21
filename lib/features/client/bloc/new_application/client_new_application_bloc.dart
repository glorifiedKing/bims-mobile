import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/client_repository.dart';
import 'client_new_application_event.dart';
import 'client_new_application_state.dart';

class ClientNewApplicationBloc extends Bloc<ClientNewApplicationEvent, ClientNewApplicationState> {
  final ClientRepository repository;

  ClientNewApplicationBloc({required this.repository}) : super(ClientNewApplicationInitial()) {
    on<SubmitApplication>(_onSubmitApplication);
    on<UpdateApplication>(_onUpdateApplication);
  }

  Future<void> _onSubmitApplication(
    SubmitApplication event,
    Emitter<ClientNewApplicationState> emit,
  ) async {
    emit(ClientNewApplicationLoading());
    try {
      await repository.submitApplication(event.data);
      emit(ClientNewApplicationSuccess());
    } catch (e) {
      emit(ClientNewApplicationError(e.toString()));
    }
  }

  Future<void> _onUpdateApplication(
    UpdateApplication event,
    Emitter<ClientNewApplicationState> emit,
  ) async {
    emit(ClientNewApplicationLoading());
    try {
      await repository.updateApplication(event.id, event.data);
      emit(ClientNewApplicationSuccess());
    } catch (e) {
      emit(ClientNewApplicationError(e.toString()));
    }
  }
}
