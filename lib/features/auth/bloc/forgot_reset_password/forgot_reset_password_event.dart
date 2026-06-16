abstract class ForgotResetPasswordEvent {}

class ForgotPasswordSubmitted extends ForgotResetPasswordEvent {
  final String identifier; // email or phone number

  ForgotPasswordSubmitted(this.identifier);
}

class ResetPasswordSubmitted extends ForgotResetPasswordEvent {
  final String token;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordSubmitted({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });
}
