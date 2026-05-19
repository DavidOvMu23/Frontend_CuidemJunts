// Librería principal de Flutter para construir la interfaz visual.
import 'package:flutter/material.dart';
// Constantes globales de la app (puntos de ruptura de pantalla, estados de llamada…).
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';

// Riverpod: permite leer datos del estado global (llamadas, usuario…).
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Sistema de traducciones de la app.
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
// Tarjeta de estadística reutilizable (muestra un número con título e icono).
import 'package:frontend_cuidemjunts/features/auth/presentation/home/widgets/stats_card.dart';
// Sección que muestra la lista de llamadas del día.
import 'package:frontend_cuidemjunts/features/auth/presentation/home/widgets/today_calls_section.dart';
// Provider con el estado del usuario autenticado (nombre, id, grupoId…).
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
// Provider con todas las llamadas del sistema.
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/llamadas_provider.dart';
// Provider con el contador de notificaciones sin leer.
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';

// -------- PANTALLA PRINCIPAL DEL OPERADOR (TELEOPERADOR) --------
// Esta pantalla es la "home" de un teleoperador (no supervisor).
// Muestra un saludo personalizado, las estadísticas de sus llamadas del día
// y la lista de las llamadas que tiene asignadas para hoy.
//
// A diferencia del supervisor, el operador solo ve SUS llamadas, no las de todos.
// El parámetro [embedded] funciona igual que en HomeSupervisorPage:
// si es true, se muestra dentro del shell; si es false, se muestra de forma autónoma.
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
    // ID del teleoperador: lo usamos para filtrar solo sus llamadas.
    final teleoperadorId = authState.id;

    // Si no hay usuario logueado, mostramos un aviso.
    if (userName == null) {
      return Scaffold(body: Center(child: Text(l10n.noAuthenticatedUser)));
    }

    // -------- TODAS LAS LLAMADAS DEL SISTEMA --------
    // Cargamos todas las llamadas para filtrar las de este teleoperador.
    final allCallsAsync = ref.watch(llamadasProvider);
    // Contador de notificaciones sin leer para el badge de la campana.
    final notificacionesSinLeerAsync = ref.watch(notificacionesSinLeerProvider);

    // Fecha de hoy, para comparar con la fecha de cada llamada.
    final now = DateTime.now();

    // -------- FILTRADO: LLAMADAS DE HOY DEL TELEOPERADOR --------
    // whenData transforma el valor de un AsyncValue (si hay datos) sin tocar los estados
    // de carga/error. Aquí filtramos para quedarnos solo con las llamadas de hoy
    // que pertenecen a este teleoperador.
    final misLlamadasHoyAsync = allCallsAsync.whenData((calls) {
      return calls.where((c) {
        // Comprobamos si la llamada es del día de hoy.
        final esHoy = c.fecha.year == now.year &&
            c.fecha.month == now.month &&
            c.fecha.day == now.day;
        // Si la llamada tiene teleoperador asignado, solo la mostramos si somos nosotros.
        // Si no tiene asignado (datos antiguos sin este campo), la mostramos igualmente.
        final esMia = c.teleoperadorId == null || c.teleoperadorId == teleoperadorId;
        return esHoy && esMia;
      }).toList();
    });

    // -------- CONTEO: LLAMADAS PENDIENTES DE HOY --------
    // A partir de las llamadas ya filtradas, contamos cuántas están en estado "pendiente".
    final pendientesHoyAsync = misLlamadasHoyAsync.whenData(
      (calls) => calls.where((c) => c.estado.toLowerCase() == CallStatus.pendiente).length,
    );

    // -------- CONTEO: LLAMADAS COMPLETADAS DE HOY --------
    // Igual, pero contamos las que ya se han completado.
    final completadasHoyAsync = misLlamadasHoyAsync.whenData(
      (calls) => calls.where((c) => c.estado.toLowerCase() == CallStatus.completada).length,
    );

    // -------- NÚMERO DE NOTIFICACIONES SIN LEER --------
    // Extraemos el valor numérico del AsyncValue para usarlo directamente.
    final unreadCount = notificacionesSinLeerAsync.when(
      data: (c) => c,
      loading: () => 0,
      error: (_, __) => 0,
    );

    // -------- DETECCIÓN DE TAMAÑO DE PANTALLA --------
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppBreakpoints.desktop;
    final horizontalPadding = isDesktop ? 20.0 : 12.0;
    // Estilos de texto y colores del tema activo.
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // -------- FUNCIÓN: FILA DE TARJETAS DE ESTADÍSTICAS --------
    // Construye las dos tarjetas (pendientes y completadas).
    // En escritorio, en fila; en móvil, en columna.
    Widget buildStatsRow() {
      // Tarjeta de llamadas pendientes (programadas pero aún sin realizar).
      final pendCard = pendientesHoyAsync.when(
        data: (n) => StatsCard(title: l10n.programedCalls, value: n.toString(), icon: Icons.pending_actions),
        loading: () => StatsCard(title: l10n.programedCalls, value: '-', icon: Icons.pending_actions, isLoading: true),
        error: (_, __) => StatsCard(title: l10n.programedCalls, value: '-', icon: Icons.pending_actions),
      );

      // Tarjeta de llamadas completadas hoy.
      final compCard = completadasHoyAsync.when(
        data: (n) => StatsCard(title: l10n.completedCalls, value: n.toString(), icon: Icons.check_circle_outline),
        loading: () => StatsCard(title: l10n.completedCalls, value: '-', icon: Icons.check_circle_outline, isLoading: true),
        error: (_, __) => StatsCard(title: l10n.completedCalls, value: '-', icon: Icons.check_circle_outline),
      );

      // En escritorio, las dos tarjetas van en fila horizontal.
      if (isDesktop) {
        return Row(children: [
          Expanded(child: pendCard),
          const SizedBox(width: 16),
          Expanded(child: compCard),
        ]);
      }
      // En móvil, una encima de la otra.
      return Column(children: [
        pendCard,
        const SizedBox(height: 12),
        compCard,
      ]);
    }

    // -------- CUERPO PRINCIPAL DE LA PANTALLA --------
    final body = Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: RefreshIndicator(
        // Al tirar hacia abajo, recargamos todas las llamadas desde el servidor.
        onRefresh: () async {
          ref.invalidate(llamadasProvider);
          await ref.read(llamadasProvider.future);
        },
        child: SingleChildScrollView(
          // AlwaysScrollableScrollPhysics permite el gesto de refrescar siempre.
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // -------- TARJETA DE SALUDO PERSONALIZADO --------
              // Muestra el avatar del teleoperador, su nombre y su grupo.
              // Si tiene notificaciones sin leer, aparece un badge con el número.
              Material(
                color: colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Avatar circular con un icono de agente de soporte.
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: colorScheme.primary,
                        child: Icon(Icons.support_agent_rounded, color: colorScheme.onPrimary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      // Nombre del teleoperador y, si está en un grupo, el ID del grupo.
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Saludo con la primera palabra del texto de bienvenida + nombre.
                            Text(
                              '${l10n.welcome.split(' ').first}, $userName',
                              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            // Solo mostramos el grupo si el teleoperador tiene uno asignado.
                            if (authState.grupoId != null)
                              Text(
                                '${l10n.group_label}: ${authState.grupoId}',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Badge de notificaciones: solo aparece si hay alguna sin leer.
                      if (unreadCount > 0)
                        Badge(
                          label: Text(unreadCount.toString()),
                          child: Icon(Icons.notifications_outlined, color: colorScheme.primary),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // -------- TARJETAS DE ESTADÍSTICAS DEL DÍA --------
              buildStatsRow(),

              const SizedBox(height: 16),

              // -------- LISTA DE LLAMADAS DE HOY --------
              // Altura fija de 400 píxeles para que no ocupe toda la pantalla.
              // showQuickActions: true permite realizar acciones rápidas desde aquí
              // (marcar como completada, posponer, etc.).
              SizedBox(
                height: 400,
                child: TodayCallsSection(
                  callsAsync: misLlamadasHoyAsync, // Solo las llamadas de este teleoperador.
                  expandContent: true,
                  showQuickActions: true,
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );

    // -------- MODO EMBEBIDO O INDEPENDIENTE --------
    // Si embedded es true, devolvemos solo el contenido (el shell ya tiene el marco).
    if (embedded) return body;

    // Si es independiente, envolvemos en un Scaffold básico.
    return Scaffold(body: body);
  }
}
