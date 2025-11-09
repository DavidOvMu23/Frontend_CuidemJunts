import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/home_widgets.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

// -------- PANTALLA PRINCIPAL DEL SUPERVISOR --------
// Es la primera pantalla que ve el supervisor al entrar.
class HomeSupervisorPage extends StatelessWidget {
  // Funciones para cambiar tema e idioma desde esta página.
  // y asi pasarlas a PreferencesPage y que desde alli se pueda cambiar.
  final void Function(bool) onToggleTheme;
  final void Function(Locale) onChangeLocale;

  const HomeSupervisorPage({
    super.key,
    required this.onToggleTheme,
    required this.onChangeLocale,
  });

  @override
  Widget build(BuildContext context) {
    // -------- TEMAS Y COLORES --------
    // Obtenemos los temas y colores para usarlos en la UI.
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    // Agarramos los textos traducidos para que esta pantalla reaccione al cambio de idioma.
    final l10n = AppLocalizations.of(context)!;
    DateTime hoy = DateTime.now();

    // -------- ESTRUCTURA DE LA PANTALLA --------
    return Scaffold(
      // -------- BARRA SUPERIOR --------
      // Lleva el título y el icono de notificaciones.
      appBar: AppBar(
        //fontsize
        title: Text("CuidemJunts", style: TextStyle(fontSize: 19)),
        centerTitle: true,
        actions: [
          // Icono de notis con su contador.
          general_badge_demo(
            10,
            Icons.notifications,
            onPressed: () {
              // TODO: Acción al pulsar el icono de notificaciones.
            },
          ),
        ],
      ),

      // -------- MENÚ LATERAL (DRAWER) --------
      // Aquí pondremos las opciones para navegar a otras páginas de la app.
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
                          texto: l10n.mainPage,
                          selected: true,
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
                          onTap: () {
                            // Navegamos a la pantalla de preferencias y pasamos las funciones de tema e idioma.
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PreferencesPage(
                                  // Preferences también puede cambiar tema/idioma.
                                  onToggleTheme: onToggleTheme,
                                  onChangeLocale: onChangeLocale,
                                ),
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
                  home_listtile_logout(
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
      // -------- CONTENIDO PRINCIPAL --------
      // Por ahora solo mostramos un texto, pero aquí irán los datos reales.
      // -------- CUERPO  --------
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),

        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.supervisonPanel,
                style: textTheme.titleMedium?.copyWith(fontSize: 27),
              ),

              // fecha de hoy (me ha ayudado el chatgpt)
              Builder(
                builder: (context) {
                  final weekdays = [
                    l10n.lunes,
                    l10n.martes,
                    l10n.miercoles,
                    l10n.jueves,
                    l10n.viernes,
                    l10n.sabado,
                    l10n.domingo,
                  ];
                  final months = [
                    l10n.enero,
                    l10n.febrero,
                    l10n.marzo,
                    l10n.abril,
                    l10n.mayo,
                    l10n.junio,
                    l10n.julio,
                    l10n.agosto,
                    l10n.septiembre,
                    l10n.octubre,
                    l10n.noviembre,
                    l10n.diciembre,
                  ];
                  final fechaHoy =
                      '${weekdays[hoy.weekday - 1]}, ${hoy.day} de ${months[hoy.month - 1]} de ${hoy.year}';
                  return Text(fechaHoy, style: textTheme.bodyMedium);
                },
              ),

              const SizedBox(height: 20),
              Material(
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.programedCalls,
                              textAlign: TextAlign.left,
                              style: textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              //TODO: implementar la consulta para saber cuantas llamadas hay hoy
                              "0",
                              style: textTheme.displayMedium?.copyWith(),
                            ),
                          ],
                        ),
                      ),
                      // Icono de calendario a la derecha, ligeramente más abajo
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Icon(
                          Icons.today,
                          color: colorScheme.primary,
                          size: 60,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Material(
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.todayCalls,
                              textAlign: TextAlign.left,
                              style: textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              //TODO: implementar la consulta para saber cuantas llamadas realizadas se han hecho hoy
                              "0",
                              style: textTheme.displayMedium?.copyWith(),
                            ),
                          ],
                        ),
                      ),
                      // Icono de calendario a la derecha, ligeramente más abajo
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Icon(
                          Icons.phone,
                          color: colorScheme.primary,
                          size: 60,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
