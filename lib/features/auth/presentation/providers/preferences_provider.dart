import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/preferences_service.dart';
// ----- Provider de PreferencesService -----

// Este provider sirve para que cualquier widget pueda acceder al servicio de preferencias
// sin tener que pasar el servicio manualmente por todos los widgets.

// ¿Por qué usar un provider?
// - Riverpod se encarga de crear y mantener la instancia
// - Podemos acceder al servicio desde cualquier widget sin pasarlo manualmente

// IMPORTANTE: Este provider asume que el servicio YA está inicializado
// en main() antes de crear el ProviderScope.
// Si no, esto causaría un error.
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  throw UnimplementedError(
    'PreferencesService debe ser inicializado en main() y sobreescrito con overrides',
  );
});
