// Librería principal de Flutter para construir la interfaz visual.
import 'package:flutter/material.dart';
// Constantes globales de la app (puntos de ruptura de pantalla, estados de llamada…).
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';

// Riverpod: permite leer datos del estado global (llamadas, usuario…).
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Modelo de una llamada para tipar correctamente los listados filtrados.
import 'package:frontend_cuidemjunts/features/auth/data/models/llamadas.dart';
// Sistema de traducciones de la app.
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
// Tarjeta de estadística reutilizable (muestra un número con título e icono).
import 'package:frontend_cuidemjunts/features/auth/presentation/home/widgets/stats_card.dart';
// Sección que muestra la lista de llamadas del día.
import 'package:frontend_cuidemjunts/features/auth/presentation/home/widgets/today_calls_section.dart';
// Sección del calendario mensual con todas las llamadas marcadas por día.
import 'package:frontend_cuidemjunts/features/auth/presentation/home/widgets/monthly_calendar_section.dart';
// Provider con el estado del usuario autenticado (nombre, id, grupoId…).
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
// Provider con todas las llamadas del sistema.
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/llamadas_provider.dart';

// -------- PANTALLA PRINCIPAL DEL TELEOPERADOR --------
// Imita la pantalla de inicio del supervisor (HomeSupervisorPage) pero filtrando
// para que el teleoperador solo vea SUS llamadas:
//   - dos tarjetas de estadísticas (pendientes / completadas hoy),
//   - lista de sus llamadas de hoy con acciones rápidas,
//   - calendario mensual con sus llamadas marcadas.
class HomeOperadorPage extends ConsumerWidget {
  // Si embedded es true, esta pantalla se inserta dentro de SupervisorShellPage.
  final bool embedded;

  const HomeOperadorPage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Textos en el idioma activo del usuario.
    final l10n = AppLocalizations.of(context)!;

    // -------- DATOS DEL USUARIO AUTENTICADO --------
    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
    // El teleoperador ve todas las llamadas asignadas a su grupo.
    final grupoId = authState.grupoId;

    // Si no hay usuario logueado, mostramos un aviso.
    if (userName == null) {
      return Scaffold(body: Center(child: Text(l10n.noAuthenticatedUser)));
    }

    // -------- TODAS LAS LLAMADAS DEL SISTEMA --------
    final allCallsAsync = ref.watch(llamadasProvider);

    // -------- LLAMADAS DEL GRUPO DEL TELEOPERADOR --------
    // El teleoperador solo ve las llamadas cuyo grupo coincide con el suyo.
    // Si por algún motivo no tiene grupo asignado, no le mostramos nada.
    final misLlamadasAsync = allCallsAsync.whenData((calls) {
      if (grupoId == null || grupoId == 0) return <Llamadas>[];
      return calls.where((c) => c.grupoId == grupoId).toList();
    });

    // -------- LLAMADAS DE HOY DEL TELEOPERADOR --------
    final now = DateTime.now();
    final misLlamadasHoyAsync = misLlamadasAsync.whenData((calls) {
      return calls.where((c) {
        return c.fecha.year == now.year &&
            c.fecha.month == now.month &&
            c.fecha.day == now.day;
      }).toList();
    });

    // -------- CONTADORES DEL DÍA --------
    final pendientesHoyAsync = misLlamadasHoyAsync.whenData(
      (calls) =>
          calls.where((c) => c.estado.toLowerCase() == CallStatus.pendiente).length,
    );
    final completadasHoyAsync = misLlamadasHoyAsync.whenData(
      (calls) =>
          calls.where((c) => c.estado.toLowerCase() == CallStatus.completada).length,
    );

    // -------- DETECCIÓN DE TAMAÑO DE PANTALLA --------
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppBreakpoints.desktop;
    final horizontalPadding = isDesktop ? 20.0 : 12.0;

    // -------- FILA DE TARJETAS DE ESTADÍSTICAS --------
    // Misma estructura que el dashboard del supervisor, pero con los datos
    // filtrados del teleoperador.
    Widget buildStatsRow(bool desktopMode) {
      final pendCard = pendientesHoyAsync.when(
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
      );

      final compCard = completadasHoyAsync.when(
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
      );

      if (desktopMode) {
        return Row(
          children: [
            Expanded(child: pendCard),
            const SizedBox(width: 20),
            Expanded(child: compCard),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pendCard,
          const SizedBox(height: 20),
          compCard,
        ],
      );
    }

    // -------- CUERPO EN MÓVIL --------
    Widget buildMobileBody() {
      return RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(llamadasProvider);
          await ref.read(llamadasProvider.future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildStatsRow(false),
              const SizedBox(height: 20),
              // Lista de llamadas de hoy del teleoperador.
              TodayCallsSection(
                callsAsync: misLlamadasHoyAsync,
              ),
              const SizedBox(height: 20),
              // Calendario mensual mostrando solo las llamadas del teleoperador.
              MonthlyCalendarSection(callsAsync: misLlamadasAsync),
            ],
          ),
        ),
      );
    }

    // -------- CUERPO EN ESCRITORIO --------
    Widget buildDesktopBody() {
      return Padding(
        padding:
            EdgeInsets.fromLTRB(horizontalPadding, 24, horizontalPadding, 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            // Mismo cálculo que el dashboard del supervisor para mantener la
            // proporción visual entre la fila de stats y la sección inferior.
            final lowerSectionHeight =
                (availableHeight - 20 - 120 - 12).clamp(320.0, availableHeight);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildStatsRow(true),
                const SizedBox(height: 20),
                SizedBox(
                  height: lowerSectionHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Izquierda: llamadas de hoy del teleoperador.
                      Expanded(
                        child: TodayCallsSection(
                          callsAsync: misLlamadasHoyAsync,
                          expandContent: true,
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Derecha: calendario mensual con sus llamadas.
                      Expanded(
                        child: MonthlyCalendarSection(
                          callsAsync: misLlamadasAsync,
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

    final mainContent = isDesktop ? buildDesktopBody() : buildMobileBody();

    // -------- MODO EMBEBIDO O INDEPENDIENTE --------
    if (embedded) return mainContent;
    return Scaffold(body: mainContent);
  }
}
