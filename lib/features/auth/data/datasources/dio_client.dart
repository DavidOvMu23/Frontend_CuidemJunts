import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/navigation/navigator_key.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/jwt_interceptor.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/preferences_provider.dart';

// -------- DIO CLIENT PROVIDER --------
// Dio es la librería que usamos para hacer todas las peticiones HTTP al servidor
// (obtener listas, crear registros, actualizar, borrar, etc.).
//
// Este provider crea y configura una única instancia de Dio que toda la app comparte.
// La configura con la URL del servidor, los tiempos de espera y el interceptor de seguridad.
//
// Un "provider" en Riverpod es como una caja que guarda un objeto y lo pone a disposición
// de toda la aplicación sin tener que pasarlo manualmente de pantalla en pantalla.
final dioClientProvider = Provider<Dio>((ref) {
  // Obtenemos el servicio de preferencias para poder leer el token JWT guardado
  final preferencesService = ref.watch(preferencesServiceProvider);

  // Creamos la instancia de Dio con la configuración base para todas las peticiones
  final dio = Dio(
    BaseOptions(
      // URL del servidor al que se conectará la app
      // En producción habría que cambiar esto por la URL real
      baseUrl: 'http://cuidemnosenxarxa.local:3000',
      // Tiempo máximo de espera para conectar con el servidor (10 segundos)
      connectTimeout: const Duration(seconds: 10),
      // Tiempo máximo de espera para recibir la respuesta completa (10 segundos)
      receiveTimeout: const Duration(seconds: 10),
      // Indicamos al servidor que siempre enviamos y esperamos datos en formato JSON
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Añadimos el interceptor JWT: se ejecuta automáticamente antes de cada petición
  // para añadir el token de seguridad en la cabecera.
  // Si el servidor responde con un error 401 (sesión expirada), cierra la sesión
  // y redirige al usuario a la pantalla de login.
  dio.interceptors.add(JwtInterceptor(
    preferencesService: preferencesService,
    onUnauthorized: () async {
      // Guard: si ya estamos sin sesión, otra petición 401 ya hizo el logout.
      // No repetimos el trabajo porque podríamos pisar lo que el usuario está
      // escribiendo en LoginPage.
      if (!ref.read(authProvider).isAuthenticated) {
        return;
      }
      // Limpiamos la sesión: _AuthGate (la home route) detecta el cambio de
      // auth state y muestra LoginPage automáticamente.
      await ref.read(authProvider.notifier).logout();
      // Popeamos las sub-rutas que estuvieran encima del home (creación de
      // usuario, detalle, etc.) para volver al _AuthGate ya en modo LoginPage.
      // IMPORTANTE: NO usamos pushAndRemoveUntil(LoginPage(), (r)=>false)
      // porque eso eliminaría _AuthGate del stack y el próximo login no podría
      // navegar a SupervisorShellPage (state cambia pero nadie reacciona).
      appNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    },
  ));

  // Devolvemos el Dio configurado para que toda la app lo pueda usar
  return dio;
});
