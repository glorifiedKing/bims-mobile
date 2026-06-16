abstract class BcoForgotResetPasswordEvent {}

class BcoForgotPasswordSubmitted extends BcoForgotResetPasswordEvent {
  final String email;

  BcoForgotPasswordSubmitted(this.email);
}

class BcoResetPasswordSubmitted extends BcoForgotResetPasswordEvent {
  final String token;
  final String newPassword;
  final String confirmPassword;

  BcoResetPasswordSubmitted({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });
}
