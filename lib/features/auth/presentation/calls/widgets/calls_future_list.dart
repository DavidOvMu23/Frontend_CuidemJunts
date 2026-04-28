import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/loading_skeleton.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/llamadas.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/calls/calls_page_enums.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/calls/widgets/call_card.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/calls/widgets/calls_sort_bottom_sheet.dart';

// Lista de llamadas que gestiona los estados de carga (FutureBuilder).
class CallsFutureList extends StatelessWidget {
  final Future<List<Llamadas>> llamadasFuture;
  final List<Llamadas> Function(List<Llamadas>) aplicarFiltros;
  final String textoFiltro;
  final CallsPageFilter filtroSeleccionado;
  final CallsPageSort ordenSeleccionado;
  final ValueChanged<CallsPageSort> onSortChanged;
  final void Function(BuildContext, Llamadas) onLlamadaTap;

  const CallsFutureList({
    super.key,
    required this.llamadasFuture,
    required this.aplicarFiltros,
    required this.textoFiltro,
    required this.filtroSeleccionado,
    required this.ordenSeleccionado,
    required this.onSortChanged,
    required this.onLlamadaTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // FutureBuilder que gestiona los estados de carga, error y vacío.
    return FutureBuilder<List<Llamadas>>(
      future: llamadasFuture,
      builder: (context, snapshot) {
        // 1. Estado de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppSkeletonList(count: 4);
        }

        // 2. Estado de error
        if (snapshot.hasError) {
          return Center(
            child: Card(
              margin: EdgeInsets.zero,
              color: colorScheme.error.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }

        final llamadas = snapshot.data ?? [];

        // 3. Estado vacío (sin llamadas en la BD)
        if (llamadas.isEmpty) {
          return Center(
            child: Text(
              'No se encontraron llamadas',
              style: textTheme.bodyMedium,
            ),
          );
        }

        // Aplicamos los filtros y ordenación sobre los datos recibidos
        final llamadasFiltradas = aplicarFiltros(llamadas);
        final totalText =
            textoFiltro.isEmpty && filtroSeleccionado == CallsPageFilter.all
            ? '${l10n.totalCalls}: ${llamadas.length}'
            : '${l10n.callsFound}: ${llamadasFiltradas.length}';

        return Column(
          children: [
            // Cabecera de la lista: contador y botón de ordenar
            Row(
              children: [
                Expanded(
                  child: Text(
                    totalText,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    ordenSeleccionado == CallsPageSort.none
                        ? Icons.filter_list_off
                        : Icons.filter_list,
                    color: colorScheme.primary,
                  ),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) =>
                          CallsSortBottomSheet(onSortSelected: onSortChanged),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 4. Lista filtrada vacía (no hay coincidencias)
            if (llamadasFiltradas.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No se encontraron llamadas',
                  style: textTheme.bodyMedium,
                ),
              )
            else
              // 5. Lista de llamadas
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: llamadasFiltradas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final llamada = llamadasFiltradas[index];
                    return CallCard(
                      llamada: llamada,
                      textTheme: textTheme,
                      colorScheme: colorScheme,
                      onTap: () => onLlamadaTap(context, llamada),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
