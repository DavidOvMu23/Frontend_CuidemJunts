// Librería principal de Flutter para construir la interfaz visual.
import 'package:flutter/material.dart';
// Constantes globales de la app (puntos de ruptura de pantalla, roles…).
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';

// Riverpod: permite leer datos del estado global (llamadas, usuario…).
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Pantallas a las que se puede navegar desde el menú lateral.
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/emergency_contacts_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/grupos_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
// Widgets reutilizables: appbar, drawer, botones, snackbars…
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
// Menú lateral (drawer) del supervisor con todas las secciones.
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
// Sistema de traducciones de la app.
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/calls_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/notifications_page.dart';
// Provider con el estado del usuario autenticado (nombre, rol…).
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
// Provider con los datos de las llamadas (programadas, completadas, todas).
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/llamadas_provider.dart';
// Provider con el contador de notificaciones sin leer.
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';

// Widgets especializados que componen el cuerpo de esta pantalla.
import 'package:frontend_cuidemjunts/features/auth/presentation/home/widgets/stats_card.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/home/widgets/today_calls_section.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/home/widgets/monthly_calendar_section.dart';

// -------- PANTALLA PRINCIPAL DEL SUPERVISOR --------
// Es la primera pantalla que ve el supervisor después de hacer login.
// Muestra estadísticas de llamadas del día, la lista de llamadas de hoy
// y un calendario mensual con todas las llamadas.
//
// El parámetro [embedded] indica si esta pantalla se muestra dentro del
// shell (con barra lateral ya visible) o de forma independiente con su
// propio AppBar y Drawer. Por eso hay dos caminos al final del build().
class HomeSupervisorPage extends ConsumerWidget {
  // Si embedded es true, esta pantalla se inserta dentro de SupervisorShellPage
  // y no necesita su propio AppBar ni Drawer (ya los tiene el shell).
  final bool embedded;

