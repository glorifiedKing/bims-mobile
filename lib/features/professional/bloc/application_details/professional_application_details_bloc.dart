import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/professional_repository.dart';
import 'professional_application_details_event.dart';
import 'professional_application_details_state.dart';

class ProfessionalApplicationDetailsBloc extends Bloc<ProfessionalApplicationDetailsEvent, ProfessionalApplicationDetailsState> {
  final ProfessionalRepository repository;

  ProfessionalApplicationDetailsBloc({required this.repository}) : super(ProfessionalApplicationDetailsInitial()) {
    on<FetchProfessionalApplicationDetails>((event, emit) async {
      emit(ProfessionalApplicationDetailsLoading());
      try {
        final details = await repository.getApplicationDetails(event.applicationKey);
        emit(ProfessionalApplicationDetailsLoaded(details));
      } catch (e) {
        emit(ProfessionalApplicationDetailsError(e.toString()));
      }
    });
  }
}
