import 'package:dio/dio.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/preferences_service.dart';

class JwtInterceptor extends Interceptor {
  final PreferencesService preferencesService;
  final Future<void> Function()? onUnauthorized;

  JwtInterceptor({required this.preferencesService, this.onUnauthorized});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Obtener el token guardado
    final token = preferencesService.getToken();

    // Depuración: imprimir información útil para el desarrollo (Chrome console)
    try {
      print('--> HTTP ${options.method} ${options.uri}');
      print('    Token presente: ${token != null}');
      print('    Authorization header antes: ${options.headers["Authorization"]}');
      print('    Body: ${options.data}');
    } catch (e) {
      // No bloquear la petición por fallos de logging
    }

    // Si existe un token, agregarlo al header Authorization
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    try {
      print('    Authorization header después: ${options.headers["Authorization"]}');
      print('<-- end HTTP ${options.method} ${options.uri}');
    } catch (e) {}

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      onUnauthorized?.call();
    }

    try {
      print('DIO ERROR ${err.type} ${err.response?.statusCode} ${err.requestOptions.uri}');
      print('Response data: ${err.response?.data}');
    } catch (e) {}

    super.onError(err, handler);
  }
}
