import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_theme.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/supervisor/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/services/preferences_service.dart';

// -------- PUNTO DE ENTRADA DE LA APLICACIÓN --------

// La función main() es el punto de inicio de toda app Flutter.
// Ahora es "async" porque necesitamos ESPERAR a que se carguen las preferencias
// guardadas antes de mostrar la app (tema e idioma guardados).
//
// ¿Por qué async?
// Porque leer del almacenamiento local tarda un poquito (milisegundos),
// y no queremos que la app se congele esperando.
void main() async {
  // -------- INICIALIZACIÓN DE FLUTTER --------
  // Esta línea es OBLIGATORIA cuando main() es async.
  // Asegura que Flutter esté listo antes de hacer operaciones asíncronas.
  // Sin esto, la app crashearía.
  WidgetsFlutterBinding.ensureInitialized();

  // -------- CREAR E INICIALIZAR EL SERVICIO DE PREFERENCIAS --------
  // Creamos una instancia del servicio que maneja el almacenamiento local.
  final preferencesService = PreferencesService();

  // Inicializamos el servicio (conecta con el almacenamiento del dispositivo).
  // El "await" hace que esperemos a que termine antes de continuar.
  await preferencesService.init();

  // -------- EJECUTAR LA APLICACIÓN --------
  // Ahora sí, ejecutamos la app y le pasamos el servicio de preferencias
  // para que pueda cargar y guardar el tema e idioma.
  runApp(MyApp(preferencesService: preferencesService));
}

// -------- WIDGET PRINCIPAL DE LA APLICACIÓN --------
// MyApp es el widget raíz. Representa toda la aplicación.
// "StatefulWidget" significa que puede tener un estado que cambia (por ejemplo, modo claro/oscuro).
class MyApp extends StatefulWidget {
  // -------- SERVICIO DE PREFERENCIAS --------
  // Recibimos el servicio de preferencias desde main() para poder
  // cargar y guardar el tema e idioma del usuario.
  final PreferencesService preferencesService;

  // Constructor: ahora requiere el servicio de preferencias.
  const MyApp({super.key, required this.preferencesService});

  @override
  State<MyApp> createState() => _MyAppState();
}

// -------- ESTADO DE MyApp --------
// Esta clase guarda los datos que pueden cambiar en la app, como el modo oscuro,
// claro o el idioma. Al vivir en el widget raíz, cualquier cambio se propaga a todas
// las pantallas automáticamente.
class _MyAppState extends State<MyApp> {
  // ---- VARIABLES DE ESTADO GLOBAL ----
  // Aquí mantenemos la información que queremos que recuerde toda la app:

  // MyApp es Stateful, por eso podemos modificarlas con setState()
  bool isDark = false; //controla si usamos tema claro u oscuro.
  Locale _locale = const Locale('es'); //define que idioma usar

  // initState() se ejecuta una sola vez cuando el widget se crea por primera vez.
  // Aquí se puede inicializar información importante antes de que la app se muestre.
  @override
  void initState() {
    super.initState();

    // -------- CARGAR PREFERENCIAS GUARDADAS --------
    // Intentamos cargar el tema y el idioma que el usuario guardó la última vez.
    _loadPreferences();
  }

  // -------- FUNCIÓN PARA CARGAR PREFERENCIAS --------
  // Lee del almacenamiento local el tema e idioma guardados anteriormente.
  // Si es la primera vez que abre la app, usa valores por defecto.
  void _loadPreferences() {
    // ---- CARGAR TEMA ----
    // Preguntamos al servicio: "¿Qué tema guardó el usuario?"
    final savedTheme = widget.preferencesService.getTheme();

    // Si encontramos un tema guardado (no es null), lo usamos.
    // Si es null (primera vez), usamos el tema del sistema operativo.
    if (savedTheme != null) {
      // El usuario ya había elegido un tema antes, lo restauramos.
      isDark = savedTheme;
    } else {
      // Primera vez: usamos el tema del sistema operativo.
      // (ESTO ME LO RECOMENDÓ EL CHAT GPT PARA QUE LA APP SEA MAS CHULA Y
      // RESPONDA AL SISTEMA OPERATIVO)
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      isDark = brightness == Brightness.dark;
    }

    // ---- CARGAR IDIOMA ----
    // Preguntamos al servicio: "¿Qué idioma guardó el usuario?"
    final savedLanguage = widget.preferencesService.getLanguage();

    // Si encontramos un idioma guardado, lo usamos.
    // Si no (primera vez), dejamos el español por defecto.
    if (savedLanguage != null) {
      // El usuario ya había elegido un idioma, lo restauramos.
      _locale = Locale(savedLanguage);
    }
    // Si savedLanguage es null, _locale ya está en español por defecto (línea 28)
  }

