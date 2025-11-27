import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/preferences_provider.dart';

// ----- Provider de LocaleNotifier -----

// Este provider se encarga de:
// - Cargar el idioma guardado cuando arranca la app
// - Cambiar entre español, catalán e inglés
// - Guardar la preferencia para que se mantenga al cerrar la app
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    // Leemos el servicio de preferencias
    final prefsService = ref.watch(preferencesServiceProvider);

    // Intentamos cargar el idioma guardado
    final savedLanguage = prefsService.getLanguage();

    // Si hay idioma guardado lo usamos, si no, español por defecto
    return savedLanguage != null ? Locale(savedLanguage) : const Locale('es');
  }

  // Cambia el idioma de la app.
  Future<void> setLocale(Locale locale) async {
    // Si ya estamos en ese idioma, no hacemos nada
    if (state == locale) return;

    // Hacemos que la ui muestre el nuevo idioma
    state = locale;

    // Guardamos la preferencia para la próxima vez
    final prefsService = ref.read(preferencesServiceProvider);
    await prefsService.saveLanguage(locale.languageCode);
  }

  // Atajos para cambiar de idioma rápidamente (Mejoras que nos ha dado el chat gpt)
  Future<void> setSpanish() async {
    await setLocale(const Locale('es'));
  }

  Future<void> setCatalan() async {
    await setLocale(const Locale('ca'));
  }

  Future<void> setEnglish() async {
    await setLocale(const Locale('en'));
  }
}

// Provider del idioma de la app.
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
