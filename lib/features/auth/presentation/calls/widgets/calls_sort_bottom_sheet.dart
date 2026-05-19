import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/calls/calls_page_enums.dart';

// Panel inferior que aparece desde abajo cuando el usuario quiere ordenar la lista
// de llamadas — muestra las opciones disponibles como filas seleccionables.
class CallsSortBottomSheet extends StatelessWidget {
  // Se llama con la opción elegida para que la pantalla padre actualice el orden
  final ValueChanged<CallsPageSort> onSortSelected;

  const CallsSortBottomSheet({super.key, required this.onSortSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del panel
          Text(
            l10n.sortType,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          // Opción: sin orden — muestra la lista como viene del servidor
          general_listtile(
            context: context,
            icon: Icons.filter_list_off,
            texto: l10n.noSortedCalls,
            onTap: () {
              onSortSelected(CallsPageSort.none);
              Navigator.pop(context);
              general_snackbar(context, l10n.noSortedCalls, 2);
            },
          ),
          // Opción: ordenar por nombre de A a Z
          general_listtile(
            context: context,
            icon: Icons.sort_by_alpha,
            texto: l10n.sortNameAZ,
            onTap: () {
              onSortSelected(CallsPageSort.nameAZ);
              Navigator.pop(context);
              general_snackbar(context, l10n.sortNameAZ, 2);
            },
          ),
          // Opción: ordenar por nombre de Z a A
          general_listtile(
            context: context,
            icon: Icons.sort_by_alpha,
            texto: l10n.sortNameZA,
            onTap: () {
              onSortSelected(CallsPageSort.nameZA);
              Navigator.pop(context);
              general_snackbar(context, l10n.sortNameZA, 2);
            },
          ),
          // Opción: ordenar por duración de menor a mayor
          general_listtile(
            context: context,
            icon: Icons.timer,
            texto: l10n.sortCallDurationShortLong,
            onTap: () {
              onSortSelected(CallsPageSort.callDurationShortLong);
              Navigator.pop(context);
              general_snackbar(context, l10n.sortCallDurationShortLong, 2);
            },
          ),
          // Opción: ordenar por duración de mayor a menor
          general_listtile(
            context: context,
            icon: Icons.timer,
            texto: l10n.sortCallDurationLongShort,
            onTap: () {
              onSortSelected(CallsPageSort.callDurationLongShort);
              Navigator.pop(context);
              general_snackbar(context, l10n.sortCallDurationLongShort, 2);
            },
          ),
          // Opción: ordenar por nivel de dependencia de mayor a menor
          general_listtile(
            context: context,
            icon: Icons.bar_chart,
            texto: l10n.sortDependencyHighLow,
            onTap: () {
              onSortSelected(CallsPageSort.dependencyHighLow);
              Navigator.pop(context);
              general_snackbar(context, l10n.sortDependencyHighLow, 2);
            },
          ),
          // Opción: ordenar por nivel de dependencia de menor a mayor
          general_listtile(
            context: context,
            icon: Icons.bar_chart,
            texto: l10n.sortDependencyLowHigh,
            onTap: () {
              onSortSelected(CallsPageSort.dependencyLowHigh);
              Navigator.pop(context);
              general_snackbar(context, l10n.sortDependencyLowHigh, 2);
            },
          ),
        ],
      ),
    );
  }
}
