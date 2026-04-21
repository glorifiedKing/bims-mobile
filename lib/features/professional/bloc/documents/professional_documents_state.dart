import '../../models/professional_documents.dart';

abstract class ProfessionalDocumentsState {}

class ProfessionalDocumentsInitial extends ProfessionalDocumentsState {}

class ProfessionalDocumentsLoading extends ProfessionalDocumentsState {}

class ProfessionalDocumentsLoaded extends ProfessionalDocumentsState {
  final ProfessionalDocuments documents;

  ProfessionalDocumentsLoaded(this.documents);
}

class ProfessionalDocumentsError extends ProfessionalDocumentsState {
  final String message;

  ProfessionalDocumentsError(this.message);
}
