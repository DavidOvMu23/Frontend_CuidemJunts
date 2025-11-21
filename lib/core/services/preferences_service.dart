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
}
