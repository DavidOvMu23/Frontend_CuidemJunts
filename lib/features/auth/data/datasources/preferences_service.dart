import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// -------- SERVICIO DE PREFERENCIAS LOCALES --------
// Este servicio se encarga de GUARDAR y CARGAR las preferencias del usuario
// en el almacenamiento local del dispositivo (como si fuera un archivo de configuración).

// ¿Dónde se guarda?
// - Android: En SharedPreferences (un archivo XML interno)
// - iOS/macOS: En UserDefaults (sistema de Apple)
// - Windows/Linux: En un archivo local
// - Web: En LocalStorage del navegador

class PreferencesService {
  // Estas son las "etiquetas" que usamos para identificar cada preferencia.
  // Es como poner un nombre a cada cajón donde guardamos información.
  static const String _keyThemeMode = 'themeMode';
  static const String _keyLanguageCode = 'languageCode';

  // Esta variable guardará la conexión al sistema de almacenamiento local.
  // La marcamos como "late" porque se inicializará después (en init()).
  late SharedPreferences _prefs;

  // Esta función DEBE llamarse al inicio de la app, antes de usar el servicio.
  // Conecta con el sistema de almacenamiento del dispositivo.
  Future<void> init() async {
    // getInstance() abre la "base de datos" de preferencias.
    // Es como abrir el archivo donde guardamos la configuración.
    _prefs = await SharedPreferences.getInstance();
  }

  // Guarda el modo de tema preferido (system, light, dark).
  Future<void> saveTheme(ThemeMode mode) async {
    await _prefs.setString(_keyThemeMode, mode.name);
  }

  // Lee el tema guardado anteriormente.
  // Retorna null si no hay preferencia guardada (para usar default/system).
  ThemeMode? getTheme() {
    final themeName = _prefs.getString(_keyThemeMode);
    if (themeName == null) return null;

    // Convertimos el string guardado de vuelta a ThemeMode
    try {
      return ThemeMode.values.firstWhere((e) => e.name == themeName);
    } catch (_) {
      return null;
    }
  }

  // Guarda el idioma preferido por el usuario
  Future<void> saveLanguage(String languageCode) async {
    // setString() guarda un texto con la clave especificada.
    // Es como escribir: "languageCode = es"
    await _prefs.setString(_keyLanguageCode, languageCode);
  }

  // Lee el idioma guardado anteriormente.
  String? getLanguage() {
    // getString() lee el texto guardado con la clave _keyLanguageCode.
    // Si no existe, devuelve null.
    return _prefs.getString(_keyLanguageCode);
  }
}
