import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/core/widgets/loading_skeleton.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/emergency_contacts/emergency_contacts_page_enums.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/emergency_contacts/widgets/emergency_contact_card.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/usuario_provider.dart';

class EmergencyContactsScaffoldBody extends ConsumerWidget {
  final Future<List<ContactoEmergencia>> contactosFuture;
  final String textoFiltro;
  final ContactoEmergenciaFilter filtroSeleccionado;
  final List<ContactoEmergencia> Function(List<ContactoEmergencia>) aplicarFiltros;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ContactoEmergenciaFilter> onFilterChanged;
  final void Function(BuildContext, ContactoEmergencia, bool, Map<String, String>) onContactoTap;
  final void Function(ContactoEmergencia) onContactoEdit;

  const EmergencyContactsScaffoldBody({
    super.key,
    required this.contactosFuture,
    required this.textoFiltro,
    required this.filtroSeleccionado,
    required this.aplicarFiltros,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onContactoTap,
    required this.onContactoEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final horizontalPadding = isDesktop ? 20.0 : 12.0;

    final usuariosFuture = ref.read(usuarioServiceProvider).getAll();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Material(
                color: colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: general_busqueda_textfield(
                              l10n.searchEmergencyContacts,
                              icono: Icons.search,
                              onChanged: onSearchChanged,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Icon(
                                  filtroSeleccionado != ContactoEmergenciaFilter.all
                                      ? Icons.filter_alt
                                      : Icons.filter_alt_off,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonFormField<ContactoEmergenciaFilter>(
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
                                        value: ContactoEmergenciaFilter.all,
                                        child: Text(l10n.allEmergencyContacts),
                                      ),
                                      DropdownMenuItem(
                                        value: ContactoEmergenciaFilter.sistema,
                                        child: Text(l10n.systemUser),
                                      ),
                                      DropdownMenuItem(
                                        value: ContactoEmergenciaFilter.externo,
                                        child: Text(l10n.externalContact),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) onFilterChanged(value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Divider(
                        height: 8,
                        color: colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      Expanded(
                        child: FutureBuilder<List<dynamic>>(
                          future: Future.wait([contactosFuture, usuariosFuture]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const AppSkeletonList(count: 4);
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  '${l10n.error}: ${snapshot.error}',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.error,
                                  ),
                                ),
                              );
                            }

                            final results = snapshot.data ?? [];
                            final contactos = (results.isNotEmpty && results[0] is List<ContactoEmergencia>)
                                ? results[0] as List<ContactoEmergencia>
                                : <ContactoEmergencia>[];
                            final usuarios = (results.length > 1 && results[1] is List<Usuario>)
                                ? results[1] as List<Usuario>
                                : <Usuario>[];
                            final contactosFiltrados = aplicarFiltros(contactos);

                            final Map<String, String> usuariosMap = {
                              for (final u in usuarios) u.dni: '${u.nombre} ${u.apellidos}'
                            };

                            if (contactosFiltrados.isEmpty) {
                              return Center(
                                child: Text(l10n.noResultsFound, style: textTheme.bodyMedium),
                              );
                            }

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${l10n.results}: ${contactosFiltrados.length}',
                                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: ListView.separated(
                                    padding: EdgeInsets.zero,
                                    itemCount: contactosFiltrados.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final contacto = contactosFiltrados[index];
                                      final asociados = contacto.usuariosDnis
                                          .map((d) => usuariosMap[d] ?? d)
                                          .toList();
                                      return EmergencyContactCard(
                                        contacto: contacto,
                                        asociados: asociados,
                                        onTap: () => onContactoTap(context, contacto, true, usuariosMap),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
