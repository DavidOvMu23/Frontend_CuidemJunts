import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/preferences_provider.dart';

// ----- Provider para el tema de la app -----
// Este archivo gestiona el aspecto visual de la app: modo claro o modo oscuro.
// Recuerda la preferencia del usuario para mantenerla entre sesiones.

// ThemeNotifier es la clase que controla el tema activo de la app.
// ThemeMode puede ser: ThemeMode.light (claro), ThemeMode.dark (oscuro)
// o ThemeMode.system (sigue la configuración del sistema operativo del móvil).
class ThemeNotifier extends Notifier<ThemeMode> {
  // build() se ejecuta al crear el provider y define el tema inicial.
  @override
  ThemeMode build() {
    // Accedemos al servicio que lee las preferencias guardadas en el dispositivo
    final prefsService = ref.watch(preferencesServiceProvider);

    // getTheme() devuelve null si es la primera vez que se abre la app.
    // En ese caso usamos ThemeMode.system para respetar el tema del teléfono.
    return prefsService.getTheme() ?? ThemeMode.system;
  }

  // Cambia el tema a claro u oscuro según el interruptor (switch) de preferencias.
  // isDark = true → modo oscuro; isDark = false → modo claro.
  void setTheme(bool isDark) {
    // Convertimos el booleano en el valor de ThemeMode correspondiente
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;
    // Actualizamos el estado para que la app cambie de tema inmediatamente
    state = mode;

    // Guardamos la preferencia para que se recuerde la próxima vez que se abra la app
    final prefsService = ref.read(preferencesServiceProvider);
    prefsService.saveTheme(mode);
  }

  // Alterna automáticamente entre modo claro y oscuro.
  // Si está en modo oscuro, cambia a claro. Si está en claro (o sistema), cambia a oscuro.
  // Se usa cuando el usuario toca un botón de cambio rápido.
  void toggleTheme() {
    // Comprobamos el tema actual y cambiamos al contrario
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.dark;
    }

    // Guardamos la nueva preferencia para que persista al cerrar la app
    final prefsService = ref.read(preferencesServiceProvider);
    prefsService.saveTheme(state);
  }
}

// Provider del tema de la app.
// Cualquier widget que necesite saber si la app está en modo claro u oscuro
// puede leer este provider. Al cambiar el tema, todos se actualizan automáticamente.
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
