import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/llamadas_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/llamadas_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';

// -------- PANTALLA PRINCIPAL DEL SUPERVISOR --------
// Es la primera pantalla que ve el supervisor al entrar.
// Ahora usa Riverpod para acceder al estado global.
class HomeSupervisorPage extends ConsumerWidget {
  const HomeSupervisorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // -------- TEMAS, COLORES Y TEXTOS --------
    // Obtenemos tipografías y paleta del tema actual para mantener
    // estilos consistentes en toda la app.
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Textos traducidos (según el idioma seleccionado en la app).
    final l10n = AppLocalizations.of(context)!;
    final DateTime hoy = DateTime.now();

    // -------- DATOS DE LLAMADAS --------
    final scheduledCallsAsync = ref.watch(scheduledCallsTodayProvider);
    final completedCallsAsync = ref.watch(completedCallsTodayProvider);
    final callsTodayAsync = ref.watch(callsTodayProvider);
    final recentCallsAsync = ref.watch(recentCallsProvider);

    // -------- DATOS DE NOTIFICACIÓN --------
    final notificacionesSinLeerAsync = ref.watch(notificacionesSinLeerProvider);

    // -------- OBTENER NOMBRE DEL USUARIO DESDE RIVERPOD --------
    // Obtenemos el estado de autenticación del provider
    final authState = ref.watch(authProvider);
    String? userName;
    String? userRole;

    if (authState.userData != null) {
      try {
        // Convertimos el JSON a un Map
        final userData =
            jsonDecode(authState.userData!) as Map<String, dynamic>;

        // Intentamos obtener el nombre del usuario
        userName =
            userData['nombre']?.toString() ??
            userData['name']?.toString() ??
            userData['correo']?.toString() ??
            userData['email']?.toString();
        userRole = userData['rol']?.toString();
      } catch (e) {
        // Si hay error al parsear el JSON, simplemente no mostramos nombre
        userName = null;
      }
    }

