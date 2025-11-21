import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/preferences_service.dart';

// Este provider crea UNA SOLA INSTANCIA de PreferencesService para toda la app. (Para entenderlo nos hemos ayudado del chatgpt)
// Es como tener un objeto global al que todos pueden acceder.

// ¿Por qué usar un provider en vez de crear el servicio directamente?
// - Riverpod se encarga de crear y mantener la instancia
// - Podemos acceder al servicio desde cualquier widget sin pasarlo manualmente
// - Es fácil de testear (podemos reemplazarlo en tests)
// - Se inicializa de forma lazy (solo cuando se necesita)

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  // IMPORTANTE: Este provider asume que el servicio YA está inicializado
  // en main() antes de crear el ProviderScope.
  // Si no, esto causaría un error.
  throw UnimplementedError(
    'PreferencesService debe ser inicializado en main() y sobreescrito con overrides',
  );
});
