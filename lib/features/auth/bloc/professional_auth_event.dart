abstract class ProfessionalAuthEvent {}

class ProfessionalAuthLoginRequested extends ProfessionalAuthEvent {
  final String identifier;
  final String password;

  ProfessionalAuthLoginRequested(this.identifier, this.password);
}

class ProfessionalAuthLogoutRequested extends ProfessionalAuthEvent {}

class ProfessionalAuthCheckRequested extends ProfessionalAuthEvent {}

class ProfessionalAuthBiometricLoginRequested extends ProfessionalAuthEvent {
  final String oldToken;
  ProfessionalAuthBiometricLoginRequested(this.oldToken);
}
