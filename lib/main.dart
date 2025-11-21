import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/app/app.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/preferences_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/preferences_service.dart';

// Punto de entrada de la aplicación.
// Esta función se ejecuta cuando abres la app. Aquí hacemos la configuración
// inicial antes de mostrar nada en pantalla.
void main() async {
  // Necesario para usar plugins de Flutter antes de runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos el servicio de preferencias (donde guardamos configuración)
  final preferencesService = PreferencesService();
  await preferencesService.init();

  // Arrancamos la app con Riverpod
  // ProviderScope es necesario para que funcionen todos los providers
  runApp(
    ProviderScope(
      // Aquí usamos el servicio de preferencias para que todos
      // los providers puedan usarlo
      overrides: [
        preferencesServiceProvider.overrideWithValue(preferencesService),
      ],
      child: const App(),
    ),
  );
}
