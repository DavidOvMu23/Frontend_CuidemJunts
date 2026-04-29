import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend_cuidemjunts/app/theme/app_theme.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/locale_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/theme_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/notification_overlay_widget.dart';

// ----- Widget principal de la aplicación (MaterialApp) -----

// Configura:
// - El tema (claro/oscuro)
// - El idioma (español/catalán/inglés)

// ----- Información importante para recordar -----
// - El widget MaterialApp es el widget raíz que proporciona los componentes visuales de la app.
// - Un provider es un objeto que almacena datos que pueden ser accedidos por cualquier widget de la app. Por eso usamos providers para guardar el tema y el idioma.
class App extends ConsumerWidget {
  const App({super.key});

  // Usamos 'ConsumerWidget' porque necesitamos consultar a los providers el tema y el idioma.
  // Si el tema o el idioma cambian, este widget se vuelve a construir para mostrar los cambios.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Comprobamos el modo de tema actual (system, light, dark)
    final themeMode = ref.watch(themeProvider);

    // Comprobamos cual es el idioma actual
    final locale = ref.watch(localeProvider);

    // Creamos la app, el MaterialApp es el widget raíz que proporciona los componentes visuales de la app.
    return MaterialApp(
      // Quitar etiqueta roja de debug de mierda
      debugShowCheckedModeBanner: false,

      // Le decimos a Flutter qué idioma usar
      locale: locale,

      // Indicamos a el programa que use nuestras traducciones
      localizationsDelegates: const [
        // Esto es para que use nuestras traducciones
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Indicamos los idioma que tenemos disponibles
      supportedLocales: const [Locale('es'), Locale('ca'), Locale('en')],

      // Indicamos cual es el tema claro y oscuro
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // Le decimos a Flutter que tema usar dependiendo del provider
      themeMode: themeMode,

      // La app SIEMPRE va a iniciar en la página de login por que
      // Nos interesa que el usuario se loguee para poder usar la app
      // Ya que si luego otro usuario coge el mismo dispositivo va a poder
      // Tener acceso a información sensible de los usuarios, por lo tanto a
      // nosotros no nos interesa hacer la persistencia del usuario
      home: Stack(
        children: [const LoginPage(), const NotificationOverlayWidget()],
      ),
    );
  }
}
