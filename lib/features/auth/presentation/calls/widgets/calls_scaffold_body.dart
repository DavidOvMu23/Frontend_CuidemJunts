import 'package:flutter/material.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final horizontalPadding = isDesktop ? 20.0 : 12.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Contenedor principal con fondo de tarjeta
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Material(
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 22 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Sección de búsqueda y filtros
                      SearchAndFilterSection(
                        filtroSeleccionado: filtroSeleccionado,
                        onSearchChanged: onSearchChanged,
                        onFilterChanged: onFilterChanged,
                        isDesktop: isDesktop,
                      ),
                      const SizedBox(height: 10),
                      // 2. Sección de filtro por fecha
                      DateFilterSection(
                        fechaDesde: fechaDesde,
                        fechaHasta: fechaHasta,
                        onFechaDesdeChanged: onFechaDesdeChanged,
                        onFechaHastaChanged: onFechaHastaChanged,
                        onClearDates: (fechaDesde != null || fechaHasta != null)
                            ? () {
                                onFechaDesdeChanged(null);
                                onFechaHastaChanged(null);
                              }
                            : null,
                        isDesktop: isDesktop,
                      ),
                      const SizedBox(height: 10),
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
