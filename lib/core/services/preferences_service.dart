import 'package:shared_preferences/shared_preferences.dart';

// -------- SERVICIO DE PREFERENCIAS LOCALES --------
// Este servicio se encarga de GUARDAR y CARGAR las preferencias del usuario
// en el almacenamiento local del dispositivo (como si fuera un archivo de configuración).
//
// ¿Qué guardamos?
// - El tema preferido (claro u oscuro)
// - El idioma preferido (español, catalán, inglés)
//
// ¿Dónde se guarda?
// - Android: En SharedPreferences (un archivo XML interno)
// - iOS/macOS: En UserDefaults (sistema de Apple)
// - Windows/Linux: En un archivo local
// - Web: En LocalStorage del navegador
//
// Lo mejor: ¡No tienes que preocuparte de dónde! SharedPreferences lo hace automáticamente.

class PreferencesService {
  // -------- CLAVES PARA GUARDAR LOS DATOS --------
  // Estas son las "etiquetas" que usamos para identificar cada preferencia.
  // Es como poner un nombre a cada cajón donde guardamos información.

  static const String _keyIsDarkMode = 'isDarkMode'; // Clave para el tema
  static const String _keyLanguageCode = 'languageCode'; // Clave para el idioma

  // -------- CLAVES PARA LA SESIÓN DEL USUARIO --------
  // Estas claves guardan información sobre si el usuario está logueado.

  static const String _keyIsLoggedIn = 'isLoggedIn'; // ¿Está logueado?
  static const String _keyUserToken = 'userToken'; // Token de autenticación
  static const String _keyUserEmail = 'userEmail'; // Email del usuario
  static const String _keyUserData =
      'userData'; // Datos completos del usuario (JSON)

  // -------- INSTANCIA DE SHAREDPREFERENCES --------
  // Esta variable guardará la conexión al sistema de almacenamiento local.
  // La marcamos como "late" porque se inicializará después (en init()).
  late SharedPreferences _prefs;

  // -------- INICIALIZACIÓN --------
  // Esta función DEBE llamarse al inicio de la app, antes de usar el servicio.
  // Conecta con el sistema de almacenamiento del dispositivo.
  //
  // ¿Por qué es async?
  // Porque acceder al almacenamiento puede tardar un poquito (milisegundos),
  // y no queremos bloquear la app mientras tanto.
  Future<void> init() async {
    // getInstance() abre la "base de datos" de preferencias.
    // Es como abrir el archivo donde guardamos la configuración.
    _prefs = await SharedPreferences.getInstance();
  }

  // -------- GUARDAR EL TEMA --------
  // Guarda si el usuario prefiere el modo oscuro o claro.
  //
  // Parámetros:
  // - isDark: true = modo oscuro, false = modo claro
  //
  // Ejemplo de uso:
  // await preferencesService.saveTheme(true); // Guarda modo oscuro
  Future<void> saveTheme(bool isDark) async {
    // setBool() guarda un valor booleano (true/false) con la clave especificada.
    // Es como escribir en un archivo: "isDarkMode = true"
    await _prefs.setBool(_keyIsDarkMode, isDark);
  }

  // -------- CARGAR EL TEMA --------
  // Lee el tema guardado anteriormente.
  //
  // Retorna:
  // - true si el usuario prefiere modo oscuro
  // - false si prefiere modo claro
  // - null si nunca se ha guardado nada (primera vez que abre la app)
  //
  // Ejemplo de uso:
  // bool? savedTheme = preferencesService.getTheme();
  // if (savedTheme != null) {
  //   isDark = savedTheme; // Usar el tema guardado
  // }
  bool? getTheme() {
    // getBool() lee el valor guardado con la clave _keyIsDarkMode.
    // Si no existe (primera vez), devuelve null.
    return _prefs.getBool(_keyIsDarkMode);
  }

