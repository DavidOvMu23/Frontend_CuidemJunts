import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/home/widgets/stats_card.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/home/widgets/today_calls_section.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/llamadas_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';
class HomeOperadorPage extends ConsumerWidget {
  final bool embedded;

  const HomeOperadorPage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
    final teleoperadorId = authState.id;

    if (userName == null) {
      return Scaffold(body: Center(child: Text(l10n.noAuthenticatedUser)));
    }

    // Filtrar llamadas de hoy que pertenezcan a este teleoperador
    final allCallsAsync = ref.watch(llamadasProvider);
    final notificacionesSinLeerAsync = ref.watch(notificacionesSinLeerProvider);

    final now = DateTime.now();

    final misLlamadasHoyAsync = allCallsAsync.whenData((calls) {
      return calls.where((c) {
        final esHoy = c.fecha.year == now.year &&
            c.fecha.month == now.month &&
            c.fecha.day == now.day;
        // Si la llamada tiene teleoperador asignado, solo mostrarla si es este tele.
        // Si no tiene (datos legacy), mostrarla igualmente.
        final esMia = c.teleoperadorId == null || c.teleoperadorId == teleoperadorId;
        return esHoy && esMia;
      }).toList();
    });

    final pendientesHoyAsync = misLlamadasHoyAsync.whenData(
      (calls) => calls.where((c) => c.estado.toLowerCase() == 'pendiente').length,
    );

    final completadasHoyAsync = misLlamadasHoyAsync.whenData(
      (calls) => calls.where((c) => c.estado.toLowerCase() == 'completada').length,
    );

    final unreadCount = notificacionesSinLeerAsync.when(
      data: (c) => c,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final horizontalPadding = isDesktop ? 20.0 : 12.0;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    Widget buildStatsRow() {
      final pendCard = pendientesHoyAsync.when(
        data: (n) => StatsCard(title: l10n.programedCalls, value: n.toString(), icon: Icons.pending_actions),
        loading: () => StatsCard(title: l10n.programedCalls, value: '-', icon: Icons.pending_actions, isLoading: true),
        error: (_, __) => StatsCard(title: l10n.programedCalls, value: '-', icon: Icons.pending_actions),
      );

      final compCard = completadasHoyAsync.when(
        data: (n) => StatsCard(title: l10n.completedCalls, value: n.toString(), icon: Icons.check_circle_outline),
        loading: () => StatsCard(title: l10n.completedCalls, value: '-', icon: Icons.check_circle_outline, isLoading: true),
        error: (_, __) => StatsCard(title: l10n.completedCalls, value: '-', icon: Icons.check_circle_outline),
      );

      if (isDesktop) {
        return Row(children: [
          Expanded(child: pendCard),
          const SizedBox(width: 16),
          Expanded(child: compCard),
        ]);
      }
      return Column(children: [
        pendCard,
        const SizedBox(height: 12),
        compCard,
      ]);
    }

    final body = Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(llamadasProvider);
          await ref.read(llamadasProvider.future);
        },
        child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Saludo personalizado
            Material(
              color: colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: colorScheme.primary,
                      child: Icon(Icons.support_agent_rounded, color: colorScheme.onPrimary, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.welcome.split(' ').first}, $userName',
                            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
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

            // Estadísticas del día
            buildStatsRow(),

            const SizedBox(height: 16),

            // Llamadas de hoy
            SizedBox(
              height: 400,
              child: TodayCallsSection(
                callsAsync: misLlamadasHoyAsync,
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

    if (embedded) return body;

    return Scaffold(body: body);
  }
}
