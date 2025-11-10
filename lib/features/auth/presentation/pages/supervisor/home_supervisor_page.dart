import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/home_widgets.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';

// -------- PANTALLA PRINCIPAL DEL SUPERVISOR --------
// Es la primera pantalla que ve el supervisor al entrar.
class HomeSupervisorPage extends StatelessWidget {
  // Funciones para cambiar tema e idioma desde esta página
  // (se las pasamos a PreferencesPage para que también pueda usarlas).
  // Callback que activa/desactiva el tema oscuro/claro.
  final void Function(bool) onToggleTheme;

  // Callback que cambia el idioma de la app.
  final void Function(Locale) onChangeLocale;

  const HomeSupervisorPage({
    super.key,
    required this.onToggleTheme,
    required this.onChangeLocale,
  });

  @override
  Widget build(BuildContext context) {
    // -------- TEMAS, COLORES Y TEXTOS --------
    // Obtenemos tipografías y paleta del tema actual para mantener
    // estilos consistentes en toda la app.
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Textos traducidos (según el idioma seleccionado en la app).
    final l10n = AppLocalizations.of(context)!;
    DateTime hoy = DateTime.now();

    // -------- ESTRUCTURA DE LA PANTALLA --------
    return Scaffold(
      // -------- BARRA SUPERIOR --------
      // AppBar: barra superior con título centrado e iconos de acción a la derecha.
      appBar: AppBar(
        // Título de la app
        title: Text("CuidemJunts", style: TextStyle(fontSize: 19)),
        //centramos el título
        centerTitle: true,
        actions: [
          // Icono de notificaciones con contador.
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
      // Drawer: menú que se abre desde el lateral con opciones de navegación.
      drawer: Drawer(
        // -------- CONTENIDO DEL DRAWER --------
        // Usamos Column + Expanded + ListView para hacer el contenido scrollable
        // y dejar la sección de perfil fija abajo.
        child: Column(
          // -------- LISTA DE OPCIONES --------
          // Expanded hace que la lista coja todo el alto disponible.
          children: [
            Expanded(
              // ListView para que el contenido del drawer sea scrollable.
              child: ListView(
                children: [
                  // -------- CABECERA CON LOGO --------
                  // Muestra el logo y el nombre/lema de la app.
                  Padding(
                    // separa del borde para que no quede pegado.
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),

                    // Fila con imagen a la izquierda y textos a la derecha.
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
                          // Columna para tener nombre y lema uno debajo del otro.
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
                  // Cada opción usa un ListTile personalizado (general_listile_demo)
                  // que ya aplica estilos consistentes con la app.
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UsersPage(
                                  onToggleTheme: onToggleTheme,
                                  onChangeLocale: onChangeLocale,
                                ),
                              ),
                            );
                          },
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
                            // Navegación a la pantalla de Preferencias.
                            // Navigator.push abre una nueva pantalla encima de la actual.
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
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(
                                      onToggleTheme: onToggleTheme,
                                      onChangeLocale: onChangeLocale,
                                    ),
                                  ),
                                );
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
      body: SingleChildScrollView(
        // SingleChildScrollView permite que toda la columna sea scrolleable
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),

        // ConstrainedBox sirve para que la columna ocupe todo el ancho disponible
        child: ConstrainedBox(
          // Hacemos que la columna ocupe todo el ancho disponible.

          // Esto es necesario para que los elementos dentro de la columna
          // (como las "tarjetas" de Material) ocupen todo el ancho posible.
          constraints: const BoxConstraints(minWidth: double.infinity),

          // Columna principal con todo el contenido de la página.
          child: Column(
            // Alineamos todo a la izquierda.
            crossAxisAlignment: CrossAxisAlignment.start,

            // Elementos de la columna
            children: [
              // Título principal
              Text(
                l10n.supervisonPanel,
                style: textTheme.titleMedium?.copyWith(fontSize: 27),
              ),

              // Fecha de hoy con textos traducidos (nombres de días/meses). (el chatgpt me ha ayudado con esto)
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
              // -------- TARJETAS DE ESTADÍSTICAS --------
              Material(
                // Material para mostrar las llamadas programadas.
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),

                  // Fila con texto a la izquierda e icono a la derecha.
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Texto con título y contador grande. el expanded hace que ocupe todo el espacio posible
                      Expanded(
                        // Columna para tener título y contador uno debajo del otro.
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

                      // Icono de calendario a la derecha
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
              // Material para mostrar las llamadas completadas.
              Material(
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  // Fila con texto a la izquierda e icono a la derecha.
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Texto con título y contador grande. el expanded hace que ocupe todo el espacio posible
                      Expanded(
                        // Columna para tener título y contador uno debajo del otro.
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.completedCalls,
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

                      // Icono de teléfono a la derecha
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

              //TODO: implementar ifelse para mostrar llamadas a realizar hoy si no mostrar lo que hay actualmente
              const SizedBox(height: 20),
              // Material para mostrar las llamadas programadas para hoy.
              Material(
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // titulo de la sección
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.todayCalls,
                              style: textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),

                      //divisor
                      const SizedBox(height: 12),
                      Divider(color: colorScheme.primary.withOpacity(0.25)),

                      // Contenido central cuando no hay llamadas programadas
                      SizedBox(
                        height: 120,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.phone_in_talk,
                                size: 48,
                                color: colorScheme.primary.withOpacity(0.25),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                l10n.nothingTodayCalls,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
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

              //TODO: implementar ifelse para mostrar actividad reciente en lista si no mostrar lo que hay actualmente
              const SizedBox(height: 20),
              Material(
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado: icono + título + contador pequeño
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.activityRecent,
                              style: textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Divider(color: colorScheme.primary.withOpacity(0.25)),

                      // Contenido central cuando no hay llamadas programadas
                      SizedBox(
                        height: 120,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.electric_bolt,
                                size: 48,
                                color: colorScheme.primary.withOpacity(0.25),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                l10n.nothingActivityRecent,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
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
            ],
          ),
        ),
      ),
    );
  }
}
