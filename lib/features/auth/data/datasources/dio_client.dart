import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/navigation/navigator_key.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/jwt_interceptor.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/preferences_provider.dart';

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

  dio.interceptors.add(JwtInterceptor(
    preferencesService: preferencesService,
    onUnauthorized: () async {
      await ref.read(authProvider.notifier).logout();
      appNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    },
  ));

  return dio;
});
