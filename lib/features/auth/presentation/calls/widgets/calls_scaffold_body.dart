import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/llamadas.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/calls/calls_page_enums.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/calls/widgets/search_and_filter_section.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/calls/widgets/calls_future_list.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/calls/widgets/date_filter_section.dart';

// Cuerpo principal de la pantalla de llamadas.
class CallsScaffoldBody extends StatelessWidget {
  final Future<List<Llamadas>> llamadasFuture;
  final CallsPageFilter filtroSeleccionado;
  final CallsPageSort ordenSeleccionado;
  final String textoFiltro;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;

  // Funciones para aplicar filtros y ordenar
  final List<Llamadas> Function(List<Llamadas>) aplicarFiltros;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<CallsPageFilter> onFilterChanged;
  final ValueChanged<CallsPageSort> onSortChanged;
  final ValueChanged<DateTime?> onFechaDesdeChanged;
  final ValueChanged<DateTime?> onFechaHastaChanged;

  // Función para mostrar el detalle de una llamada
  final void Function(BuildContext, Llamadas) onLlamadaTap;

  const CallsScaffoldBody({
    super.key,
    required this.llamadasFuture,
    required this.filtroSeleccionado,
    required this.ordenSeleccionado,
    required this.textoFiltro,
    this.fechaDesde,
    this.fechaHasta,
    required this.aplicarFiltros,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.onFechaDesdeChanged,
    required this.onFechaHastaChanged,
    required this.onLlamadaTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          Text(
            l10n.calls,
            style: textTheme.titleMedium?.copyWith(fontSize: 27),
          ),
          Text(l10n.superviseCalls, style: textTheme.bodyMedium),
          const SizedBox(height: 7),

          // Aviso de vista preliminar
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.usersPreliminarView,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenedor principal con fondo blanco/tarjeta
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Material(
                borderRadius: BorderRadius.circular(30),
                clipBehavior: Clip.hardEdge,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.allCalls,
                        style: textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 5),

                      // 1. Sección de búsqueda y filtros
                      SearchAndFilterSection(
                        filtroSeleccionado: filtroSeleccionado,
                        onSearchChanged: onSearchChanged,
                        onFilterChanged: onFilterChanged,
                      ),
                      const SizedBox(height: 12),

                      // 2. Sección de filtro por fecha
                      DateFilterSection(
                        fechaDesde: fechaDesde,
                        fechaHasta: fechaHasta,
                        onFechaDesdeChanged: onFechaDesdeChanged,
                        onFechaHastaChanged: onFechaHastaChanged,
                      ),
                      const SizedBox(height: 8),
                      Divider(
                        height: 8,
                        color: colorScheme.primary.withValues(alpha: 0.3),
                      ),

                      // 3. Lista de llamadas (ocupa el resto del espacio)
                      Expanded(
                        child: CallsFutureList(
                          llamadasFuture: llamadasFuture,
                          aplicarFiltros: aplicarFiltros,
                          textoFiltro: textoFiltro,
                          filtroSeleccionado: filtroSeleccionado,
                          ordenSeleccionado: ordenSeleccionado,
                          onSortChanged: onSortChanged,
                          onLlamadaTap: onLlamadaTap,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
