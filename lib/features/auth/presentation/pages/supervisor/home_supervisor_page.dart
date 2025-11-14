import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/llamadas_page.dart';

// -------- PANTALLA PRINCIPAL DEL SUPERVISOR --------
// Es la primera pantalla que ve el supervisor al entrar.
class HomeSupervisorPage extends StatelessWidget {
  // Callback que cambia el tema de la app.
  // Si es true, activa modo oscuro; si es false, modo claro.
  // Se utiliza para que el cambio de tema afecte a toda la app.
  final void Function(bool) onToggleTheme;

  // Callback que cambia el idioma de la app.
  // Se utiliza para que el cambio de idioma afecte a toda la app.
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
      appBar: appMainAppBar(
        onNotifications: () {
          // TODO: Acción al pulsar el icono de notificaciones.
        },
      ),

      // -------- MENÚ LATERAL (DRAWER) --------
      // Drawer: menú que se abre desde el lateral con opciones de navegación.
      drawer: appDrawer(
        context: context,
        selected: DrawerItem.home,
        onTapCalls: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LlamadasPage(
                onToggleTheme: onToggleTheme,
                onChangeLocale: onChangeLocale,
              ),
            ),
          );
        },
        onTapUsers: () {
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
        onTapTelemarketers: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkersPage(
                onToggleTheme: onToggleTheme,
                onChangeLocale: onChangeLocale,
              ),
            ),
          );
        },
        onTapPreferences: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PreferencesPage(
                onToggleTheme: onToggleTheme,
                onChangeLocale: onChangeLocale,
              ),
            ),
          );
        },
        onLogoutConfirmed: () {
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
      ),

      // -------- CONTENIDO PRINCIPAL --------
      body: SingleChildScrollView(
        // SingleChildScrollView permite que toda la columna sea scrolleable
        padding: const EdgeInsets.symmetric(horizontal: 16.0),

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