  const HomeSupervisorPage({
    super.key,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // -------- TEXTOS TRADUCIDOS --------
    // Obtenemos los textos en el idioma que tenga activo el usuario.
    final l10n = AppLocalizations.of(context)!;

    // -------- PROVIDERS DE LLAMADAS --------
    // Cada uno devuelve un AsyncValue (puede estar cargando, tener datos o tener error).
    // scheduledCallsTodayProvider: número de llamadas programadas para hoy.
    final scheduledCallsAsync = ref.watch(scheduledCallsTodayProvider);
    // completedCallsTodayProvider: número de llamadas ya completadas hoy.
    final completedCallsAsync = ref.watch(completedCallsTodayProvider);
    // callsTodayProvider: lista completa de llamadas de hoy (para la sección de hoy).
    final callsTodayAsync = ref.watch(callsTodayProvider);
    // llamadasProvider: todas las llamadas (para el calendario mensual).
    final allCallsAsync = ref.watch(llamadasProvider);

    // -------- CONTADOR DE NOTIFICACIONES SIN LEER --------
    // Se usa para mostrar el número rojo encima del icono de la campana.
    final notificacionesSinLeerAsync = ref.watch(notificacionesSinLeerProvider);

    // -------- DATOS DEL USUARIO AUTENTICADO --------
    // Leemos el estado de autenticación para obtener nombre y rol.
    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
    final userRole = authState.rol;

    // Si no hay usuario logueado (por ejemplo, la sesión expiró), mostramos un aviso.
    if (userName == null) {
      return Scaffold(
        body: Center(child: Text(l10n.noAuthenticatedUser)),
      );
    }

    // -------- DETECCIÓN DE TAMAÑO DE PANTALLA --------
    // Usamos el ancho de la pantalla para decidir si usar el diseño de escritorio o móvil.
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppBreakpoints.desktop;
    // Margen horizontal: más amplio en escritorio para aprovechar el espacio.
    final horizontalPadding = isDesktop ? 20.0 : 12.0;

    // -------- FUNCIÓN: FILA DE TARJETAS DE ESTADÍSTICAS --------
    // Muestra dos tarjetas: "Llamadas programadas" y "Llamadas completadas".
    // En escritorio las coloca en fila; en móvil las apila en columna.
    Widget buildStatsRow(bool desktopMode) {
      if (desktopMode) {
        // En escritorio: las dos tarjetas una al lado de la otra.
        return Row(
          children: [
            Expanded(
              child: scheduledCallsAsync.when(
                // Cuando los datos están listos, mostramos el número real.
                data: (count) => StatsCard(
                  title: l10n.programedCalls,
                  value: count.toString(),
                  icon: Icons.today,
                ),
                // Mientras carga, mostramos un guion y el estado de carga.
                loading: () => StatsCard(
                  title: l10n.programedCalls,
                  value: '-',
                  icon: Icons.today,
                  isLoading: true,
                ),
                // Si falla, mostramos guion sin indicador de carga.
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
      }

      // En móvil: las dos tarjetas una encima de la otra.
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

    // -------- FUNCIÓN: CUERPO EN MÓVIL --------
    // Muestra las tarjetas, las llamadas de hoy y el calendario en columna desplazable.
    // RefreshIndicator permite refrescar los datos tirando hacia abajo.
    Widget buildMobileBody() {
      return RefreshIndicator(
        onRefresh: () async {
          // Invalidamos el provider para que vuelva a pedir datos al servidor.
          ref.invalidate(llamadasProvider);
          await ref.read(llamadasProvider.future);
        },
        child: SingleChildScrollView(
          // AlwaysScrollableScrollPhysics permite el gesto de refrescar incluso cuando
          // el contenido es más corto que la pantalla.
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarjetas de estadísticas del día.
              buildStatsRow(false),
              const SizedBox(height: 20),
              // Sección con la lista de llamadas programadas para hoy.
              TodayCallsSection(callsAsync: callsTodayAsync),
              const SizedBox(height: 20),
              // Sección con el calendario del mes y sus llamadas.
              MonthlyCalendarSection(callsAsync: allCallsAsync),
            ],
          ),
        ),
      );
    }

    // -------- FUNCIÓN: CUERPO EN ESCRITORIO --------
    // Usa LayoutBuilder para calcular cuánto espacio queda y dividirlo en dos columnas:
    // izquierda → llamadas de hoy; derecha → calendario mensual.
    Widget buildDesktopBody() {
      return Padding(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 24, horizontalPadding, 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Altura disponible del área de contenido.
            final availableHeight = constraints.maxHeight;
            // Calculamos la altura de la sección inferior restando el espacio
            // de las tarjetas (120) y los márgenes (20 + 12), con un mínimo de 320.
            final lowerSectionHeight = (availableHeight - 20 - 120 - 12).clamp(320.0, availableHeight);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila de tarjetas de estadísticas en modo escritorio (horizontal).
                buildStatsRow(true),
                const SizedBox(height: 20),
                // Sección inferior con altura calculada y dos columnas.
                SizedBox(
                  height: lowerSectionHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Columna izquierda: llamadas de hoy con contenido expandido.
                      Expanded(
                        child: TodayCallsSection(
                          callsAsync: callsTodayAsync,
                          expandContent: true,
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Columna derecha: calendario mensual con contenido expandido.
                      Expanded(
                        child: MonthlyCalendarSection(
                          callsAsync: allCallsAsync,
                          expandContent: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    // Elegimos el cuerpo correcto según el tamaño de pantalla.
    final mainContent = isDesktop ? buildDesktopBody() : buildMobileBody();

    // -------- MODO EMBEBIDO --------
    // Si embedded es true, solo devolvemos el contenido sin Scaffold propio,
    // porque SupervisorShellPage ya proporciona el marco visual completo.
    if (embedded) {
      return mainContent;
    }

    // -------- MODO INDEPENDIENTE (con su propio AppBar y Drawer) --------
    return Scaffold(
      // -------- BARRA SUPERIOR (AppBar) --------
      // Muestra el logo de la app, el título y un icono de notificaciones
      // con el número de notificaciones sin leer encima.
      appBar: appMainAppBar(
        numeroNotificaciones: notificacionesSinLeerAsync.when(
          data: (count) => count,
          loading: () => 0,
          error: (_, __) => 0,
        ),
        // Al pulsar la campana, navegamos a la pantalla de notificaciones.
        onNotifications: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsPage()),
          );
        },
        context: context,
      ),

      // -------- MENÚ LATERAL (Drawer) --------
      // Panel que se abre deslizando desde la izquierda (o pulsando el icono de menú).
      // Muestra el nombre del usuario y enlaces a todas las secciones de la app.
      drawer: appDrawer(
        context: context,
        userName: userName,
        userRole: userRole,
        // Marca "Inicio" como la sección actualmente seleccionada (resaltado en el menú).
        selected: DrawerItem.home,
        // Cada onTap navega a la sección correspondiente.
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
        onTapGroups: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GruposPage()),
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
        // -------- CERRAR SESIÓN --------
        onLogoutConfirmed: () async {
          // Borramos el token y los datos del usuario del estado global.
          await ref.read(authProvider.notifier).logout();

          // Navegamos al login y eliminamos TODAS las pantallas anteriores del stack.
          // Así el usuario no puede volver atrás con el botón "atrás" del dispositivo.
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false, // false = elimina todas las rutas anteriores
          );
        },
      ),

      // -------- CUERPO PRINCIPAL --------
      body: mainContent,
    );
  }
}
