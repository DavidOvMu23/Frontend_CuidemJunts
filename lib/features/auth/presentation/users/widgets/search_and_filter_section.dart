import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/users_page_enums.dart';

// Sección que agrupa el buscador de texto y el filtro por dependencia
class SearchAndFilterSection extends StatelessWidget {
  final UsersPageFilter filtroSeleccionado;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<UsersPageFilter> onFilterChanged;

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
        // Buscador por nombre/DNI
        general_busqueda_textfield(
          l10n.searchUser,
          icono: Icons.search,
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 20),

        // Dropdown para filtrar por nivel de dependencia
        Row(
          children: [
            Icon(
              filtroSeleccionado != UsersPageFilter.all
                  ? Icons.filter_alt
                  : Icons.filter_alt_off,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<UsersPageFilter>(
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
                    value: UsersPageFilter.all,
                    child: Text(l10n.searchAllUsers),
                  ),
                  DropdownMenuItem(
                    value: UsersPageFilter.ningunaDep,
                    child: Text(l10n.searchNoDependency),
                  ),
                  DropdownMenuItem(
                    value: UsersPageFilter.leve,
                    child: Text(l10n.searchModerateDependency),
                  ),
                  DropdownMenuItem(
                    value: UsersPageFilter.medio,
                    child: Text(l10n.searchSevereDependency),
                  ),
                  DropdownMenuItem(
                    value: UsersPageFilter.severo,
                    child: Text(l10n.searchHighDependency),
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
