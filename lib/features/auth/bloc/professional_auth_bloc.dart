import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../../core/network/pro_api_client.dart';
import '../../../core/constants/api_constants.dart';
import 'professional_auth_event.dart';
import 'professional_auth_state.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/notification_service.dart';

class ProfessionalAuthBloc
    extends Bloc<ProfessionalAuthEvent, ProfessionalAuthState> {
  final ProApiClient proApiClient;

  ProfessionalAuthBloc({required this.proApiClient})
    : super(ProfessionalAuthInitial()) {
    on<ProfessionalAuthLoginRequested>(_onLoginRequested);
    on<ProfessionalAuthLogoutRequested>(_onLogoutRequested);
    on<ProfessionalAuthCheckRequested>(_onCheckRequested);
    on<ProfessionalAuthBiometricLoginRequested>(_onBiometricLogin);
  }

  Future<void> _onLoginRequested(
    ProfessionalAuthLoginRequested event,
    Emitter<ProfessionalAuthState> emit,
  ) async {
    emit(ProfessionalAuthLoading());
    try {
      final response = await proApiClient.dio.post(
        '/token',
        data: {
          'email': event.identifier,
          'password': event.password,
        },
      );
      
      final token = response.data['access_token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('professional_access_token', token);
      await BiometricService().updateProSecureTokenIfEnabled(token);
      emit(ProfessionalAuthAuthenticated(token));
      // Register FCM token with the professional portal.
      NotificationService.instance.sendTokenToApi(portal: Portal.professional);
    } on DioException catch (e) {
      emit(
        ProfessionalAuthError(e.response?.data['message'] ?? 'Login failed'),
      );
    } catch (e) {
      emit(ProfessionalAuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    ProfessionalAuthLogoutRequested event,
    Emitter<ProfessionalAuthState> emit,
  ) async {
    emit(ProfessionalAuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('professional_access_token');
      emit(ProfessionalAuthUnauthenticated());
    } catch (e) {
      emit(ProfessionalAuthError(e.toString()));
    }
  }

  Future<void> _onCheckRequested(
    ProfessionalAuthCheckRequested event,
    Emitter<ProfessionalAuthState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('professional_access_token');

    if (token != null) {
      emit(ProfessionalAuthAuthenticated(token));
    } else {
      emit(ProfessionalAuthUnauthenticated());
    }
  }

  Future<void> _onBiometricLogin(
    ProfessionalAuthBiometricLoginRequested event,
    Emitter<ProfessionalAuthState> emit,
  ) async {
    emit(ProfessionalAuthLoading());
    try {
      final response = await proApiClient.dio.post(
        ApiConstants.refreshToken,
        data: {'token': event.oldToken},
      );

      if (response.statusCode == 200 && response.data['access_token'] != null) {
        final token = response.data['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('professional_access_token', token);
        await BiometricService().updateProSecureTokenIfEnabled(token);
        emit(ProfessionalAuthAuthenticated(token));
        // Re-register FCM token after biometric token refresh.
        NotificationService.instance.sendTokenToApi(portal: Portal.professional);
      } else {
        emit(ProfessionalAuthError('Biometric login expired. Please log in manually.'));
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Token refresh failed';
      emit(ProfessionalAuthError('Biometric login failed: $msg'));
    } catch (e) {
      emit(ProfessionalAuthError('Unexpected error: $e'));
    }
  }
}
