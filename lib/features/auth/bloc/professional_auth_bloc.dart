import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'professional_auth_event.dart';
import 'professional_auth_state.dart';

class ProfessionalAuthBloc
    extends Bloc<ProfessionalAuthEvent, ProfessionalAuthState> {
  final ApiClient apiClient;

  ProfessionalAuthBloc({required this.apiClient})
    : super(ProfessionalAuthInitial()) {
    on<ProfessionalAuthLoginRequested>(_onLoginRequested);
    on<ProfessionalAuthLogoutRequested>(_onLogoutRequested);
    on<ProfessionalAuthCheckRequested>(_onCheckRequested);
  }

  Future<void> _onLoginRequested(
    ProfessionalAuthLoginRequested event,
    Emitter<ProfessionalAuthState> emit,
  ) async {
    emit(ProfessionalAuthLoading());
    try {
      // Mock login for now
      await Future.delayed(const Duration(seconds: 1));
      if (event.identifier.isNotEmpty && event.password.isNotEmpty) {
        final mockToken =
            'mock_professional_token_${DateTime.now().millisecondsSinceEpoch}';
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('professional_access_token', mockToken);
        emit(ProfessionalAuthAuthenticated(mockToken));
      } else {
        emit(ProfessionalAuthError('Invalid credentials'));
      }

      /* Real API call when ready
      final response = await apiClient.dio.post(
        ApiConstants.professionalLogin,
        data: {
          'identifier': event.identifier,
          'password': event.password,
        },
      );
      
      final token = response.data['access_token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('professional_access_token', token);
      
      emit(ProfessionalAuthAuthenticated(token));
      */
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
}
