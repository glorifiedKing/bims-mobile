import 'package:flutter_bloc/flutter_bloc.dart';
import 'professional_counters_event.dart';
import 'professional_counters_state.dart';
import '../../repositories/professional_repository.dart';

class ProfessionalCountersBloc extends Bloc<ProfessionalCountersEvent, ProfessionalCountersState> {
  final ProfessionalRepository repository;

  ProfessionalCountersBloc({required this.repository}) : super(ProfessionalCountersInitial()) {
    on<FetchProfessionalCounters>((event, emit) async {
      emit(ProfessionalCountersLoading());
      try {
        final counters = await repository.getCounters();
        emit(ProfessionalCountersLoaded(counters));
      } catch (e) {
        emit(ProfessionalCountersError(e.toString()));
      }
    });
  }
}
