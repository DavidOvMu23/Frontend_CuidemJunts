import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/calls/calls_page_enums.dart';

// Bottom sheet para seleccionar el tipo de ordenación de llamadas
class CallsSortBottomSheet extends StatelessWidget {
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
          Text(
            l10n.sortType,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
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
