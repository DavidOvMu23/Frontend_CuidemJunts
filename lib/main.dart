import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_theme.dart';
import 'package:frontend_cuidemjunts/catalog/catalog_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/supervisor/home_supervisor_page.dart';

// -------- PUNTO DE ENTRADA DE LA APLICACIÓN --------

// La función main() es el punto de inicio de toda app Flutter.
// Aquí se ejecuta la aplicación llamando a runApp() y pasando nuestro widget principal (MyApp).
void main() {
  runApp(const MyApp());
}

// -------- WIDGET PRINCIPAL DE LA APLICACIÓN --------
// MyApp es el widget raíz. Representa toda la aplicación.
// "StatefulWidget" significa que puede tener un estado que cambia (por ejemplo, modo claro/oscuro).
class MyApp extends StatefulWidget {
  const MyApp({super.key});

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

    // Obtenemos el tema del sistema operativo (puede ser claro u oscuro)
    //(ESTO ME LO RECOMENDÓ EL CHAT GPT PARA QUE LA APP SEA MAS CHULA Y
    //RESPONDA AL SISTEMA OPERATIVO)
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    // Si el sistema está en modo oscuro, activamos el tema oscuro
    isDark = brightness == Brightness.dark;
  }

  // Esta función permite cambiar el tema desde dentro de la app.
  // La pasamos como callback a otras pantallas; cuando la invoquen, setState()
  // guardará el nuevo valor y notificará al framework para que repinte los widgets.
  void toggleTheme(bool value) {
    // setState() actualiza la interfaz cuando cambia el valor de isDark.
    setState(() => isDark = value);
  }

  // Funcionamiento idéntico al anterior pero para el idioma.
  // Cualquier pantalla puede llamar a onChangeLocale para cambiarlo (por ejemplo, el login y el preferences).
  // Al actualizar _locale, MaterialApp vuelve a construir los textos localizados.
  void setLocale(Locale locale) {
    if (_locale == locale) {
      return;
    }
    setState(() => _locale = locale);
  }

  // -------- CONSTRUCCIÓN DE LA INTERFAZ --------
  // Devuelve la estructura visual de la aplicación.
  @override
  Widget build(BuildContext context) {
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

      // Página principal de la aplicación al abrirla.
      // Le pasamos referencias (callbacks) a nuestras funciones de estado para que el Login
      // pueda pedir cambios de idioma o tema. Así, el estado se mantiene aquí pero se controla
      // desde cualquier lugar de la app.
      home: HomeSupervisorPage(
        onToggleTheme: toggleTheme,
        onChangeLocale: setLocale,
      ),
      //home: CatalogPage(),
    );
  }
}
