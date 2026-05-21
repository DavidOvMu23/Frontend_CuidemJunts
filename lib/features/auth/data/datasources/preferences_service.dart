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
  // Claves adicionales del usuario logueado, para poder restaurar la sesión
  // tras un refresco del navegador sin tener que pedir credenciales otra vez.
  static const String _keyUserId = 'user_id';
  static const String _keyUserNombre = 'user_nombre';
  static const String _keyUserRol = 'user_rol';
  static const String _keyUserNia = 'user_nia';
  static const String _keyUserGrupoId = 'user_grupo_id';

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

  // Guarda los datos completos del usuario logueado para poder restaurar la
  // sesión tras un refresco del navegador. Pasamos los campos como nulos para
  // borrarlos sin tener que llamar a clearSession.
  Future<void> saveUserSession({
    required int id,
    required String correo,
    String? nombre,
    String? rol,
    String? nia,
    int? grupoId,
  }) async {
    await _prefs.setInt(_keyUserId, id);
    await _prefs.setString(_keyUserDni, correo);
    if (nombre != null) {
      await _prefs.setString(_keyUserNombre, nombre);
    } else {
      await _prefs.remove(_keyUserNombre);
    }
    if (rol != null) {
      await _prefs.setString(_keyUserRol, rol);
    } else {
      await _prefs.remove(_keyUserRol);
    }
    if (nia != null) {
      await _prefs.setString(_keyUserNia, nia);
    } else {
      await _prefs.remove(_keyUserNia);
    }
    if (grupoId != null) {
      await _prefs.setInt(_keyUserGrupoId, grupoId);
    } else {
      await _prefs.remove(_keyUserGrupoId);
    }
  }

  // Lee los datos del usuario logueado guardados previamente; devuelve null
  // en cada campo si no hay sesión almacenada.
  ({int? id, String? correo, String? nombre, String? rol, String? nia, int? grupoId})
      getUserSession() {
    return (
      id: _prefs.getInt(_keyUserId),
      correo: _prefs.getString(_keyUserDni),
      nombre: _prefs.getString(_keyUserNombre),
      rol: _prefs.getString(_keyUserRol),
      nia: _prefs.getString(_keyUserNia),
      grupoId: _prefs.getInt(_keyUserGrupoId),
    );
  }

  // Limpia la sesión del usuario (logout). Borra todos los campos relacionados
  // con la sesión, no solo el token.
  Future<void> clearSession() async {
    await _prefs.remove(_keyJwtToken);
    await _prefs.remove(_keyUserDni);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserNombre);
    await _prefs.remove(_keyUserRol);
    await _prefs.remove(_keyUserNia);
    await _prefs.remove(_keyUserGrupoId);
  }
}
