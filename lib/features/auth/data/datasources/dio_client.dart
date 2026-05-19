import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/navigation/navigator_key.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/jwt_interceptor.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
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
      baseUrl: 'http://localhost:3000',
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
      // Limpiamos la sesión del usuario (borra el token guardado)
      await ref.read(authProvider.notifier).logout();
      // Navegamos a la pantalla de login eliminando todas las pantallas anteriores,
      // para que el usuario no pueda volver atrás con el botón "atrás"
      appNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    },
  ));

  // Devolvemos el Dio configurado para que toda la app lo pueda usar
  return dio;
});
