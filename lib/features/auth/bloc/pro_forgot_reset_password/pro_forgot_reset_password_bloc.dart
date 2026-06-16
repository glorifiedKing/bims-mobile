import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/professional/repositories/professional_repository.dart';
import 'pro_forgot_reset_password_event.dart';
import 'pro_forgot_reset_password_state.dart';

class ProForgotResetPasswordBloc
    extends Bloc<ProForgotResetPasswordEvent, ProForgotResetPasswordState> {
  final ProfessionalRepository _repository;

  ProForgotResetPasswordBloc({required ProfessionalRepository repository})
      : _repository = repository,
        super(ProForgotResetPasswordInitial()) {
    on<ProForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<ProResetPasswordSubmitted>(_onResetPasswordSubmitted);
  }

  Future<void> _onForgotPasswordSubmitted(
    ProForgotPasswordSubmitted event,
    Emitter<ProForgotResetPasswordState> emit,
  ) async {
    emit(ProForgotPasswordLoading());
    try {
      final email = event.email.trim();
      if (email.isEmpty) {
        emit(ProForgotResetPasswordError('Please enter your email address.'));
        return;
      }

      await _repository.forgotPassword(email: email);

      emit(ProForgotPasswordSuccess(
        message: 'Password reset code has been sent successfully.',
        email: email,
      ));
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      emit(ProForgotResetPasswordError(errorMsg));
    }
  }

  Future<void> _onResetPasswordSubmitted(
    ProResetPasswordSubmitted event,
    Emitter<ProForgotResetPasswordState> emit,
  ) async {
    emit(ProResetPasswordLoading());
    try {
      if (event.token.trim().isEmpty) {
        emit(ProForgotResetPasswordError('Please enter the verification code.'));
        return;
      }
      if (event.newPassword.isEmpty) {
        emit(ProForgotResetPasswordError('Please enter a new password.'));
        return;
      }
      if (event.newPassword != event.confirmPassword) {
        emit(ProForgotResetPasswordError('Passwords do not match.'));
        return;
      }

      await _repository.resetPassword(
        token: event.token.trim(),
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );

      emit(ProResetPasswordSuccess('Password changed successfully.'));
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      emit(ProForgotResetPasswordError(errorMsg));
    }
  }
}
