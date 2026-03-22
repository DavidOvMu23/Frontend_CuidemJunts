import 'package:dio/dio.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/preferences_service.dart';

// -------- HTTP INTERCEPTOR CON JWT --------
// Este interceptor se encarga de agregar el token JWT a todas las peticiones HTTP
// de manera automática. Así no tenemos que agregarlo manualmente en cada llamada.

class JwtInterceptor extends Interceptor {
  final PreferencesService preferencesService;

  JwtInterceptor({required this.preferencesService});

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
    // Si recibimos un 401 (Unauthorized), significa que el token expiró o es inválido
    if (err.response?.statusCode == 401) {
      // Aquí podríamos limpiar la sesión y redirigir al login
      // Por ahora solo dejamos que se propague el error
    }

    // Depuración de errores HTTP
    try {
      print('DIO ERROR ${err.type} ${err.response?.statusCode} ${err.requestOptions.uri}');
      print('Response data: ${err.response?.data}');
    } catch (e) {}

    super.onError(err, handler);
  }
}
