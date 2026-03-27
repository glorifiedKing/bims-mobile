import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Dio dio;
  final SharedPreferences prefs;

  AuthBloc({required this.dio, required this.prefs}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheck);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthRegisterRequested>(_onRegister);
  }

  void _onAuthCheck(AuthCheckRequested event, Emitter<AuthState> emit) {
    final token = prefs.getString('access_token');
    if (token != null) {
      emit(AuthAuthenticated(token));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final data = event.type == 'email'
          ? {'email': event.identifier, 'password': event.password, 'type': 'email'}
          : {'phone': event.identifier, 'password': event.password, 'type': 'phone'};

      final response = await dio.post(
        ApiConstants.login,
        data: data,
      );

      if (response.statusCode == 200 && response.data['access_token'] != null) {
        final token = response.data['access_token'];
        await prefs.setString('access_token', token);
        emit(AuthAuthenticated(token));
      } else {
        emit(AuthError('Login failed: Invalid credentials'));
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data['message'] ?? e.message ?? 'An error occurred';
      emit(AuthError('Login error: $msg'));
    } catch (e) {
      emit(AuthError('Unexpected error: $e'));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await prefs.remove('access_token');
    emit(AuthUnauthenticated());
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await dio.post(
        ApiConstants.createAccount,
        data: event.data,
      );
      if (response.statusCode == 201) {
        // Registration successful
        emit(AuthUnauthenticated()); // Need to login next
      } else {
        emit(AuthError('Registration failed'));
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data['message'] ?? e.message ?? 'Registration Error';
      emit(AuthError('Error: $msg'));
    } catch (e) {
      emit(AuthError('Unexpected err: $e'));
    }
  }
}
