import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bims_mobile_general/features/auth/bloc/auth_bloc.dart';
import 'package:bims_mobile_general/features/auth/bloc/auth_event.dart';
import '../constants/api_constants.dart';
import '../routing/app_router.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.clientBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final context = AppRouter.rootNavigatorKey.currentContext;
            if (context != null) {
              context.read<AuthBloc>().add(AuthLogoutRequested());
              context.go('/client/login');
            } else {
              // Fallback
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('access_token');
              AppRouter.rootNavigatorKey.currentContext?.go('/client/login');
            }
          }
          if (e.response?.statusCode == 422) {
            final data = e.response?.data;

            if (data is Map<String, dynamic>) {
              final Map<String, dynamic> errorMap =
                  (data.containsKey('errors') && data['errors'] is Map)
                  ? data['errors']
                  : data;

              final List<String> allErrors = [];

              errorMap.forEach((key, value) {
                if (value is List) {
                  allErrors.addAll(value.map((e) => e.toString()));
                } else if (key == 'message' &&
                    value is String &&
                    allErrors.isEmpty) {
                  // If it's just a top-level message and no list errors found yet
                  allErrors.add(value);
                }
              });

              if (allErrors.isNotEmpty) {
                final String cleanMessage = allErrors.join('\n');
                return handler.next(e.copyWith(error: cleanMessage));
              }
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