  // Esta función permite cambiar el tema desde dentro de la app.
  // La pasamos como callback a otras pantallas; cuando la invoquen, setState()
  // guardará el nuevo valor y notificará al framework para que repinte los widgets.
  //
  // AHORA TAMBIÉN GUARDA la preferencia en el almacenamiento local para recordarla.
  void toggleTheme(bool value) {
    // setState() actualiza la interfaz cuando cambia el valor de isDark.
    setState(() => isDark = value);

    // -------- GUARDAR LA PREFERENCIA --------
    // Guardamos el nuevo tema en el almacenamiento local.
    // La próxima vez que abra la app, se cargará este valor.
    widget.preferencesService.saveTheme(value);
  }

  // Funcionamiento idéntico al anterior pero para el idioma.
  // Cualquier pantalla puede llamar a onChangeLocale para cambiarlo (por ejemplo, el login y el preferences).
  // Al actualizar _locale, MaterialApp vuelve a construir los textos localizados.
  //
  // AHORA TAMBIÉN GUARDA la preferencia en el almacenamiento local para recordarla.
  void setLocale(Locale locale) {
    if (_locale == locale) {
      return;
    }
    setState(() => _locale = locale);

    // -------- GUARDAR LA PREFERENCIA --------
    // Guardamos el nuevo idioma en el almacenamiento local.
    // Guardamos solo el código del idioma ('es', 'ca', 'en').
    widget.preferencesService.saveLanguage(locale.languageCode);
  }

  // -------- CONSTRUCCIÓN DE LA INTERFAZ --------
  // Devuelve la estructura visual de la aplicación.
  @override
  Widget build(BuildContext context) {
    // -------- VERIFICAR SI HAY SESIÓN ACTIVA --------
    // Preguntamos: "¿El usuario ya está logueado?"
    final isLoggedIn = widget.preferencesService.isLoggedIn();

    // -------- DECIDIR QUÉ PANTALLA MOSTRAR --------
    // Si está logueado, vamos directo a la pantalla principal.
    // Si NO está logueado, mostramos el login.
    Widget homePage;

    if (isLoggedIn) {
      // ¡El usuario YA está logueado! Vamos directo a su pantalla principal.
      homePage = HomeSupervisorPage(
        onToggleTheme: toggleTheme,
        onChangeLocale: setLocale,
        preferencesService: widget.preferencesService, // Pasamos el servicio
      );
    } else {
      // El usuario NO está logueado. Mostramos la pantalla de login.
      homePage = LoginPage(
        onToggleTheme: toggleTheme,
        onChangeLocale: setLocale,
        preferencesService: widget.preferencesService, // Pasamos el servicio
      );
    }

    return MaterialApp(
      // Nombre de la aplicación
      title: 'Cuidem Junts',

      // Oculta la etiqueta de "debug" que aparece arriba a la derecha
      debugShowCheckedModeBanner: false,

      // Configuración de internacionalización(documentación de web de pepe)
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,

      // Idioma que tenemos guardado en el estado global
      locale: _locale,

      // Aquí definimos los temas claro y oscuro usando AppTheme (definido en app/theme/app_palette.dart)
      theme: AppTheme.lightTheme, // Declaramos el tema claro
      darkTheme: AppTheme.darkTheme, // Declaramos el tema oscuro
      // themeMode decide cuál tema aplicar: claro u oscuro
      // Si isDark es true, se usa el modo oscuro; si es false, el claro
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      // -------- PANTALLA INICIAL --------
      // Mostramos la pantalla que decidimos arriba (login o home).
      home: homePage,
    );
  }
}
