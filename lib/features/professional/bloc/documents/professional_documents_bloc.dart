import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/professional_repository.dart';
import 'professional_documents_event.dart';
import 'professional_documents_state.dart';

class ProfessionalDocumentsBloc extends Bloc<ProfessionalDocumentsEvent, ProfessionalDocumentsState> {
  final ProfessionalRepository repository;

  ProfessionalDocumentsBloc({required this.repository}) : super(ProfessionalDocumentsInitial()) {
    on<FetchProfessionalDocuments>((event, emit) async {
      emit(ProfessionalDocumentsLoading());
      try {
        final documents = await repository.getDocuments();
        emit(ProfessionalDocumentsLoaded(documents));
      } catch (e) {
        emit(ProfessionalDocumentsError(e.toString()));
      }
    });
  }
}
