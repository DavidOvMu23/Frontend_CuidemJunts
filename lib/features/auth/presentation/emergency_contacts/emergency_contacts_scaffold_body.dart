import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/usuario_provider.dart';

// Cuerpo principal de la pantalla de contactos de emergencia,
// diseñado para replicar el estilo y estructura de UsersScaffoldBody.
class EmergencyContactsScaffoldBody extends ConsumerWidget {
  final Future<List<ContactoEmergencia>> contactosFuture;
  final String textoFiltro;
  final List<ContactoEmergencia> Function(List<ContactoEmergencia>) aplicarFiltros;
  final ValueChanged<String> onSearchChanged;
  final void Function(BuildContext, ContactoEmergencia, bool, Map<String, String>) onContactoTap;
  final void Function(ContactoEmergencia) onContactoEdit;

  const EmergencyContactsScaffoldBody({
    super.key,
    required this.contactosFuture,
    required this.textoFiltro,
    required this.aplicarFiltros,
    required this.onSearchChanged,
    required this.onContactoTap,
    required this.onContactoEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final usuariosFuture = ref.read(usuarioServiceProvider).getAll();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.emergencyContacts,
            style: textTheme.titleMedium?.copyWith(fontSize: 27),
          ),
          Text(l10n.manageEmergencyContacts, style: textTheme.bodyMedium),
          const SizedBox(height: 7),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Material(
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.searchEmergencyContacts,
                        style: textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 5),
                      general_busqueda_textfield(
                        l10n.searchEmergencyContacts,
                        icono: Icons.search,
                        onChanged: onSearchChanged,
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
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
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
                            final contactos = (results.isNotEmpty && results[0] is List<ContactoEmergencia>) ? results[0] as List<ContactoEmergencia> : <ContactoEmergencia>[];
                            final usuarios = (results.length > 1 && results[1] is List<Usuario>) ? results[1] as List<Usuario> : <Usuario>[];
                            final contactosFiltrados = aplicarFiltros(contactos);

                            final Map<String, String> usuariosMap = { for (final u in usuarios) u.dni : '${u.nombre} ${u.apellidos}' };

                            if (contactosFiltrados.isEmpty) {
                              return Center(
                                child: Text(
                                  l10n.noResultsFound,
                                  style: textTheme.bodyMedium,
                                ),
                              );
                            }

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Resultados: ${contactosFiltrados.length}',
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
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
                                      final asociados = contacto.usuariosDnis.map((d) => usuariosMap[d] ?? d).toList();
                                      return Material(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(16),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(16),
                                          onTap: () => onContactoTap(context, contacto, true, usuariosMap),
                                          child: Stack(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(14, 12, 40, 12),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${contacto.nombre} ${contacto.apellidos}',
                                                      style: textTheme.headlineLarge?.copyWith(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.phone, size: 18),
                                                        const SizedBox(width: 6),
                                                        Text(contacto.telefono, style: textTheme.bodyMedium),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    // Mostrar referencia a usuario(s) usando los asociados
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Icon(Icons.badge_outlined, size: 18),
                                                        const SizedBox(width: 6),
                                                        Expanded(child: Text('Usuarios: ${asociados.isEmpty ? '-' : asociados.join(', ')}', style: textTheme.bodyMedium)),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Positioned(
                                                right: 12,
                                                top: 0,
                                                bottom: 0,
                                                child: Center(
                                                  child: Icon(
                                                    Icons.chevron_right,
                                                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
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