    // -------- ESTRUCTURA DE LA PANTALLA --------
    return Scaffold(
      // -------- BARRA SUPERIOR --------
      // AppBar: barra superior con título centrado e iconos de acción a la derecha.
      appBar: appMainAppBar(
        numeroNotificaciones: notificacionesSinLeerAsync.when(
          data: (count) => count,
          loading: () => 0,
          error: (_, __) => 0,
        ),
        onNotifications: () {
          showNotificacionesDialog(context, ref, l10n);
        },
      ),

      // -------- MENÚ LATERAL (DRAWER) --------
      // Drawer: menú que se abre desde el lateral con opciones de navegación.
      drawer: appDrawer(
        context: context,
        userName: userName, // Pasamos el nombre del usuario
        userRole: userRole,
        selected: DrawerItem.home,
        onTapCalls: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LlamadasPage()),
          );
        },
        onTapUsers: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UsersPage()),
          );
        },
        onTapTelemarketers: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WorkersPage()),
          );
        },
        onTapPreferences: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PreferencesPage()),
          );
        },
        onLogoutConfirmed: () async {
          // -------- CERRAR SESIÓN CON RIVERPOD --------
          // Usamos el provider de autenticación para cerrar sesión
          await ref.read(authProvider.notifier).logout();

          // -------- NAVEGAR AL LOGIN --------
          // Usamos pushAndRemoveUntil para eliminar TODAS las pantallas
          // anteriores del stack de navegación. Así el usuario no puede
          // volver atrás con el botón de "atrás".
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false, // Elimina TODAS las rutas anteriores
          );
        },
      ),

      // -------- CONTENIDO PRINCIPAL --------
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título principal (fijo)
            Text(
              l10n.supervisonPanel,
              style: textTheme.titleMedium?.copyWith(fontSize: 27),
            ),

            // Fecha de hoy con textos traducidos (fijo)
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

            const SizedBox(height: 6),

            // Contenido scrolleable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                  const SizedBox(height: 6),

                                  scheduledCallsAsync.when(
                                    data: (count) => Text(
                                      count.toString(),
                                      style: textTheme.displayMedium,
                                    ),
                                    error: (_, __) => Text(
                                      '-',
                                      style: textTheme.displayMedium,
                                    ),
                                    loading: () =>
                                        const CircularProgressIndicator(),
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
                                  const SizedBox(height: 6),
                                  completedCallsAsync.when(
                                    data: (count) => Text(
                                      count.toString(),
                                      style: textTheme.displayMedium,
                                    ),
                                    loading: () =>
                                        const CircularProgressIndicator(),
                                    error: (_, __) => Text(
                                      '-',
                                      style: textTheme.displayMedium,
                                    ),
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
                            const SizedBox(height: 2),
                            Divider(
                              color: colorScheme.primary.withOpacity(0.25),
                            ),

                            // Mostrar las llamadas o el mensaje de vacío
                            callsTodayAsync.when(
                              data: (calls) {
                                // Si no hay llamadas, mostramos el icono y mensaje
                                if (calls.isEmpty) {
                                  return SizedBox(
                                    height: 120,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.phone_in_talk,
                                            size: 48,
                                            color: colorScheme.primary
                                                .withOpacity(0.25),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            l10n.nothingTodayCalls,
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: colorScheme.onSurface
                                                      .withOpacity(0.6),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                // Si hay llamadas, las mostramos en cards
                                return Column(
                                  children: calls
                                      .map(
                                        (call) => Card(
                                          margin: const EdgeInsets.only(
                                            top: 8.0,
                                            bottom: 2.0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Nombre del paciente
                                                if (call.usuarioNombre != null)
                                                  Text(
                                                    '${call.usuarioNombre}${call.usuarioApellidos != null ? ' ${call.usuarioApellidos}' : ''}',
                                                    style: textTheme.titleMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 16,
                                                        ),
                                                  ),
                                                if (call.usuarioNombre != null)
                                                  const SizedBox(height: 4),

                                                // Nombre del grupo
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.group,
                                                      size: 16,
                                                      color: colorScheme
                                                          .onSurface
                                                          .withOpacity(0.6),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      call.grupoNombre ??
                                                          'Sin grupo',
                                                      style: textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            color: colorScheme
                                                                .onSurface
                                                                .withOpacity(
                                                                  0.7,
                                                                ),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),

                                                // Hora
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.access_time,
                                                      size: 16,
                                                      color: colorScheme
                                                          .onSurface
                                                          .withOpacity(0.6),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      call.hora,
                                                      style: textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            color: colorScheme
                                                                .onSurface
                                                                .withOpacity(
                                                                  0.7,
                                                                ),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),

                                                // Badge de estado con color
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: _getEstadoColor(
                                                        call.estado,
                                                        isDark:
                                                            Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.dark,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      _getEstadoTexto(
                                                        call.estado,
                                                        l10n,
                                                      ),
                                                      style: textTheme.bodySmall
                                                          ?.copyWith(
                                                            color: _getEstadoTextColor(
                                                              call.estado,
                                                              isDark:
                                                                  Theme.of(
                                                                    context,
                                                                  ).brightness ==
                                                                  Brightness
                                                                      .dark,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                );
                              },
                              loading: () => const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              error: (_, __) => Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(l10n.errorCallsLoading),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

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
                            //divisor
                            const SizedBox(height: 2),
                            Divider(
                              color: colorScheme.primary.withOpacity(0.25),
                            ),

                            recentCallsAsync.when(
                              data: (calls) {
                                // Si no hay actividad reciente, mostramos el icono y mensaje
                                if (calls.isEmpty) {
                                  return SizedBox(
                                    height: 120,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.electric_bolt,
                                            size: 48,
                                            color: colorScheme.primary
                                                .withOpacity(0.25),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            l10n.nothingActivityRecent,
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: colorScheme.onSurface
                                                      .withOpacity(0.6),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                // Si hay actividad, la mostramos en cards
                                return Column(
                                  children: calls
                                      .map(
                                        (call) => Card(
                                          margin: const EdgeInsets.only(
                                            top: 8.0,
                                            bottom: 2.0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Nombre del paciente
                                                if (call.usuarioNombre != null)
                                                  Text(
                                                    '${call.usuarioNombre}${call.usuarioApellidos != null ? ' ${call.usuarioApellidos}' : ''}',
                                                    style: textTheme.titleMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 16,
                                                        ),
                                                  ),
                                                if (call.usuarioNombre != null)
                                                  const SizedBox(height: 4),

                                                // Nombre del grupo
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.group,
                                                      size: 16,
                                                      color: colorScheme
                                                          .onSurface
                                                          .withOpacity(0.6),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      call.grupoNombre ??
                                                          'Sin grupo',
                                                      style: textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            color: colorScheme
                                                                .onSurface
                                                                .withOpacity(
                                                                  0.7,
                                                                ),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),

                                                // Hora
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.access_time,
                                                      size: 16,
                                                      color: colorScheme
                                                          .onSurface
                                                          .withOpacity(0.6),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      call.hora,
                                                      style: textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            color: colorScheme
                                                                .onSurface
                                                                .withOpacity(
                                                                  0.7,
                                                                ),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),

                                                // Badge de estado con color
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: _getEstadoColor(
                                                        call.estado,
                                                        isDark:
                                                            Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.dark,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      _getEstadoTexto(
                                                        call.estado,
                                                        l10n,
                                                      ),
                                                      style: textTheme.bodySmall
                                                          ?.copyWith(
                                                            color: _getEstadoTextColor(
                                                              call.estado,
                                                              isDark:
                                                                  Theme.of(
                                                                    context,
                                                                  ).brightness ==
                                                                  Brightness
                                                                      .dark,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                );
                              },
                              loading: () => const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              error: (_, __) => Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(l10n.errorLoadingActivity),
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
    );
  }

  // -------- FUNCIONES HELPER PARA COLORES DE ESTADO --------
  // Obtiene el texto formateado del estado
  String _getEstadoTexto(String? estado, AppLocalizations l10n) {
    if (estado == null || estado.trim().isEmpty) return l10n.noStatus;
    final upper = estado.trim().toUpperCase();
    switch (upper) {
      case 'COMPLETADA':
      case 'COMPLETED':
        return l10n.callCompleted;
      case 'PENDIENTE':
      case 'PENDING':
        return l10n.callPending;
      case 'CANCELADA':
      case 'CANCELLED':
      case 'CANCELED':
        return l10n.callCancelled;
      case 'NO_CONTESTO':
      case 'NO_ANSWER':
        return l10n.callNoAnswer;
      default:
        // Consider if a default localization string is better than raw `estado.trim()`
        return estado.trim();
    }
  }

  // Obtiene el color de fondo según el estado
  Color _getEstadoColor(String? estado, {required bool isDark}) {
    if (estado == null || estado.trim().isEmpty) {
      return isDark ? Colors.grey[800]! : Colors.grey[300]!;
    }
    final upper = estado.trim().toUpperCase();
    switch (upper) {
      case 'COMPLETADA':
      case 'COMPLETED':
        // Verde para completadas
        return isDark ? AppPalette.successDark : AppPalette.successLight;
      case 'PENDIENTE':
      case 'PENDING':
        // Naranja/amarillo para pendientes
        return isDark ? AppPalette.warningDark : AppPalette.warningLight;
      case 'CANCELADA':
      case 'CANCELLED':
      case 'CANCELED':
        // Gris para canceladas
        return isDark ? Colors.grey[800]! : Colors.grey[300]!;
      case 'NO_CONTESTO':
      case 'NO_ANSWER':
        // Rojo para no contestó
        return isDark ? AppPalette.errorDark : AppPalette.errorLight;
      default:
        return isDark ? Colors.grey[800]! : Colors.grey[300]!;
    }
  }

  // Obtiene el color del texto según el estado
  Color _getEstadoTextColor(String? estado, {required bool isDark}) {
    if (estado == null || estado.trim().isEmpty) {
      return isDark ? Colors.grey[300]! : Colors.grey[700]!;
    }
    final upper = estado.trim().toUpperCase();
    switch (upper) {
      case 'COMPLETADA':
      case 'COMPLETED':
        return isDark
            ? AppPalette.successFontDark
            : AppPalette.successFontLight;
      case 'PENDIENTE':
      case 'PENDING':
        return isDark
            ? AppPalette.warningFontDark
            : AppPalette.warningFontLight;
      case 'CANCELADA':
      case 'CANCELLED':
      case 'CANCELED':
        return isDark ? Colors.grey[300]! : Colors.grey[700]!;
      case 'NO_CONTESTO':
      case 'NO_ANSWER':
        return isDark ? AppPalette.errorFontDark : AppPalette.errorFontLight;
      default:
        return isDark ? Colors.grey[300]! : Colors.grey[700]!;
    }
  }

  // -------- DIÁLOGO DE NOTIFICACIONES --------
  // Función que muestra una ventana flotante con todas las notificaciones
  void showNotificacionesDialog(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final notificacionesAsync = ref.watch(notificacionesProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.notifications),
        content: SizedBox(
          width: double.maxFinite,
          child: notificacionesAsync.when(
            data: (notificaciones) {
              if (notificaciones.isEmpty) {
                return Text(l10n.noNotifications);
              }

              // Separar notificaciones por estado
              final sinLeer = notificaciones.where((n) => n.esSinLeer).toList();
              final leidas = notificaciones.where((n) => n.esLeida).toList();

              return ListView(
                shrinkWrap: true,
                children: [
                  // Sección de NO LEÍDAS
                  if (sinLeer.isNotEmpty) ...[
                    Text(
                      l10n.unread,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...sinLeer.map(
                      (notif) => ListTile(
                        leading: const Icon(
                          Icons.mark_email_unread,
                          color: Colors.blue,
                        ),
                        title: Text(notif.contenido),
                      ),
                    ),
                    const Divider(),
                  ],

                  // Sección de LEÍDAS
                  if (leidas.isNotEmpty) ...[
                    Text(
                      l10n.read,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...leidas.map(
                      (notif) => ListTile(
                        leading: const Icon(Icons.drafts, color: Colors.grey),
                        title: Text(
                          notif.contenido,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Text(l10n.errorNotificationsLoading),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}
