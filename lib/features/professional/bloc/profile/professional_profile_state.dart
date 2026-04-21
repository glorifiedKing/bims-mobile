import '../../models/professional_profile.dart';

abstract class ProfessionalProfileState {}

class ProfessionalProfileInitial extends ProfessionalProfileState {}

class ProfessionalProfileLoading extends ProfessionalProfileState {}

class ProfessionalProfileLoaded extends ProfessionalProfileState {
  final ProfessionalProfile profile;

  ProfessionalProfileLoaded(this.profile);
}

class ProfessionalProfileError extends ProfessionalProfileState {
  final String message;

  ProfessionalProfileError(this.message);
}
