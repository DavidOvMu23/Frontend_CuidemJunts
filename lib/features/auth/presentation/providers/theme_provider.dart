import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/preferences_provider.dart';

// ----- Provider para el tema de la app -----

// Este provider se encarga de:
// - Cargar la preferencia de tema guardada cuando arranca la app
// - Cambiar entre modo claro y oscuro
// - Guardar la preferencia para que se mantenga al cerrar la app

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Le decimos a Flutter que use el tema que le pasamos
    final prefsService = ref.watch(preferencesServiceProvider);

    // getTheme() devuelve null si es la primera vez, así que usamos ThemeMode.system
    return prefsService.getTheme() ??
        ThemeMode.system; // esto me lo hizo el chatgpt
  }

  // Cambia el tema a claro u oscuro según el valor que le pases.
  // Si el usuario toca el switch que hay en preferencias, forzamos Light o Dark.
  void setTheme(bool isDark) {
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;
    state = mode;

    // Guardamos la preferencia para la próxima vez que se abra la app
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

    // Guardamos la preferencia para la próxima vez que se abra la app
    final prefsService = ref.read(preferencesServiceProvider);
    prefsService.saveTheme(state);
  }
}

// Provider del tema de la app.
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
