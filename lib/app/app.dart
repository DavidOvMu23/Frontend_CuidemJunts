import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend_cuidemjunts/app/theme/app_theme.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/locale_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/theme_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/supervisor/home_supervisor_page.dart';

// Widget principal de la aplicación (MaterialApp).

// Configura:
// - El tema (claro/oscuro)
// - El idioma (español/catalán/inglés)
// - La pantalla inicial según el estado de autenticación
class App extends ConsumerWidget {
  const App({super.key});

  // Usamos 'ConsumerWidget' porque necesitamos escuchar a nuestros providers.
  // Si el tema, el idioma o el estado de login cambian, este widget se reconstruye
  // automáticamente para reflejar los cambios.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Comprobamos si el usuario está logueado o no,
    // la app se repinta y nos redirige a la pantalla correcta.
    final authState = ref.watch(authProvider);

    // Comprobamos si el tema actual es el claro o el oscuro
    final isDarkMode = ref.watch(themeProvider);

    // Comprobamos cual es el idioma actual
    final locale = ref.watch(localeProvider);

    // Decidimos qué pantalla mostrar según si el usuario está logueado por que
    Widget initialPage;
    if (authState.isAuthenticated) {
      // Si tiene sesión activa lo lleva al home
      initialPage = const HomeSupervisorPage();
    } else {
      // Si no tiene sesión inciada lo lleva al login para iniciar sesión
      initialPage = const LoginPage();
    }

    // Creamos la app, el MaterialApp es el widget raíz que proporciona los componentes visuales de la app.
    return MaterialApp(
      // Quitamos la etiqueta roja de debug de la esquina
      debugShowCheckedModeBanner: false,

      // Le decimos a Flutter qué idioma usar ahora mismo
      locale: locale,

      localizationsDelegates: const [
        // Establecemos aqui nuestras traducciones personalizadas
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Lista de idiomas
      supportedLocales: const [Locale('es'), Locale('ca'), Locale('en')],

      // Indicamos cuales son los temas claro y oscuro para poder hacer uso de estos
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // Le decimos a Flutter cuál de los dos usar según el provider
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // Aquí ponemos la página que decidimos antes dependiendo si el usuario
      // tiene sesión iniciada o no
      home: initialPage,
    );
  }
}
