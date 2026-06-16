abstract class ForgotResetPasswordState {}

class ForgotResetPasswordInitial extends ForgotResetPasswordState {}

class ForgotPasswordLoading extends ForgotResetPasswordState {}

class ForgotPasswordSuccess extends ForgotResetPasswordState {
  final String message;
  final String identifier;
  final String type; // 'email' or 'phone'

  ForgotPasswordSuccess({
    required this.message,
    required this.identifier,
    required this.type,
  });
}

class ResetPasswordLoading extends ForgotResetPasswordState {}

class ResetPasswordSuccess extends ForgotResetPasswordState {
  final String message;

  ResetPasswordSuccess(this.message);
}

class ForgotResetPasswordError extends ForgotResetPasswordState {
  final String message;

  ForgotResetPasswordError(this.message);
}
