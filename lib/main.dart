import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_theme.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';

// Punto de entrada de la aplicación
void main() {
  runApp(const MyApp());
}

// Widget raíz de la aplicación
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

// Estado del widget raíz
class _MyAppState extends State<MyApp> {
  bool isDark = false; // Modo oscuro por defecto

  // Detecta el modo del sistema al iniciar la app
  @override
  void initState() {
    super.initState();

    // Detecta el tema del sistema operativo
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    // Establece el tema inicial según el sistema
    isDark = brightness == Brightness.dark;
  }

  // Para cambiar el tema desde preferencias
  void toggleTheme(bool value) {
    setState(() => isDark = value);
  }

  // Construye la aplicación
  @override
  Widget build(BuildContext context) {
    //Crea la aplicación con los temas y la página de login
    return MaterialApp(
      title: 'Cuidem Junts',
      debugShowCheckedModeBanner: false,

      // Define los temas claro y oscuro
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // Aplica el modo según el sistema al iniciar, y lo que el usuario cambie después si quiere desde preferencias
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      // Página de inicio
      home: LoginPage(onToggleTheme: toggleTheme),
    );
  }
}
