import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/emergency_contacts/emergency_contacts_page_enums.dart';

// Panel inferior para elegir cómo ordenar la lista de contactos de emergencia
class EmergencyContactsSortBottomSheet extends StatelessWidget {
  // Se llama con el criterio elegido para que la pantalla padre actualice la lista
  final ValueChanged<ContactoEmergenciaSort> onSortSelected;

  const EmergencyContactsSortBottomSheet({super.key, required this.onSortSelected});

  // Método auxiliar: aplica la selección, cierra el panel y muestra una confirmación
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
          // Título del panel
          Text(l10n.sortType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          // Ordena de A a Z por nombre
          general_listtile(
            context: context,
            icon: Icons.sort_by_alpha,
            texto: l10n.sortNameAZ,
            onTap: () => _select(context, ContactoEmergenciaSort.nameAZ, l10n.sortNameAZ),
          ),
          // Ordena de Z a A por nombre
          general_listtile(
            context: context,
            icon: Icons.sort_by_alpha,
            texto: l10n.sortNameZA,
            onTap: () => _select(context, ContactoEmergenciaSort.nameZA, l10n.sortNameZA),
          ),
          // Muestra primero los contactos que son usuarios del sistema
          general_listtile(
            context: context,
            icon: Icons.verified_user_outlined,
            texto: l10n.sortInternalFirst,
            onTap: () => _select(context, ContactoEmergenciaSort.sistemaPrimero, l10n.sortInternalFirst),
          ),
          // Muestra primero los contactos externos (no son usuarios del sistema)
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
