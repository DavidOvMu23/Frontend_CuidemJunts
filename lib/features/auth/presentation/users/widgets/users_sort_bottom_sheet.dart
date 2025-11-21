import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/users_page_enums.dart';

// -------- BOTTOM SHEET DE ORDENACIÓN --------
// Modal que permite al usuario seleccionar el criterio de ordenación de la lista.
class UsersSortBottomSheet extends StatelessWidget {
  final ValueChanged<UsersPageSort> onSortSelected;

  const UsersSortBottomSheet({super.key, required this.onSortSelected});

  // Selecciona el orden, cierra el modal y muestra un snackbar.
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
          general_listtile(
            context: context,
            icon: Icons.filter_list_off,
            texto: l10n.noSortedUsers,
            onTap: () =>
                _select(context, UsersPageSort.noneAZ, l10n.noSortedUsers),
          ),
          general_listtile(
            context: context,
            icon: Icons.sort_by_alpha,
            texto: l10n.sortNameZA,
            onTap: () =>
                _select(context, UsersPageSort.nameZA, l10n.sortedZASnackbar),
          ),
          general_listtile(
            context: context,
            icon: Icons.sort_by_alpha,
            texto: l10n.sortNameAZ,
            onTap: () =>
                _select(context, UsersPageSort.noneAZ, l10n.sortedAZSnackbar),
          ),
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
