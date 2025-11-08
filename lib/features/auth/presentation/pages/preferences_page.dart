import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';

// -------- PÁGINA DE PREFERENCIAS --------
// Aquí cambio idioma y tema sin salirme de la app.
class PreferencesPage extends StatefulWidget {
  const PreferencesPage({
    super.key,
    required this.onToggleTheme,
    required this.onChangeLocale,
  });

  final void Function(bool) onToggleTheme; // Cambia modo claro/oscuro.
  final void Function(Locale) onChangeLocale; // Cambia idioma.

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  late String
  selectedLanguage; // Esto es lo que ve el usuario en el desplegable.
  bool _languageInitialized = false; // Bandera para no recalcular cada vez.

  // Lista con los idiomas que tengo disponibles.
  final Map<String, Locale> languageOptions = const {
    'Español': Locale('es'),
    'Valencià': Locale('ca'),
    'English': Locale('en'),
  };

  @override
  void initState() {
    super.initState();
    selectedLanguage = 'Español'; // Arranco en español por defecto.
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
    final theme = Theme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // -------- APPBAR CON EL BOTÓN DE NOTIS --------
      appBar: AppBar(
        title: Text(l10n.appPreferences),
        centerTitle: true,
        actions: [
          general_badge_demo(10, Icons.notifications, onPressed: () {}),
        ],
      ),

      // -------- MENÚ LATERAL --------
      // Menú rápido para volver al Home sin más historias.
      drawer: Drawer(
        // -------- CONTENIDO DEL DRAWER --------
        // Almacenamos los elementos en una columna
        child: Column(
          // -------- LISTA DE OPCIONES --------
          // Con el Expanded hacemos que la lista use todo el alto disponible
          children: [
            Expanded(
              // ListView para que el contenido del drawer sea scrollable.
              child: ListView(
                children: [
                  // -------- CABECERA CON LOGO --------
                  // Contiene el logo y nombre de la app.
                  Padding(
                    //para separar de los bordes
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),

                    //almacenamos los textos e imagen en una fila
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/Logo_CuidemJunts.png',
                          height: 74,
                        ),
                        const SizedBox(
                          width: 16,
                        ), //espacio entre imagen y textos

                        Expanded(
                          //almacenamos los textos en una columna para que este uno encima del otro
                          child: Column(
                            children: [
                              // Nombre de la app
                              Text(
                                'CuidemJunts',
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),

                              // Lema de la app
                              Text(
                                'Lluita contra la soletat\nen persones majors',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // -------- DIVISOR --------
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(color: colorScheme.primary.withOpacity(0.3)),
                  ),
                  const SizedBox(height: 10),

                  // -------- TÍTULO DE LA SECCIÓN --------
                  // Texto “Supervisión” para separar las opciones principales.
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ).copyWith(top: 8),
                    child: Text(
                      l10n.supervison,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // -------- OPCIONES DEL MENÚ --------
                  // Cada opción es un ListTile personalizado llamando a la función
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        // Opción de Home (seleccionada), no ponemos el onTap porque es la página actual
                        general_listile_demo(
                          context: context,
                          icon: Icons.home,
                          texto: l10n.mainMenu,
                          selected: false,
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeSupervisorPage(
                                  onToggleTheme: widget.onToggleTheme,
                                  onChangeLocale: widget.onChangeLocale,
                                ),
                              ),
                            );
                          },
                        ),

                        // Opción de Llamadas
                        general_listile_demo(
                          context: context,
                          icon: Icons.phone,
                          texto: l10n.calls,
                          // TODO: Añadir navegación a la pantalla de llamadas
                          onTap: () {},
                        ),

                        // Opción de Usuarios
                        general_listile_demo(
                          context: context,
                          icon: Icons.people,
                          texto: l10n.users,
                          // TODO: Añadir navegación a la pantalla de usuarios
                          onTap: () {},
                        ),

                        // Opción de Grupos y Teleoperadores
                        general_listile_demo(
                          context: context,
                          icon: Icons.support_agent,
                          texto: l10n.telemarketers,
                          // TODO: Añadir navegación a la pantalla de grupos
                          onTap: () {},
                        ),
                        // Opción de Preferencias
                        general_listile_demo(
                          context: context,
                          icon: Icons.settings,
                          texto: l10n.preferences,
                          selected: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            // -------- SECCIÓN INFERIOR CON PERFIL Y LOGOUT --------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),

              // Almacenamos el avatar, nombre y botón de logout en una columna
              child: Column(
                children: [
                  // -------- AVATAR Y NOMBRE DE USUARIO --------
                  ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      // Integramos el avatar con el tema.
                      backgroundColor: colorScheme.surface,
                      foregroundColor: colorScheme.primary,
                      child: const Icon(Icons.person, size: 32),
                    ),
                    title: Text(
                      'Supervisor Name',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      l10n.supervisor,
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // -------- OPCIÓN DE CERRAR SESIÓN --------
                  general_listtile_logout(
                    context: context,
                    icon: Icons.logout,
                    texto: l10n.logOut,
                    onTap: () {
                      // Mostramos un diálogo de confirmación antes de cerrar sesión.
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.logOut),
                          content: Text(l10n.confirmLogOut),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(l10n.cancel),
                            ),
                            FilledButton(
                              onPressed: () {
                                //TODO: Implementar cierre de sesión
                              },
                              child: Text(l10n.accept),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // -------- CUERPO  --------
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: Material(
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -------- ZONA DE IDIOMA --------
                  // ListTile + Dropdown para cambiar el idioma de toda la app.
                  ListTile(
                    contentPadding: EdgeInsets.zero,
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
                  const SizedBox(height: 16),

                  // -------- ZONA DE TEMA --------
                  // SwitchListTile para activar/desactivar modo oscuro.
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          l10n.theme,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Theme.of(context).brightness == Brightness.dark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
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
