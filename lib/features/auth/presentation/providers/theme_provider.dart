import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/preferences_provider.dart';

// Controla el tema de la aplicación (modo claro u oscuro).

// Este provider se encarga de:
// - Cargar la preferencia de tema guardada cuando arranca la app
// - Cambiar entre modo claro y oscuro
// - Guardar la preferencia para que se mantenga al cerrar la app
class ThemeNotifier extends Notifier<bool> {
  // Carga el tema guardado al iniciar la app.
  //
  // Si el usuario había elegido modo oscuro antes, se carga automáticamente.
  // Si es la primera vez que abre la app, por defecto usa modo claro (false).
  // Aunque edto da igual por que la app va a coger como color predeterminado el del sistema operativo
  @override
  bool build() {
    final prefsService = ref.watch(preferencesServiceProvider);
    // getTheme() devuelve null si es la primera vez, así que usamos ?? false
    return prefsService.getTheme() ?? false;
  }

  // Cambia el tema a claro u oscuro según el valor que le pases.
  void setTheme(bool isDark) {
    state = isDark;

    // Guardamos la preferencia para la próxima vez
    final prefsService = ref.read(preferencesServiceProvider);
    prefsService.saveTheme(isDark);
  }

  // Cambia entre modo claro y oscuro automáticamente.
  // Si está en modo claro, pasa a oscuro. Si está en oscuro, pasa a claro.
  // Útil para botones de "cambiar tema" sin tener que comprobar el estado actual.
  void toggleTheme() {
    state = !state;

    final prefsService = ref.read(preferencesServiceProvider);
    prefsService.saveTheme(state);
  }
}

// Provider del tema de la app.
final themeProvider = NotifierProvider<ThemeNotifier, bool>(ThemeNotifier.new);