  // -------- GUARDAR EL IDIOMA --------
  // Guarda el código del idioma preferido por el usuario.
  //
  // Parámetros:
  // - languageCode: código del idioma ('es', 'ca', 'en')
  //
  // Ejemplo de uso:
  // await preferencesService.saveLanguage('es'); // Guarda español
  Future<void> saveLanguage(String languageCode) async {
    // setString() guarda un texto con la clave especificada.
    // Es como escribir: "languageCode = es"
    await _prefs.setString(_keyLanguageCode, languageCode);
  }

  // -------- CARGAR EL IDIOMA --------
  // Lee el idioma guardado anteriormente.
  //
  // Retorna:
  // - El código del idioma guardado ('es', 'ca', 'en')
  // - null si nunca se ha guardado nada (primera vez)
  //
  // Ejemplo de uso:
  // String? savedLanguage = preferencesService.getLanguage();
  // if (savedLanguage != null) {
  //   _locale = Locale(savedLanguage); // Usar el idioma guardado
  // }
  String? getLanguage() {
    // getString() lee el texto guardado con la clave _keyLanguageCode.
    // Si no existe, devuelve null.
    return _prefs.getString(_keyLanguageCode);
  }

  // -------- BORRAR TODAS LAS PREFERENCIAS --------
  // Elimina TODAS las preferencias guardadas.
  // Útil para "resetear" la app o para cerrar sesión.
  //
  // Ejemplo de uso:
  // await preferencesService.clearAll(); // Borra todo
  Future<void> clearAll() async {
    // clear() elimina todo el contenido del almacenamiento.
    // Es como borrar el archivo de configuración completo.
    await _prefs.clear();
  }

  // -------- BORRAR UNA PREFERENCIA ESPECÍFICA --------
  // Elimina solo una preferencia concreta (tema o idioma).
  //
  // Parámetros:
  // - key: la clave de la preferencia a borrar
  //
  // Ejemplo de uso:
  // await preferencesService.remove(_keyIsDarkMode); // Borra solo el tema
  Future<void> remove(String key) async {
    // remove() elimina solo el valor asociado a esa clave.
    await _prefs.remove(key);
  }

  // ========================================
  // FUNCIONES PARA MANEJAR LA SESIÓN
  // ========================================

  // -------- GUARDAR SESIÓN COMPLETA --------
  // Guarda TODA la información de la sesión cuando el usuario hace login.
  // Esto incluye: token, email y datos completos del usuario.
  //
  // Parámetros:
  // - token: El token de autenticación que devuelve el backend
  // - email: El email del usuario
  // - userData: Datos completos del usuario en formato JSON (String)
  //
  // Ejemplo de uso:
  // await preferencesService.saveSession(
  //   token: 'abc123xyz',
  //   email: 'usuario@ejemplo.com',
  //   userData: '{"nombre":"Juan","rol":"supervisor"}',
  // );
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

  // -------- VERIFICAR SI HAY SESIÓN ACTIVA --------
  // Comprueba si el usuario tiene una sesión iniciada.
  //
  // Retorna:
  // - true si el usuario está logueado
  // - false si NO está logueado (o nunca ha hecho login)

  bool isLoggedIn() {
    // Leemos el valor de _keyIsLoggedIn.
    // Si es null (nunca se guardó), devolvemos false por defecto.
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // -------- OBTENER EL TOKEN GUARDADO --------
  // Lee el token de autenticación guardado.
  //
  // Retorna:
  // - El token si existe
  // - null si no hay sesión activa

  String? getToken() {
    return _prefs.getString(_keyUserToken);
  }

  // -------- OBTENER EL EMAIL GUARDADO --------
  // Lee el email del usuario guardado.
  //
  // Retorna:
  // - El email si existe
  // - null si no hay sesión activa

  String? getUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  // -------- OBTENER DATOS COMPLETOS DEL USUARIO --------
  // Lee los datos completos del usuario guardados en formato JSON.
  //
  // Retorna:
  // - Los datos en formato String (JSON) si existen
  // - null si no hay datos guardados

  String? getUserData() {
    return _prefs.getString(_keyUserData);
  }

  // -------- CERRAR SESIÓN --------
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
