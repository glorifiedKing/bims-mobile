abstract class BcoForgotResetPasswordState {}

class BcoForgotResetPasswordInitial extends BcoForgotResetPasswordState {}

class BcoForgotPasswordLoading extends BcoForgotResetPasswordState {}

class BcoForgotPasswordSuccess extends BcoForgotResetPasswordState {
  final String message;
  final String email;

  BcoForgotPasswordSuccess({
    required this.message,
    required this.email,
  });
}

class BcoResetPasswordLoading extends BcoForgotResetPasswordState {}

class BcoResetPasswordSuccess extends BcoForgotResetPasswordState {
  final String message;

  BcoResetPasswordSuccess(this.message);
}

class BcoForgotResetPasswordError extends BcoForgotResetPasswordState {
  final String message;

  BcoForgotResetPasswordError(this.message);
}
