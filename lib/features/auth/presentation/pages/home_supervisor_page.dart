import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/emergency_contacts_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/calls_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/notifications_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/llamadas_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';

import 'package:frontend_cuidemjunts/features/auth/presentation/home/widgets/stats_card.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/home/widgets/today_calls_section.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/home/widgets/recent_activity_section.dart';

// -------- PANTALLA PRINCIPAL DEL SUPERVISOR --------
// Es la primera pantalla que ve el supervisor al entrar.
// Ahora usa Riverpod para acceder al estado global.
class HomeSupervisorPage extends ConsumerWidget {
  final bool embedded;

  const HomeSupervisorPage({
    super.key,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // -------- TEMAS, COLORES Y TEXTOS --------
    // Textos traducidos (según el idioma seleccionado en la app).
    final l10n = AppLocalizations.of(context)!;

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
    final userName = authState.nombre;
    final userRole = authState.rol;

    // Si no hay usuario logueado, mostrar un mensaje
    if (userName == null) {
      return const Scaffold(
        body: Center(child: Text('No hay usuario autenticado')),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final horizontalPadding = isDesktop ? 20.0 : 12.0;

    final mainContent = Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contenido scrolleable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // -------- TARJETAS DE ESTADÍSTICAS --------
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 1080;
                        if (isDesktop) {
                          return Row(
                            children: [
                              Expanded(
                                child: scheduledCallsAsync.when(
                                  data: (count) => StatsCard(
                                    title: l10n.programedCalls,
                                    value: count.toString(),
                                    icon: Icons.today,
                                  ),
                                  loading: () => StatsCard(
                                    title: l10n.programedCalls,
                                    value: '-',
                                    icon: Icons.today,
                                    isLoading: true,
                                  ),
                                  error: (_, __) => StatsCard(
                                    title: l10n.programedCalls,
                                    value: '-',
                                    icon: Icons.today,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: completedCallsAsync.when(
                                  data: (count) => StatsCard(
                                    title: l10n.completedCalls,
                                    value: count.toString(),
                                    icon: Icons.phone,
                                  ),
                                  loading: () => StatsCard(
                                    title: l10n.completedCalls,
                                    value: '-',
                                    icon: Icons.phone,
                                    isLoading: true,
                                  ),
                                  error: (_, __) => StatsCard(
                                    title: l10n.completedCalls,
                                    value: '-',
                                    icon: Icons.phone,
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              scheduledCallsAsync.when(
                                data: (count) => StatsCard(
                                  title: l10n.programedCalls,
                                  value: count.toString(),
                                  icon: Icons.today,
                                ),
                                loading: () => StatsCard(
                                  title: l10n.programedCalls,
                                  value: '-',
                                  icon: Icons.today,
                                  isLoading: true,
                                ),
                                error: (_, __) => StatsCard(
                                  title: l10n.programedCalls,
                                  value: '-',
                                  icon: Icons.today,
                                ),
                              ),
                              const SizedBox(height: 20),
                              completedCallsAsync.when(
                                data: (count) => StatsCard(
                                  title: l10n.completedCalls,
                                  value: count.toString(),
                                  icon: Icons.phone,
                                ),
                                loading: () => StatsCard(
                                  title: l10n.completedCalls,
                                  value: '-',
                                  icon: Icons.phone,
                                  isLoading: true,
                                ),
                                error: (_, __) => StatsCard(
                                  title: l10n.completedCalls,
                                  value: '-',
                                  icon: Icons.phone,
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 20),
                    // -------- LLAMADAS DE HOY --------
                    TodayCallsSection(callsAsync: callsTodayAsync),

                    const SizedBox(height: 20),
                    // -------- ACTIVIDAD RECIENTE --------
                    RecentActivitySection(callsAsync: recentCallsAsync),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

    // -------- ESTRUCTURA DE LA PANTALLA --------
    if (embedded) {
      return mainContent;
    }

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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsPage()),
          );
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
        onTapEmergencyContacts: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EmergencyContactsPage(),
            ),
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
        onTapNotifications: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsPage()),
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
      body: mainContent,
    );
  }
}
