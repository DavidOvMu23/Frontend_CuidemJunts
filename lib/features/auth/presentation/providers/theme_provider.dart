import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/preferences_provider.dart';

// Controla el tema de la aplicación (modo claro, oscuro o sistema).

// Este provider se encarga de:
// - Cargar la preferencia de tema guardada cuando arranca la app
// - Cambiar entre modo claro y oscuro
// - Guardar la preferencia para que se mantenga al cerrar la app
class ThemeNotifier extends Notifier<ThemeMode> {
  // Carga el tema guardado al iniciar la app.
  //
  // Si el usuario había elegido modo oscuro antes, se carga automáticamente.
  // Si es la primera vez que abre la app, por defecto usa el del sistema.
  @override
  ThemeMode build() {
    final prefsService = ref.watch(preferencesServiceProvider);
    // getTheme() devuelve null si es la primera vez, así que usamos ThemeMode.system
    return prefsService.getTheme() ?? ThemeMode.system;
  }

  // Cambia el tema a claro u oscuro según el valor que le pases.
  // Si el usuario toca el switch, forzamos Light o Dark.
  void setTheme(bool isDark) {
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;
    state = mode;

    // Guardamos la preferencia para la próxima vez
    final prefsService = ref.read(preferencesServiceProvider);
    prefsService.saveTheme(mode);
  }

  // Cambia entre modo claro y oscuro automáticamente.
  // Si está en modo claro, pasa a oscuro. Si está en oscuro, pasa a claro.
  // Si está en sistema, pasa a oscuro por defecto.
  void toggleTheme() {
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.dark;
    }

    final prefsService = ref.read(preferencesServiceProvider);
    prefsService.saveTheme(state);
  }
}

// Provider del tema de la app.
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
