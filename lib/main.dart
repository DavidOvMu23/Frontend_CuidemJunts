// Paquete principal de Flutter: necesario para construir cualquier app
import 'package:flutter/material.dart';
// Riverpod: el sistema de gestión de estado que usamos para compartir datos entre pantallas
import 'package:flutter_riverpod/flutter_riverpod.dart';
// El widget raíz de la app (ver app.dart)
import 'package:frontend_cuidemjunts/app/app.dart';
// Provider que expone el servicio de preferencias al resto de la app
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/preferences_provider.dart';
// Servicio que guarda datos del usuario en el dispositivo (tema, idioma, token…)
import 'package:frontend_cuidemjunts/features/auth/data/datasources/preferences_service.dart';

// -------- MAIN --------

// Punto de entrada de la aplicación: Flutter siempre busca esta función para arrancar
void main() async {
  // Necesario antes de cualquier llamada asíncrona al arrancar Flutter
  // Sin esto, las llamadas a servicios nativos pueden fallar
  WidgetsFlutterBinding.ensureInitialized();

  // Creamos el servicio de preferencias, que guarda configuración en el dispositivo
  // (tema claro/oscuro, idioma seleccionado, token de sesión, etc.)
  final preferencesService = PreferencesService();
  // Lo inicializamos de forma asíncrona antes de arrancar la app
  // para que los datos ya estén disponibles cuando se dibuje la primera pantalla
  await preferencesService.init();

  // Arrancamos la app con Riverpod
  // ProviderScope es el contenedor global de todos los providers; sin él ninguno funciona
  runApp(
    ProviderScope(
      // Sustituimos el provider vacío por la instancia real ya inicializada
      // Así toda la app puede leer las preferencias guardadas desde el primer instante
      overrides: [
        preferencesServiceProvider.overrideWithValue(preferencesService),
      ],
      // App es el widget raíz que configura tema, idioma y navegación
      child: const App(),
    ),
  );
}
