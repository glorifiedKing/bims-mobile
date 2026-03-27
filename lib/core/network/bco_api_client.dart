import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../constants/api_constants.dart';
import '../routing/app_router.dart';

class BcoApiClient {
  late final Dio _dio;

  BcoApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.bcoBaseUrl,
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
          final token = prefs.getString('bco_access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('bco_access_token');
            AppRouter.rootNavigatorKey.currentContext?.go('/bco/login');
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
