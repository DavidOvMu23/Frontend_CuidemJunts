import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/loading_skeleton.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/llamadas.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/calls/widgets/call_detail_dialog.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/home/widgets/call_card.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/llamadas_provider.dart';

// Sección de la pantalla de inicio que muestra las llamadas programadas para hoy.
// Puede mostrar botones de acción rápida (completar / no contestó) si se activa showQuickActions.
class TodayCallsSection extends ConsumerStatefulWidget {
  // Lista de llamadas de hoy — puede estar cargando, tener error o datos listos
  final AsyncValue<List<Llamadas>> callsAsync;
  // Cuando es true, la lista se expande para ocupar todo el espacio disponible
  final bool expandContent;
  // Cuando es true, cada llamada pendiente muestra botones de acción rápida
  final bool showQuickActions;

  const TodayCallsSection({
    super.key,
    required this.callsAsync,
    this.expandContent = false,
    this.showQuickActions = false,
  });

  @override
  ConsumerState<TodayCallsSection> createState() => _TodayCallsSectionState();
}

class _TodayCallsSectionState extends ConsumerState<TodayCallsSection> {
  // Actualiza el estado de una llamada en el servidor (p. ej. marcarla como completada)
  Future<void> _updateEstado(Llamadas llamada, String nuevoEstado) async {
    final service = ref.read(llamadasServiceProvider);
    try {
      await service.update(llamada.id, {'estado': nuevoEstado});
      // Recargamos los datos para que la pantalla refleje el cambio
      ref.invalidate(llamadasProvider);
    } catch (_) {}
  }

  // Abre el diálogo de detalle de una llamada con opciones de editar y eliminar
  void _openDetail(Llamadas llamada) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => CallDetailDialog(
        llamada: llamada,
        onEdit: () {
          // El diálogo de detalle ya se cerró solo antes de llamar a onEdit
          // Marcamos la llamada para que la pantalla de edición la recoja
          ref.read(pendingCallEditProvider.notifier).set(llamada);
        },
        onDelete: () async {
          final service = ref.read(llamadasServiceProvider);
          final scaffoldMsg = ScaffoldMessenger.of(context);
          final navCtx = Navigator.of(ctx);
          try {
            await service.delete(llamada.id);
            // Invalidamos todos los proveedores relacionados para refrescar los contadores
            ref.invalidate(llamadasProvider);
            ref.invalidate(callsTodayProvider);
            ref.invalidate(scheduledCallsTodayProvider);
            ref.invalidate(completedCallsTodayProvider);
            if (!mounted) return;
            navCtx.pop();
            scaffoldMsg.showSnackBar(SnackBar(content: Text(l10n.callDeletedSuccessfully)));
          } catch (e) {
            if (!mounted) return;
            scaffoldMsg.showSnackBar(SnackBar(
              content: Text(l10n.errorDeletingCall(e.toString())),
              backgroundColor: Theme.of(context).colorScheme.error,
            ));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Construimos el contenido según el estado: cargando, error o datos disponibles
    final content = widget.callsAsync.when(
      data: (calls) {
        // Si no hay llamadas hoy, mostramos un mensaje informativo con icono
        if (calls.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.phone_in_talk,
                  size: 48,
                  color: colorScheme.primary.withValues(alpha: 0.25),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.nothingTodayCalls,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          );
        }

        // Si hay 3 o menos llamadas, usamos ListView.separated para añadir separadores
        if (calls.length <= 3) {
          return ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: calls.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final call = calls[index];
              return CallCard(
                usuarioNombre: call.usuarioNombre,
                usuarioApellidos: call.usuarioApellidos,
                grupoNombre: call.grupoNombre,
                hora: call.hora,
                estado: call.estado,
                onTap: () => _openDetail(call),
                onMarkCompleted: widget.showQuickActions
                    ? () => _updateEstado(call, CallStatus.completada)
                    : null,
                onMarkNoAnswer: widget.showQuickActions
                    ? () => _updateEstado(call, CallStatus.noContesto)
                    : null,
              );
            },
          );
        }

        // Con más de 3 llamadas, usamos ListView.builder (más eficiente para listas largas)
        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          // En modo expandido se puede hacer scroll dentro de la sección; si no, la lista es fija
          physics: widget.expandContent ? const ClampingScrollPhysics() : const NeverScrollableScrollPhysics(),
          itemCount: calls.length,
          itemBuilder: (context, index) {
            final call = calls[index];
            return Padding(
              padding: EdgeInsets.only(bottom: index == calls.length - 1 ? 0 : 10),
              child: CallCard(
                usuarioNombre: call.usuarioNombre,
                usuarioApellidos: call.usuarioApellidos,
                grupoNombre: call.grupoNombre,
                hora: call.hora,
                estado: call.estado,
                onTap: () => _openDetail(call),
                onMarkCompleted: widget.showQuickActions
                    ? () => _updateEstado(call, CallStatus.completada)
                    : null,
                onMarkNoAnswer: widget.showQuickActions
                    ? () => _updateEstado(call, CallStatus.noContesto)
                    : null,
              ),
            );
          },
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 10),
        child: Column(
          children: [
            AppSkeletonCard(height: 118),
            SizedBox(height: 10),
            AppSkeletonCard(height: 118),
          ],
        ),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(l10n.errorCallsLoading),
      ),
    );

    return Material(
      color: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.todayCalls,
              style: textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Divider(color: colorScheme.primary.withValues(alpha: 0.25)),
            if (widget.expandContent)
              Expanded(child: content)
            else
              content,
            if (!widget.expandContent) const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
