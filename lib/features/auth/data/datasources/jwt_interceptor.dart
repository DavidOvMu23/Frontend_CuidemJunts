import 'package:dio/dio.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/preferences_service.dart';

// -------- JWT INTERCEPTOR --------
// Un interceptor es como un "guardia de seguridad" que revisa cada petición
// que la app envía al servidor ANTES de que salga, y cada respuesta que llega ANTES
// de que la app la procese.
//
// Este interceptor hace dos cosas:
// 1. Antes de enviar cualquier petición: añade el token JWT en la cabecera
//    para que el servidor sepa que el usuario está autenticado.
// 2. Cuando llega una respuesta de error 401 (sesión expirada o no autorizada):
//    llama a la función onUnauthorized para cerrar la sesión y redirigir al login.
class JwtInterceptor extends Interceptor {
  // Servicio de preferencias: lo usamos para leer el token JWT guardado en el dispositivo
  final PreferencesService preferencesService;

  // Función que se llama cuando el servidor responde con un error 401 (no autorizado).
  // Es opcional porque puede haber contextos donde no se necesite redirigir.
  final Future<void> Function()? onUnauthorized;

  JwtInterceptor({required this.preferencesService, this.onUnauthorized});

  // onRequest: se ejecuta automáticamente ANTES de enviar cada petición al servidor.
  // Su función es añadir el token de seguridad en la cabecera "Authorization".
  // Así el servidor sabe quién hace la petición y si tiene permiso para hacerla.
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Leemos el token JWT guardado en el dispositivo después del último login
    final token = preferencesService.getToken();

    // Si hay token guardado, lo añadimos a la cabecera de la petición
    // El formato "Bearer <token>" es el estándar para autenticación JWT
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Dejamos que la petición continúe su camino hacia el servidor
    super.onRequest(options, handler);
  }

  // onError: se ejecuta automáticamente cuando el servidor responde con un error.
  // Aquí solo nos interesa el error 401, que significa que la sesión expiró
  // o que el token ya no es válido.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Si el servidor devuelve 401, es que el usuario ya no está autorizado
    // (el token expiró o fue revocado), así que cerramos la sesión
    if (err.response?.statusCode == 401) {
      // Llamamos a la función de cierre de sesión y redirección al login
      onUnauthorized?.call();
    }

    // Dejamos que el error continúe para que otros partes de la app puedan manejarlo
    super.onError(err, handler);
  }
}
