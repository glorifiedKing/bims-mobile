import '../../models/pro_application_details_model.dart';

abstract class ProfessionalApplicationDetailsState {}

class ProfessionalApplicationDetailsInitial extends ProfessionalApplicationDetailsState {}

class ProfessionalApplicationDetailsLoading extends ProfessionalApplicationDetailsState {}

class ProfessionalApplicationDetailsLoaded extends ProfessionalApplicationDetailsState {
  final ProApplicationDetailsModel details;

  ProfessionalApplicationDetailsLoaded(this.details);
}

class ProfessionalApplicationDetailsError extends ProfessionalApplicationDetailsState {
  final String message;

  ProfessionalApplicationDetailsError(this.message);
}
