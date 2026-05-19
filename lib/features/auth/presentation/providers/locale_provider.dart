import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/preferences_provider.dart';

// ----- Provider de LocaleNotifier -----
// Este archivo gestiona el IDIOMA de toda la aplicación.
// Permite cambiar entre español ('es'), catalán ('ca') e inglés ('en').
// La elección del usuario se guarda para que se recuerde al cerrar y reabrir la app.

// LocaleNotifier es la clase que controla el idioma activo en la app.
// Un "Locale" en Flutter es simplemente el código del idioma, como 'es', 'ca' o 'en'.
class LocaleNotifier extends Notifier<Locale> {
  // build() se ejecuta al crear el provider y define el idioma inicial.
  @override
  Locale build() {
    // Accedemos al servicio que lee las preferencias guardadas en el dispositivo
    final prefsService = ref.watch(preferencesServiceProvider);

    // Intentamos leer el idioma que el usuario eligió la última vez
    final savedLanguage = prefsService.getLanguage();

    // Si hay un idioma guardado lo usamos; si es la primera vez, usamos español
    return savedLanguage != null ? Locale(savedLanguage) : const Locale('es');
  }

  // Cambia el idioma de toda la app al que se le indique.
  // Se llama cuando el usuario elige un idioma en la pantalla de preferencias.
  Future<void> setLocale(Locale locale) async {
    // Si el usuario eligió el mismo idioma que ya tenemos, no hacemos nada
    // para evitar guardar y redibujar sin necesidad
    if (state == locale) return;

    // Actualizamos el estado para que la app cambie de idioma inmediatamente
    state = locale;

    // Guardamos la elección del usuario para que se recuerde la próxima vez
    final prefsService = ref.read(preferencesServiceProvider);
    await prefsService.saveLanguage(locale.languageCode);
  }

  // Cambia el idioma a ESPAÑOL ('es')
  Future<void> setSpanish() async {
    await setLocale(const Locale('es'));
  }

  // Cambia el idioma a CATALÁN ('ca')
  Future<void> setCatalan() async {
    await setLocale(const Locale('ca'));
  }

  // Cambia el idioma a INGLÉS ('en')
  Future<void> setEnglish() async {
    await setLocale(const Locale('en'));
  }
}

// Provider del idioma de la app.
// Cualquier widget que necesite saber el idioma actual puede leer este provider.
// Cuando el idioma cambia, todos los widgets que lo usen se actualizan solos.
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
