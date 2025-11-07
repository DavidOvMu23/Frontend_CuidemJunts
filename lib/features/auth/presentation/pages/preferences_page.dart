import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

// Página de preferencias de la app
class PreferencesPage extends StatefulWidget {
  const PreferencesPage({
    super.key,
    required this.onToggleTheme,
    required this.onChangeLocale,
  });
  // Callback para cambiar el tema
  final void Function(bool) onToggleTheme;
  final void Function(Locale) onChangeLocale;

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

// Estado de la página de preferencias
class _PreferencesPageState extends State<PreferencesPage> {
  // Valor seleccionado del idioma
  late String selectedLanguage;
  bool _languageInitialized = false;

  // Lista de idiomas disponibles
  final Map<String, Locale> languageOptions = const {
    'Español': Locale('es'),
    'Valencià': Locale('ca'),
    'English': Locale('en'),
  };

  @override
  void initState() {
    super.initState();
    selectedLanguage = 'Español';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_languageInitialized) return;
    final currentLocale = Localizations.localeOf(context);
    final match = languageOptions.entries.firstWhere(
      (entry) => entry.value.languageCode == currentLocale.languageCode,
      orElse: () => languageOptions.entries.first,
    );
    selectedLanguage = match.key;
    _languageInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Tema actual
    final theme = Theme.of(context);

    // Construye la interfaz de usuario
    return Scaffold(
      // AppBar con título y notificaciones
      appBar: AppBar(
        title: Text(l10n.appPreferences),
        centerTitle: true,

        //Notificaciones
        actions: [
          general_badge_demo(10, Icons.notifications, onPressed: () {}),
        ],
      ),

      // Menú lateral para navegar al Home
      drawer: Drawer(
        // Lista de opciones en el menú lateral
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 16),
            // logo de la app
            Image.asset('assets/images/Logo_CuidemJunts.png', height: 120),

            // título de la app
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              child: Text(
                'Cuidem Junts',
                // vuelve al estilo de texto por defecto del tema (como antes)
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
            ),

            const Divider(),

            // opción de preferencias
            general_listile_demo(
              context: context,
              icon: Icons.home,
              texto: "Home",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(
                      onToggleTheme: widget.onToggleTheme,
                      onChangeLocale: widget.onChangeLocale,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      // Cuerpo de la página con las preferencias
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        //Sized box para ocupar todo el ancho
        child: SizedBox(
          width: double.infinity, // Ocupa todo el ancho disponible
          // Surface
          child: Material(
            borderRadius: BorderRadius.circular(16),

            // Contenido de las preferencias
            child: Padding(
              padding: const EdgeInsets.all(16.0),

              // Column con las opciones
              child: Column(
                //alineado de las opciones
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,

                // Opciones de preferencias
                children: [
                  ListTile(
                    // Elimina el padding por defecto para ajustar mejor el diseño
                    contentPadding: EdgeInsets.zero,

                    // Título con icono que cambia según el tema
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.lenguagePreferences,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        // Dropdown para seleccionar idioma
                        DropdownButton<String>(
                          value: selectedLanguage,
                          borderRadius: BorderRadius.circular(12),
                          onChanged: (String? newValue) {
                            if (newValue == null) return;
                            final locale = languageOptions[newValue];
                            if (locale == null) return;
                            setState(() {
                              selectedLanguage = newValue;
                            });
                            widget.onChangeLocale(locale);
                          },
                          items: languageOptions.keys.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  //linea de configuracion de idioma
                  const SizedBox(height: 16),

                  //SwitchListTile para cambiar el tema
                  //la diferencia entre switchlisttile y switch es que
                  //switchlisttile hace que todo el tile sea clickeable
                  //y el switch solo el propio boton
                  SwitchListTile(
                    // Elimina el padding por defecto para ajustar mejor el diseño
                    contentPadding: EdgeInsets.zero,

                    // Título con icono que cambia según el tema
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Tema',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Icono que cambia según el tema
                        Icon(
                          // Muestra un icono diferente según el tema actual
                          Theme.of(context).brightness == Brightness.dark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                    // Valor del switch según el tema actual
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (value) => widget.onToggleTheme(value),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
