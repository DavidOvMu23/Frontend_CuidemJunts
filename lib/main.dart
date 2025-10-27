import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_theme.dart';
import 'package:frontend_cuidemjunts/catalog/catalog_page.dart';

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
  // Constructor de MyApp (usa "const" porque no cambia)
  const MyApp({super.key});

  // Crea y asocia el estado de este widget (definido más abajo en _MyAppState)
  @override
  State<MyApp> createState() => _MyAppState();
}

// -------- ESTADO DE MyApp --------

// Esta clase guarda los datos que pueden cambiar en la app, como el modo oscuro o claro.
class _MyAppState extends State<MyApp> {
  // Variable para saber si está activado el modo oscuro
  bool isDark = false;

  // initState() se ejecuta una sola vez cuando el widget se crea por primera vez.
  // Aquí se puede inicializar información importante antes de que la app se muestre.
  @override
  void initState() {
    super.initState();

    // Obtenemos el brillo del sistema operativo (puede ser claro u oscuro)
    //(ESTO ME LO RECOMENDÓ EL CHAT GPT PARA QUE LA APP SEA MAS CHULA Y
    //RESPONDA AL TEMA DEL SISTEMA OPERATIVO)
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    // Si el sistema está en modo oscuro, activamos el tema oscuro
    isDark = brightness == Brightness.dark;
  }

  // Esta función permite cambiar el tema desde dentro de la app.
  // Por ejemplo, si el usuario quiere cambiar de claro a oscuro manualmente desde las preferencias.
  void toggleTheme(bool value) {
    // setState() actualiza la interfaz cuando cambia el valor de isDark.
    setState(() => isDark = value);
  }

  // -------- CONSTRUCCIÓN DE LA INTERFAZ --------
  // El método build() se ejecuta cada vez que el estado cambia.
  // Devuelve la estructura visual de la aplicación.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Nombre de la aplicación
      title: 'Cuidem Junts',

      // Oculta la etiqueta de "debug" que aparece arriba a la derecha
      debugShowCheckedModeBanner: false,

      // Aquí definimos los temas claro y oscuro usando AppTheme (definido en app/theme/app_palette.dart)
      theme: AppTheme.lightTheme, // Declaramos el tema claro
      darkTheme: AppTheme.darkTheme, // Declaramos el tema oscuro
      // themeMode decide cuál tema aplicar: claro u oscuro
      // Si isDark es true, se usa el modo oscuro; si es false, el claro
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      // Página principal de la aplicación al abrirla
      // En este caso, es la página de inicio de sesión (LoginPage)
      // Se le pasa la función toggleTheme para permitir cambiar el tema desde ahí
      //home: LoginPage(onToggleTheme: toggleTheme),
      home: CatalogPage(),
    );
  }
}
