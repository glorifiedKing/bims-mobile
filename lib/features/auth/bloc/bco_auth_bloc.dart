import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/bco_api_client.dart';
import '../models/bco_user.dart';
import 'bco_auth_event.dart';
import 'bco_auth_state.dart';

class BcoAuthBloc extends Bloc<BcoAuthEvent, BcoAuthState> {
  final Dio baseDio;
  final SharedPreferences prefs;
  final BcoApiClient bcoApiClient;

  Dio get bcoDio => bcoApiClient.dio;

  BcoAuthBloc({required this.baseDio, required this.prefs, required this.bcoApiClient})
    : super(BcoAuthInitial()) {

    on<BcoAuthCheckRequested>(_onAuthCheck);
    on<BcoAuthLoginRequested>(_onLogin);
    on<BcoAuthLogoutRequested>(_onLogout);
  }

  void _onAuthCheck(BcoAuthCheckRequested event, Emitter<BcoAuthState> emit) {
    final token = prefs.getString('bco_access_token');
    final userStr = prefs.getString('bco_user_data');
    if (token != null && userStr != null) {
      try {
        final user = BcoUser.fromJson(jsonDecode(userStr));
        emit(BcoAuthAuthenticated(token, user));
      } catch (e) {
        emit(BcoAuthUnauthenticated());
      }
    } else {
      emit(BcoAuthUnauthenticated());
    }
  }

  Future<void> _onLogin(
    BcoAuthLoginRequested event,
    Emitter<BcoAuthState> emit,
  ) async {
    emit(BcoAuthLoading());
    try {
      final response = await bcoDio.post(
        ApiConstants.bcoLogin,
        data: {'email': event.email, 'password': event.password},
      );

      if (response.statusCode == 200 && response.data['access_token'] != null) {
        final token = response.data['access_token'];
        final userJson = response.data['user'];
        final user = BcoUser.fromJson(userJson);
        
        // Using distinct keys for BCO tokens and user data
        await prefs.setString('bco_access_token', token);
        await prefs.setString('bco_user_data', jsonEncode(userJson));
        emit(BcoAuthAuthenticated(token, user));
      } else {
        emit(BcoAuthError('Login failed: Invalid credentials'));
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data['message'] ?? e.message ?? 'An error occurred';
      emit(BcoAuthError('Login error: $msg'));
    } catch (e) {
      emit(BcoAuthError('Unexpected error: $e'));
    }
  }

  Future<void> _onLogout(
    BcoAuthLogoutRequested event,
    Emitter<BcoAuthState> emit,
  ) async {
    emit(BcoAuthLoading());
    await prefs.remove('bco_access_token');
    await prefs.remove('bco_user_data');
    emit(BcoAuthUnauthenticated());
  }
}
