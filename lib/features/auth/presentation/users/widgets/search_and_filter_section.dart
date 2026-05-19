import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/users_page_enums.dart';

// Sección que agrupa el buscador de texto y el filtro por nivel de dependencia
// en la pantalla de usuarios — permite buscar por nombre/DNI y filtrar por grado.
class SearchAndFilterSection extends StatelessWidget {
  // El filtro de dependencia activo en este momento
  final UsersPageFilter filtroSeleccionado;
  // Se llama cuando el usuario escribe en el buscador
  final ValueChanged<String> onSearchChanged;
  // Se llama cuando el usuario cambia el filtro de dependencia
  final ValueChanged<UsersPageFilter> onFilterChanged;
  // En escritorio los dos controles se muestran en la misma fila
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

    // Menú desplegable para filtrar por nivel de dependencia del usuario
    final filterSelector = Row(
      children: [
        // El icono cambia si hay un filtro activo para indicarlo visualmente
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
            // Opciones de filtro por nivel de dependencia
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
            // Notificamos a la pantalla padre cuando el usuario elige una opción
            onChanged: (value) {
              if (value != null) onFilterChanged(value);
            },
          ),
        ),
      ],
    );

    // En escritorio, buscador y filtro en la misma fila
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: general_busqueda_textfield(
              l10n.searchUser,
              icono: Icons.search,
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: filterSelector),
        ],
      );
    }

    // En móvil, se apilan verticalmente para no quedar apretados
    return Column(
      children: [
        // Buscador por nombre/DNI
        general_busqueda_textfield(
          l10n.searchUser,
          icono: Icons.search,
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 12),

        // Dropdown para filtrar por nivel de dependencia
        filterSelector,
      ],
    );
  }
}
