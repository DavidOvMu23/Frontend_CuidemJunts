import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/loading_skeleton.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/llamadas.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/calls/widgets/call_detail_dialog.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/home/widgets/call_card.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/llamadas_provider.dart';

class TodayCallsSection extends ConsumerStatefulWidget {
  final AsyncValue<List<Llamadas>> callsAsync;
  final bool expandContent;
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
  Future<void> _updateEstado(Llamadas llamada, String nuevoEstado) async {
    final service = ref.read(llamadasServiceProvider);
    try {
      await service.update(llamada.id, {'estado': nuevoEstado});
      ref.invalidate(llamadasProvider);
    } catch (_) {}
  }

  void _openDetail(Llamadas llamada) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => CallDetailDialog(
        llamada: llamada,
        onEdit: () {
          // CallDetailDialog ya se cerró solo antes de llamar a onEdit
          ref.read(pendingCallEditProvider.notifier).set(llamada);
        },
        onDelete: () async {
          final service = ref.read(llamadasServiceProvider);
          final scaffoldMsg = ScaffoldMessenger.of(context);
          final navCtx = Navigator.of(ctx);
          try {
            await service.delete(llamada.id);
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

    final content = widget.callsAsync.when(
      data: (calls) {
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
                    ? () => _updateEstado(call, 'completada')
                    : null,
                onMarkNoAnswer: widget.showQuickActions
                    ? () => _updateEstado(call, 'no_contesto')
                    : null,
              );
            },
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
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
                    ? () => _updateEstado(call, 'completada')
                    : null,
                onMarkNoAnswer: widget.showQuickActions
                    ? () => _updateEstado(call, 'no_contesto')
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
