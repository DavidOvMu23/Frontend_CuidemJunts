import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/calls/calls_page_enums.dart';

// Sección que agrupa el buscador de texto y el menú desplegable de filtros
// por estado de llamada — aparece en la parte superior de la pantalla de llamadas.
class SearchAndFilterSection extends StatelessWidget {
  // Estado del filtro activo (todas, completadas, pendientes, no contestadas)
  final CallsPageFilter filtroSeleccionado;
  // Se llama cada vez que el usuario escribe en el buscador
  final ValueChanged<String> onSearchChanged;
  // Se llama cuando el usuario cambia el filtro de estado
  final ValueChanged<CallsPageFilter> onFilterChanged;
  // Si estamos en escritorio, el buscador y el filtro se muestran en fila
  final bool isDesktop;

  const SearchAndFilterSection({
    super.key,
    required this.filtroSeleccionado,
    required this.onSearchChanged,
    required this.onFilterChanged,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // El menú desplegable de filtro — se reutiliza en móvil y escritorio
    final filterSelector = Row(
      children: [
        // El icono cambia según si hay un filtro activo o no, para indicarlo visualmente
        Icon(
          filtroSeleccionado != CallsPageFilter.all
              ? Icons.filter_alt
              : Icons.filter_alt_off,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<CallsPageFilter>(
            initialValue: filtroSeleccionado,
            icon: const Icon(Icons.arrow_drop_down),
            borderRadius: BorderRadius.circular(12),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            // Las opciones disponibles del filtro
            items: [
              DropdownMenuItem(
                value: CallsPageFilter.all,
                child: Text(l10n.allCalls),
              ),
              DropdownMenuItem(
                value: CallsPageFilter.complete,
                child: Text(l10n.callCompleted),
              ),
              DropdownMenuItem(
                value: CallsPageFilter.pending,
                child: Text(l10n.callPending),
              ),
              DropdownMenuItem(
                value: CallsPageFilter.incomplete,
                child: Text(l10n.callNoAnswer),
              ),
            ],
            // Cuando el usuario elige una opción, se notifica a la pantalla padre
            onChanged: (value) {
              if (value != null) onFilterChanged(value);
            },
          ),
        ),
      ],
    );

    // En escritorio, el buscador y el filtro están en la misma fila para aprovechar el espacio
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: general_busqueda_textfield(
              l10n.searchCalls,
              icono: Icons.search,
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: filterSelector),
        ],
      );
    }

    // En móvil, el buscador y el filtro se apilan verticalmente para no quedar apretados
    return Column(
      children: [
        // Buscador por nombre/resumen
        general_busqueda_textfield(
          l10n.searchCalls,
          icono: Icons.search,
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 12),

        // Dropdown para filtrar por estado/grupo
        filterSelector,
      ],
    );
  }
}
