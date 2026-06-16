abstract class ProForgotResetPasswordEvent {}

class ProForgotPasswordSubmitted extends ProForgotResetPasswordEvent {
  final String email;

  ProForgotPasswordSubmitted(this.email);
}

class ProResetPasswordSubmitted extends ProForgotResetPasswordEvent {
  final String token;
  final String newPassword;
  final String confirmPassword;

  ProResetPasswordSubmitted({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });
}
