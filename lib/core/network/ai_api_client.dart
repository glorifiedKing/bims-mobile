import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class AiApiClient {
  late final Dio _dio;

  AiApiClient({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConstants.aiBaseUrl,
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 60),
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
          // Use professional BIMS token for autologin into AI backend
          final token = prefs.getString('professional_access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
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
                  allErrors.addAll(value.map((item) => item.toString()));
                } else if (key == 'message' &&
                    value is String &&
                    allErrors.isEmpty) {
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
