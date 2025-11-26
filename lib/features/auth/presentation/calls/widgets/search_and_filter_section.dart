import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/calls/calls_page_enums.dart';

// Sección que agrupa el buscador de texto y el filtro por estado/grupo
class SearchAndFilterSection extends StatelessWidget {
  final CallsPageFilter filtroSeleccionado;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<CallsPageFilter> onFilterChanged;

  const SearchAndFilterSection({
    super.key,
    required this.filtroSeleccionado,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

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
        Row(
          children: [
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
                onChanged: (value) {
                  if (value != null) onFilterChanged(value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
