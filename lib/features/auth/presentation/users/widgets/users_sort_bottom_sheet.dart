import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/users_page_enums.dart';

// Panel inferior que aparece desde abajo cuando el usuario quiere ordenar la lista
// de usuarios — muestra las opciones disponibles como filas seleccionables.
class UsersSortBottomSheet extends StatelessWidget {
  // Se llama con el criterio elegido para que la pantalla padre actualice el orden
  final ValueChanged<UsersPageSort> onSortSelected;

  const UsersSortBottomSheet({super.key, required this.onSortSelected});

  // Método auxiliar: aplica la selección, cierra el panel y muestra una confirmación
  void _select(BuildContext context, UsersPageSort sort, String snackbarText) {
    onSortSelected(sort);
    Navigator.pop(context);
    general_snackbar(context, snackbarText, 2);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.sortType,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),

          // Opción: sin orden, muestra la lista como viene del servidor
          general_listtile(
            context: context,
            icon: Icons.filter_list_off,
            texto: l10n.noSortedUsers,
            onTap: () =>
                _select(context, UsersPageSort.noneAZ, l10n.noSortedUsers),
          ),
          // Opción: ordenar por nombre de Z a A
          general_listtile(
            context: context,
            icon: Icons.sort_by_alpha,
            texto: l10n.sortNameZA,
            onTap: () =>
                _select(context, UsersPageSort.nameZA, l10n.sortedZASnackbar),
          ),
          // Opción: ordenar por fecha de nacimiento, más jóvenes primero
          general_listtile(
            context: context,
            icon: Icons.date_range,
            texto: l10n.sortDateBirthNewest,
            onTap: () => _select(
              context,
              UsersPageSort.dateBirthNewest,
              l10n.sortedDateBirthNewest,
            ),
          ),
          // Opción: ordenar por fecha de nacimiento, más mayores primero
          general_listtile(
            context: context,
            icon: Icons.date_range,
            texto: l10n.sortDateBirthOldest,
            onTap: () => _select(
              context,
              UsersPageSort.dateBirthOldest,
              l10n.sortedDateBirthOldest,
            ),
          ),
          // Opción: ordenar por dependencia de mayor a menor (más grave primero)
          general_listtile(
            context: context,
            icon: Icons.bar_chart,
            texto: l10n.sortDependencyHighLow,
            onTap: () => _select(
              context,
              UsersPageSort.dependencyHighLow,
              l10n.sortedDependencyLevelHighLow,
            ),
          ),
          // Opción: ordenar por dependencia de menor a mayor (ninguna primero)
          general_listtile(
            context: context,
            icon: Icons.bar_chart,
            texto: l10n.sortDependencyLowHigh,
            onTap: () => _select(
              context,
              UsersPageSort.dependencyLowHigh,
              l10n.sortedDependencyLevelLowHigh,
            ),
          ),
        ],
      ),
    );
  }
}
