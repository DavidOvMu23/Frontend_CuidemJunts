// -------- SHARED PREFERENCES --------
// Este servicio se encarga de GUARDAR y CARGAR las preferencias del usuario
// en el almacenamiento local del dispositivo (como si fuera un archivo de configuración).

// ¿Dónde se guarda?
// - Android: En SharedPreferences (un archivo XML interno)
// - iOS/macOS: En UserDefaults (sistema de Apple)
// - Windows/Linux: En un archivo local
// - Web: En LocalStorage del navegador

// ¿Qué hace?
// - Guarda preferencias como el tema (oscuro/claro) o el idioma preferido.
// - Guarda el token JWT para mantener la sesión autenticada
// - Permite acceder a estas preferencias desde cualquier parte de la app.

// NOTA: el chatgpt nos ha ayudado con este archivo por que estube pegandome cabezazos
// para que funcionase correctamente y no lo consegía, pero una vez que corregió los errores
// ya todo tenía sentido, y al final no era tan dificil de entender. Lo que mas me costó hacer
// era hacer que otra página pudiera acceder a las preferencias y poder modificar ciertos elementos como el tema

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  // Estas son las "etiquetas" que usamos para identificar cada preferencia.
  static const String _keyThemeMode = 'themeMode';
  static const String _keyLanguageCode = 'languageCode';
  static const String _keyJwtToken = 'jwt_token';
  static const String _keyUserDni = 'user_dni';

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

  // -------- JWT TOKEN MANAGEMENT --------
  // Guarda el token JWT después de hacer login
  Future<void> saveToken(String token) async {
    await _prefs.setString(_keyJwtToken, token);
  }

  // Lee el token JWT guardado
  String? getToken() {
    return _prefs.getString(_keyJwtToken);
  }

  // Guarda el DNI del usuario autenticado
  Future<void> saveUserDni(String dni) async {
    await _prefs.setString(_keyUserDni, dni);
  }

  // Lee el DNI del usuario autenticado
  String? getUserDni() {
    return _prefs.getString(_keyUserDni);
  }

  // Limpia la sesión del usuario (logout)
  Future<void> clearSession() async {
    await _prefs.remove(_keyJwtToken);
    await _prefs.remove(_keyUserDni);
  }
}
