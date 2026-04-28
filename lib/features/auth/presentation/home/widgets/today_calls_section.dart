import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/loading_skeleton.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/llamadas.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/home/widgets/call_card.dart';

// Sección que muestra las llamadas programadas para hoy
class TodayCallsSection extends StatelessWidget {
  final AsyncValue<List<Llamadas>> callsAsync;

  const TodayCallsSection({super.key, required this.callsAsync});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Material(
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la sección
            Text(
              l10n.todayCalls,
              style: textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),

            // Divisor
            const SizedBox(height: 2),
            Divider(color: colorScheme.primary.withValues(alpha: 0.25)),

            // Contenido: llamadas, loading o error
            callsAsync.when(
              data: (calls) {
                // Si no hay llamadas, mostramos mensaje vacío
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
                    ),
                  );
                }

                // Si hay 3 o menos, usamos Column adaptable
                if (calls.length <= 3) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: calls
                        .map(
                          (call) => CallCard(
                            usuarioNombre: call.usuarioNombre,
                            usuarioApellidos: call.usuarioApellidos,
                            grupoNombre: call.grupoNombre,
                            hora: call.hora,
                            estado: call.estado,
                          ),
                        )
                        .toList(),
                  );
                }

                // Si hay más de 3, mostramos scroll
                const double cardHeight = 135.0;
                return SizedBox(
                  height: cardHeight * 3,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: calls.length,
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
                  ),
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
            ),
          ],
        ),
      ),
    );
  }
}
