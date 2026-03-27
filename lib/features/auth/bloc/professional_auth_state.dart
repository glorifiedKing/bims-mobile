abstract class ProfessionalAuthState {}

class ProfessionalAuthInitial extends ProfessionalAuthState {}

class ProfessionalAuthLoading extends ProfessionalAuthState {}

class ProfessionalAuthAuthenticated extends ProfessionalAuthState {
  final String token;

  ProfessionalAuthAuthenticated(this.token);
}

class ProfessionalAuthUnauthenticated extends ProfessionalAuthState {}

class ProfessionalAuthError extends ProfessionalAuthState {
  final String message;

  ProfessionalAuthError(this.message);
}
