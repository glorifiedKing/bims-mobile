import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/client_repository.dart';
import 'client_assessment_event.dart';
import 'client_assessment_state.dart';

class ClientAssessmentBloc extends Bloc<ClientAssessmentEvent, ClientAssessmentState> {
  final ClientRepository repository;

  ClientAssessmentBloc({required this.repository}) : super(ClientAssessmentInitial()) {
    on<FetchAssessment>(_onFetchAssessment);
    on<GeneratePrn>(_onGeneratePrn);
  }

  Future<void> _onFetchAssessment(
    FetchAssessment event,
    Emitter<ClientAssessmentState> emit,
  ) async {
    emit(ClientAssessmentLoading());
    try {
      final assessmentModel = await repository.getAssessment(event.applicationKey);
      emit(ClientAssessmentLoaded(assessmentModel));
    } catch (e) {
      emit(ClientAssessmentError(e.toString()));
    }
  }

  Future<void> _onGeneratePrn(
    GeneratePrn event,
    Emitter<ClientAssessmentState> emit,
  ) async {
    emit(ClientAssessmentLoading());
    try {
      final prn = await repository.generatePrn(event.applicationKey, event.data);
      emit(ClientAssessmentPrnGenerated(prn));
    } catch (e) {
      emit(ClientAssessmentError(e.toString()));
    }
  }
}
