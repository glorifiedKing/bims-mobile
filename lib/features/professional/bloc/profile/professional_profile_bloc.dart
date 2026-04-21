import 'package:flutter_bloc/flutter_bloc.dart';
import 'professional_profile_event.dart';
import 'professional_profile_state.dart';
import '../../repositories/professional_repository.dart';

class ProfessionalProfileBloc extends Bloc<ProfessionalProfileEvent, ProfessionalProfileState> {
  final ProfessionalRepository repository;

  ProfessionalProfileBloc({required this.repository}) : super(ProfessionalProfileInitial()) {
    on<FetchProfessionalProfile>((event, emit) async {
      emit(ProfessionalProfileLoading());
      try {
        final profile = await repository.getProfile();
        emit(ProfessionalProfileLoaded(profile));
      } catch (e) {
        emit(ProfessionalProfileError(e.toString()));
      }
    });
  }
}
