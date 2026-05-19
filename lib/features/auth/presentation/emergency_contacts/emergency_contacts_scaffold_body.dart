import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/core/widgets/loading_skeleton.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/emergency_contacts/emergency_contacts_page_enums.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/emergency_contacts/widgets/emergency_contact_card.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/emergency_contacts/widgets/emergency_contacts_sort_bottom_sheet.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/usuario_provider.dart';

// Cuerpo principal de la pantalla de contactos de emergencia — muestra el buscador,
// el filtro por tipo (sistema/externo) y la lista de contactos.
class EmergencyContactsScaffoldBody extends ConsumerWidget {
  // La petición al servidor que traerá la lista de contactos
  final Future<List<ContactoEmergencia>> contactosFuture;
  // Texto escrito en el buscador
  final String textoFiltro;
  // Filtro activo (todos, del sistema, externos)
  final ContactoEmergenciaFilter filtroSeleccionado;
  // Criterio de ordenación activo
  final ContactoEmergenciaSort ordenSeleccionado;
  // Aplica los filtros y el orden a la lista completa
  final List<ContactoEmergencia> Function(List<ContactoEmergencia>) aplicarFiltros;
  // Se llama cuando el usuario escribe en el buscador o cambia el filtro
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ContactoEmergenciaFilter> onFilterChanged;
  final ValueChanged<ContactoEmergenciaSort> onSortChanged;
  // Se llama cuando el usuario pulsa un contacto para ver su detalle
  final void Function(BuildContext, ContactoEmergencia, bool, Map<String, String>) onContactoTap;
  // Se llama cuando el usuario quiere editar un contacto
  final void Function(ContactoEmergencia) onContactoEdit;

  const EmergencyContactsScaffoldBody({
    super.key,
    required this.contactosFuture,
    required this.textoFiltro,
    required this.filtroSeleccionado,
    required this.ordenSeleccionado,
    required this.aplicarFiltros,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.onContactoTap,
    required this.onContactoEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppBreakpoints.desktop;
    final horizontalPadding = isDesktop ? 20.0 : 12.0;

    // Comprobamos si el usuario logueado es supervisor para mostrar las opciones adecuadas
    final isSupervisor = (ref.read(authProvider).rol ?? '').toLowerCase() == AppRoles.supervisor;
    // También pedimos la lista de usuarios del sistema para poder mostrar sus nombres
    // junto a los contactos que los referencian
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
                          // Esperamos a que lleguen AMBAS peticiones al mismo tiempo antes de pintar
                          future: Future.wait([contactosFuture, usuariosFuture]),
                          builder: (context, snapshot) {
                            // Mientras esperamos, mostramos un esqueleto de carga
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const AppSkeletonList(count: 4);
                            }

                            // Si algo salió mal, mostramos el mensaje de error
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

                            // Separamos los dos resultados que llegaron juntos
                            final results = snapshot.data ?? [];
                            final contactos = (results.isNotEmpty && results[0] is List<ContactoEmergencia>)
                                ? results[0] as List<ContactoEmergencia>
                                : <ContactoEmergencia>[];
                            final usuarios = (results.length > 1 && results[1] is List<Usuario>)
                                ? results[1] as List<Usuario>
                                : <Usuario>[];
                            // Aplicamos los filtros activos sobre la lista de contactos
                            final contactosFiltrados = aplicarFiltros(contactos);

                            // Creamos un mapa DNI → nombre completo para buscar rápidamente
                            // el nombre de cada usuario asociado a un contacto
                            final Map<String, String> usuariosMap = {
                              for (final u in usuarios) u.dni: '${u.nombre} ${u.apellidos}'
                            };

                            if (contactosFiltrados.isEmpty) {
                              return Center(
                                child: Text(l10n.noResultsFound, style: textTheme.bodyMedium),
                              );
                            }

                            final totalText = textoFiltro.isEmpty && filtroSeleccionado == ContactoEmergenciaFilter.all
                                ? '${l10n.totalContacts}: ${contactos.length}'
                                : '${l10n.results}: ${contactosFiltrados.length}';

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        totalText,
                                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 16),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        ordenSeleccionado == ContactoEmergenciaSort.nameAZ
                                            ? Icons.filter_list_off
                                            : Icons.filter_list,
                                        color: colorScheme.primary,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (_) => EmergencyContactsSortBottomSheet(
                                            onSortSelected: onSortChanged,
                                          ),
                                        );
                                      },
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
                                      // Para cada contacto buscamos los nombres completos de los
                                      // usuarios asociados usando el mapa creado antes
                                      final asociados = contacto.usuariosDnis
                                          .map((d) => usuariosMap[d] ?? d)
                                          .toList();
                                      return EmergencyContactCard(
                                        contacto: contacto,
                                        asociados: asociados,
                                        onTap: () => onContactoTap(context, contacto, isSupervisor, usuariosMap),
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
