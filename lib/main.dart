import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/app/app.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/preferences_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/preferences_service.dart';

// -------- MAIN --------

// Punto de entrada de la aplicación
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Inicializamos el servicio de preferencias (donde guardamos configuración)
  final preferencesService = PreferencesService();
  await preferencesService.init();

  // Arrancamos la app con Riverpod
  // ProviderScope es necesario para que funcionen todos los providers
  runApp(
    ProviderScope(
      overrides: [
        preferencesServiceProvider.overrideWithValue(preferencesService),
      ],
      child: const App(),
    ),
  );
}
