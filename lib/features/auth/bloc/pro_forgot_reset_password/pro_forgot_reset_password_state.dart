abstract class ProForgotResetPasswordState {}

class ProForgotResetPasswordInitial extends ProForgotResetPasswordState {}

class ProForgotPasswordLoading extends ProForgotResetPasswordState {}

class ProForgotPasswordSuccess extends ProForgotResetPasswordState {
  final String message;
  final String email;

  ProForgotPasswordSuccess({
    required this.message,
    required this.email,
  });
}

class ProResetPasswordLoading extends ProForgotResetPasswordState {}

class ProResetPasswordSuccess extends ProForgotResetPasswordState {
  final String message;

  ProResetPasswordSuccess(this.message);
}

class ProForgotResetPasswordError extends ProForgotResetPasswordState {
  final String message;

  ProForgotResetPasswordError(this.message);
}
