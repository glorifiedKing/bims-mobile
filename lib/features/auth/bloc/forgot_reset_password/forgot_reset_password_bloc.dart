import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/client/repositories/client_repository.dart';
import 'forgot_reset_password_event.dart';
import 'forgot_reset_password_state.dart';

class ForgotResetPasswordBloc
    extends Bloc<ForgotResetPasswordEvent, ForgotResetPasswordState> {
  final ClientRepository _repository;

  ForgotResetPasswordBloc({required ClientRepository repository})
      : _repository = repository,
        super(ForgotResetPasswordInitial()) {
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<ResetPasswordSubmitted>(_onResetPasswordSubmitted);
  }

  Future<void> _onForgotPasswordSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotResetPasswordState> emit,
  ) async {
    emit(ForgotPasswordLoading());
    try {
      final identifier = event.identifier.trim();
      if (identifier.isEmpty) {
        emit(ForgotResetPasswordError('Please enter your email or phone number.'));
        return;
      }

      final isEmail = identifier.contains('@');
      final type = isEmail ? 'email' : 'phone';

      await _repository.forgotPassword(
        type: type,
        email: isEmail ? identifier : null,
        phone: !isEmail ? identifier : null,
      );

      emit(ForgotPasswordSuccess(
        message: 'Password reset code has been sent successfully.',
        identifier: identifier,
        type: type,
      ));
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      emit(ForgotResetPasswordError(errorMsg));
    }
  }

  Future<void> _onResetPasswordSubmitted(
    ResetPasswordSubmitted event,
    Emitter<ForgotResetPasswordState> emit,
  ) async {
    emit(ResetPasswordLoading());
    try {
      if (event.token.trim().isEmpty) {
        emit(ForgotResetPasswordError('Please enter the verification code.'));
        return;
      }
      if (event.newPassword.isEmpty) {
        emit(ForgotResetPasswordError('Please enter a new password.'));
        return;
      }
      if (event.newPassword != event.confirmPassword) {
        emit(ForgotResetPasswordError('Passwords do not match.'));
        return;
      }

      await _repository.resetPassword(
        token: event.token.trim(),
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );

      emit(ResetPasswordSuccess('Password changed successfully.'));
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      emit(ForgotResetPasswordError(errorMsg));
    }
  }
}
