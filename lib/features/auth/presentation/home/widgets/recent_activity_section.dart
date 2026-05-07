import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/loading_skeleton.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/llamadas.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/home/widgets/call_card.dart';

// Sección que muestra la actividad reciente
class RecentActivitySection extends StatelessWidget {
  final AsyncValue<List<Llamadas>> callsAsync;
  final bool expandContent;

  const RecentActivitySection({super.key, required this.callsAsync, this.expandContent = false});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final content = callsAsync.when(
      data: (calls) {
        if (calls.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.electric_bolt,
                  size: 48,
                  color: colorScheme.primary.withValues(alpha: 0.25),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.nothingActivityRecent,
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
              );
            },
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: expandContent ? const ClampingScrollPhysics() : const NeverScrollableScrollPhysics(),
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
        child: Text(l10n.errorLoadingActivity),
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
              l10n.activityRecent,
              style: textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Divider(color: colorScheme.primary.withValues(alpha: 0.25)),
            if (expandContent)
              Expanded(child: content)
            else
              content,
            if (!expandContent) const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
