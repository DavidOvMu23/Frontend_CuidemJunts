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

    // Si existe un token, agregarlo al header Authorization
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Si recibimos un 401 (Unauthorized), significa que el token expiró o es inválido
    if (err.response?.statusCode == 401) {
      // Aquí podríamos limpiar la sesión y redirigir al login
      // Por ahora solo dejamos que se propague el error
    }

    super.onError(err, handler);
  }
}
