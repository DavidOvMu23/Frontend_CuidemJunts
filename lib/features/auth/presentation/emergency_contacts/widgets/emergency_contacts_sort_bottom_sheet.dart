import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/emergency_contacts/emergency_contacts_page_enums.dart';

class EmergencyContactsSortBottomSheet extends StatelessWidget {
  final ValueChanged<ContactoEmergenciaSort> onSortSelected;

  const EmergencyContactsSortBottomSheet({super.key, required this.onSortSelected});

  void _select(BuildContext context, ContactoEmergenciaSort sort, String text) {
    onSortSelected(sort);
    Navigator.pop(context);
    general_snackbar(context, text, 2);
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
          Text(l10n.sortType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          general_listtile(
            context: context,
            icon: Icons.sort_by_alpha,
            texto: l10n.sortNameAZ,
            onTap: () => _select(context, ContactoEmergenciaSort.nameAZ, l10n.sortNameAZ),
          ),
          general_listtile(
            context: context,
            icon: Icons.sort_by_alpha,
            texto: l10n.sortNameZA,
            onTap: () => _select(context, ContactoEmergenciaSort.nameZA, l10n.sortNameZA),
          ),
          general_listtile(
            context: context,
            icon: Icons.verified_user_outlined,
            texto: l10n.sortInternalFirst,
            onTap: () => _select(context, ContactoEmergenciaSort.sistemaPrimero, l10n.sortInternalFirst),
          ),
          general_listtile(
            context: context,
            icon: Icons.person_outline,
            texto: l10n.sortExternalFirst,
            onTap: () => _select(context, ContactoEmergenciaSort.externoPrimero, l10n.sortExternalFirst),
          ),
        ],
      ),
    );
  }
}
