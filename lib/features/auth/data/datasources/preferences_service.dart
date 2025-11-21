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
  static const String _keyIsDarkMode = 'isDarkMode';
  static const String _keyLanguageCode = 'languageCode';

  // Estas claves guardan información sobre si el usuario está logueado.
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserToken = 'userToken';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyUserData =
      'userData'; // Datos completos del usuario (JSON)

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

  // Guarda si el usuario prefiere el modo oscuro o claro.
  Future<void> saveTheme(bool isDark) async {
    // setBool() guarda un valor booleano (true/false) con la clave especificada.
    // Es como escribir en un archivo: "isDarkMode = true"
    await _prefs.setBool(_keyIsDarkMode, isDark);
  }

  // Lee el tema guardado anteriormente.
  bool? getTheme() {
    return _prefs.getBool(_keyIsDarkMode);
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

  // Guarda TODA la información de la sesión cuando el usuario hace login.
  // Esto incluye: token, email y datos completos del usuario.
  Future<void> saveSession({
    required String token,
    required String email,
    String? userData,
  }) async {
    // Guardamos que el usuario SÍ está logueado
    await _prefs.setBool(_keyIsLoggedIn, true);

    // Guardamos el token de autenticación
    await _prefs.setString(_keyUserToken, token);

    // Guardamos el email del usuario
    await _prefs.setString(_keyUserEmail, email);

    // Si hay datos adicionales del usuario, los guardamos también
    if (userData != null) {
      await _prefs.setString(_keyUserData, userData);
    }
  }

  // Comprueba si el usuario tiene una sesión iniciada.
  bool isLoggedIn() {
    // Leemos el valor de _keyIsLoggedIn.
    // Si es null (nunca se guardó), devolvemos false por defecto.
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Lee el token de autenticación guardado.

  // Retorna:
  // - El token si existe
  // - null si no hay sesión activa
  String? getToken() {
    return _prefs.getString(_keyUserToken);
  }

  // Lee el email del usuario guardado.

  // Retorna:
  // - El email si existe
  // - null si no hay sesión activa
  String? getUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  // Lee los datos completos del usuario guardados en formato JSON.

  // Retorna:
  // - Los datos en formato String (JSON) si existen
  // - null si no hay datos guardados

  String? getUserData() {
    return _prefs.getString(_keyUserData);
  }

  // Borra TODA la información de la sesión del usuario.
  // Esto hace que la próxima vez tenga que volver a hacer login.
  Future<void> logout() async {
    // Marcamos que ya NO está logueado
    await _prefs.setBool(_keyIsLoggedIn, false);

    // Borramos el token
    await _prefs.remove(_keyUserToken);

    // Borramos el email
    await _prefs.remove(_keyUserEmail);

    // Borramos los datos del usuario
    await _prefs.remove(_keyUserData);

    // NOTA: NO borramos el tema ni el idioma, esas preferencias se mantienen
    // aunque el usuario cierre sesión.
  }
}
