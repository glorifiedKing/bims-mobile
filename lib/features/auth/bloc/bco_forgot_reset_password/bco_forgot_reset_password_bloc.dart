import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/bco/repositories/bco_repository.dart';
import 'bco_forgot_reset_password_event.dart';
import 'bco_forgot_reset_password_state.dart';

class BcoForgotResetPasswordBloc
    extends Bloc<BcoForgotResetPasswordEvent, BcoForgotResetPasswordState> {
  final BcoRepository _repository;

  BcoForgotResetPasswordBloc({required BcoRepository repository})
      : _repository = repository,
        super(BcoForgotResetPasswordInitial()) {
    on<BcoForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<BcoResetPasswordSubmitted>(_onResetPasswordSubmitted);
  }

  Future<void> _onForgotPasswordSubmitted(
    BcoForgotPasswordSubmitted event,
    Emitter<BcoForgotResetPasswordState> emit,
  ) async {
    emit(BcoForgotPasswordLoading());
    try {
      final email = event.email.trim();
      if (email.isEmpty) {
        emit(BcoForgotResetPasswordError('Please enter your email address.'));
        return;
      }

      await _repository.forgotPassword(email: email);

      emit(BcoForgotPasswordSuccess(
        message: 'Password reset code has been sent successfully.',
        email: email,
      ));
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      emit(BcoForgotResetPasswordError(errorMsg));
    }
  }

  Future<void> _onResetPasswordSubmitted(
    BcoResetPasswordSubmitted event,
    Emitter<BcoForgotResetPasswordState> emit,
  ) async {
    emit(BcoResetPasswordLoading());
    try {
      if (event.token.trim().isEmpty) {
        emit(BcoForgotResetPasswordError('Please enter the verification code.'));
        return;
      }
      if (event.newPassword.isEmpty) {
        emit(BcoForgotResetPasswordError('Please enter a new password.'));
        return;
      }
      if (event.newPassword != event.confirmPassword) {
        emit(BcoForgotResetPasswordError('Passwords do not match.'));
        return;
      }

      await _repository.resetPassword(
        token: event.token.trim(),
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );

      emit(BcoResetPasswordSuccess('Password changed successfully.'));
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      emit(BcoForgotResetPasswordError(errorMsg));
    }
  }
}
