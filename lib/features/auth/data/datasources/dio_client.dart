import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/jwt_interceptor.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/preferences_provider.dart';

// -------- DIO CLIENT CON JWT INTERCEPTOR --------
// Provider que crea una instancia de Dio con el interceptor JWT configurado.
// Esto asegura que todas las peticiones HTTP incluyan el token JWT automáticamente.

final dioClientProvider = Provider<Dio>((ref) {
  final preferencesService = ref.watch(preferencesServiceProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:3000',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Agregar el interceptor JWT
  dio.interceptors.add(JwtInterceptor(preferencesService: preferencesService));

  return dio;
});
