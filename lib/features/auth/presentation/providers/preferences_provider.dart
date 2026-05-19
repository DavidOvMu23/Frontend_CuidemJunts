import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/preferences_service.dart';

// ----- Provider de PreferencesService -----
// PreferencesService es el servicio que guarda datos pequeños en el dispositivo
// (idioma, tema claro/oscuro, token de sesión, etc.).
// Estos datos persisten aunque el usuario cierre la app.

// Este provider sirve para que cualquier widget pueda acceder al servicio de preferencias
// sin tener que pasarlo manualmente de pantalla en pantalla.

// ¿Por qué usar un provider?
// - Riverpod se encarga de crear y mantener la instancia
// - Podemos acceder al servicio desde cualquier widget sin pasarlo manualmente

// IMPORTANTE: Este provider lanza un error intencionalmente porque
// necesita ser inicializado ANTES de arrancar la app (en main.dart).
// En main() se crea la instancia real y se "inyecta" aquí mediante overrides.
// Si no se hace así, la app crashearía porque SharedPreferences necesita
// inicializarse de forma asíncrona antes de usarse.
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  throw UnimplementedError(
    'PreferencesService debe ser inicializado en main() y sobreescrito con overrides',
  );
});
