import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/contacto_emergencia_service.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/calls_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/notifications_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/usuario_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';

class EmergencyContactsPage extends ConsumerStatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  ConsumerState<EmergencyContactsPage> createState() =>
      _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends ConsumerState<EmergencyContactsPage> {
  late final ContactoEmergenciaService _contactoService;
  late Future<List<ContactoEmergencia>> _contactosFuture;

  String textoFiltro = '';

  @override
  void initState() {
    super.initState();
    _contactoService = ref.read(contactoEmergenciaServiceProvider);
    _contactosFuture = _cargarContactos();
  }

  Future<List<ContactoEmergencia>> _cargarContactos() async {
    return _contactoService.getAll();
  }

  void _recargarContactos() {
    setState(() {
      _contactosFuture = _cargarContactos();
    });
  }

  void _onSearchChanged(String value) {
    setState(() => textoFiltro = value);
  }

  List<ContactoEmergencia> _aplicarFiltros(List<ContactoEmergencia> contactos) {
    final query = textoFiltro.trim().toLowerCase();

    final filtrados = contactos.where((contacto) {
      final nombreCompleto = '${contacto.nombre} ${contacto.apellidos}'
          .toLowerCase();
      final paciente = _pacienteTexto(contacto).toLowerCase();
      return query.isEmpty ||
          nombreCompleto.contains(query) ||
          contacto.telefono.contains(query) ||
          contacto.relacion.toLowerCase().contains(query) ||
          paciente.contains(query);
    }).toList();

    filtrados.sort((a, b) => a.nombre.compareTo(b.nombre));
    return filtrados;
  }

  String _pacienteTexto(ContactoEmergencia contacto) {
    final nombre = (contacto.pacienteNombre ?? '').trim();
    if (nombre.isNotEmpty) {
      if ((contacto.dniUsuarioRef ?? '').trim().isNotEmpty) {
        return '$nombre (${contacto.dniUsuarioRef})';
      }
      return nombre;
    }

    return (contacto.dniUsuarioRef ?? '').trim().isEmpty
        ? '-'
        : contacto.dniUsuarioRef!;
  }

  Future<void> _mostrarDetalleContacto(
    BuildContext context,
    ContactoEmergencia contacto,
    bool isSupervisor,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${contacto.nombre} ${contacto.apellidos}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(l10n.phone, contacto.telefono),
            _buildInfoRow(l10n.relation, contacto.relacion),
            _buildInfoRow(l10n.refersToUser, _pacienteTexto(contacto)),
          ],
        ),
        actions: [
          if (isSupervisor)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _abrirFormularioContacto(contacto: contacto);
              },
              child: Text(l10n.edit),
            ),
          if (isSupervisor)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _confirmarEliminar(contacto);
              },
              child: Text(l10n.delete),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminar(ContactoEmergencia contacto) async {
    final l10n = AppLocalizations.of(context)!;

    await showConfirmDialog(
      context,
      title: l10n.delete,
      content:
          '${l10n.deleteUserContent}\n\n${contacto.nombre} ${contacto.apellidos}',
      confirmText: l10n.accept,
      cancelText: l10n.cancel,
      onConfirm: () async {
        try {
          await _contactoService.delete(contacto.id);
          if (!mounted) return;
          _recargarContactos();
          general_snackbar(context, l10n.userDeletedSuccessfully, 2);
        } catch (e) {
          if (!mounted) return;
          general_snackbar_error(context, '${l10n.error}: $e', 3);
        }
      },
    );
  }

  Future<void> _abrirFormularioContacto({ContactoEmergencia? contacto}) async {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = contacto != null;
    final usuariosFuture = ref.read(usuarioServiceProvider).getAll();

    final nombreCtrl = TextEditingController(text: contacto?.nombre ?? '');
    final apellidosCtrl = TextEditingController(
      text: contacto?.apellidos ?? '',
    );
    final telefonoCtrl = TextEditingController(text: contacto?.telefono ?? '');
    final relacionCtrl = TextEditingController(text: contacto?.relacion ?? '');
    String? selectedDni = (contacto?.dniUsuarioRef ?? '').trim().isEmpty
        ? null
        : contacto!.dniUsuarioRef;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setLocalState) => AlertDialog(
            title: Text(isEdit ? l10n.edit : l10n.add),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  general_textfield_NoICON(l10n.name, controller: nombreCtrl),
                  const SizedBox(height: 10),
                  general_textfield_NoICON(
                    l10n.lastName,
                    controller: apellidosCtrl,
                  ),
                  const SizedBox(height: 10),
                  general_textfield_NoICON(
                    l10n.phone,
                    controller: telefonoCtrl,
                  ),
                  const SizedBox(height: 10),
                  general_textfield_NoICON(
                    l10n.relation,
                    controller: relacionCtrl,
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<List<Usuario>>(
                    future: usuariosFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Text(
                          '${l10n.error}: ${snapshot.error}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        );
                      }

                      final usuarios = snapshot.data ?? [];
                      if (selectedDni != null &&
                          !usuarios.any((u) => u.dni == selectedDni)) {
                        selectedDni = null;
                      }

                      return DropdownButtonFormField<String?>(
                        initialValue: selectedDni,
                        borderRadius: BorderRadius.circular(12),
                        decoration: InputDecoration(
                          labelText: l10n.refersToUser,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Sin paciente asignado'),
                          ),
                          ...usuarios.map(
                            (u) => DropdownMenuItem<String?>(
                              value: u.dni,
                              child: Text(
                                '${u.nombre} ${u.apellidos} (${u.dni})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setLocalState(() {
                            selectedDni = value;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () async {
                  final nombre = nombreCtrl.text.trim();
                  final apellidos = apellidosCtrl.text.trim();
                  final telefono = telefonoCtrl.text.trim();
                  final relacion = relacionCtrl.text.trim();

                  if (nombre.isEmpty ||
                      apellidos.isEmpty ||
                      telefono.isEmpty ||
                      relacion.isEmpty) {
                    general_snackbar_error(context, l10n.fillAllFields, 2);
                    return;
                  }

                  final payload = <String, dynamic>{
                    'nombre': nombre,
                    'apellidos': apellidos,
                    'telefono': telefono,
                    'relacion': relacion,
                  };

                  if (selectedDni != null) {
                    payload['dniUsuarioRef'] = selectedDni;
                  } else if (isEdit) {
                    payload['dniUsuarioRef'] = '';
                  }

                  try {
                    if (isEdit) {
                      await _contactoService.update(contacto.id, payload);
                    } else {
                      await _contactoService.create(payload);
                    }

                    if (!mounted) return;
                    Navigator.pop(ctx);
                    _recargarContactos();
                    general_snackbar(
                      context,
                      isEdit
                          ? l10n.userUpdatedSuccess
                          : l10n.userCreatedSuccess,
                      2,
                    );
                  } catch (e) {
                    if (!mounted) return;
                    general_snackbar_error(context, '${l10n.error}: $e', 3);
                  }
                },
                child: Text(l10n.accept),
              ),
            ],
          ),
        );
      },
    );

    nombreCtrl.dispose();
    apellidosCtrl.dispose();
    telefonoCtrl.dispose();
    relacionCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
    final userRole = authState.rol;
    final isSupervisor = userRole?.toLowerCase() == 'supervisor';

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final notificacionesSinLeerAsync = ref.watch(notificacionesSinLeerProvider);

    return Scaffold(
      appBar: appMainAppBar(
        numeroNotificaciones: notificacionesSinLeerAsync.when(
          data: (count) => count,
          loading: () => 0,
          error: (_, __) => 0,
        ),
        onNotifications: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsPage()),
          );
        },
      ),
      drawer: appDrawer(
        userName: userName,
        userRole: userRole,
        context: context,
        selected: DrawerItem.emergencyContacts,
        onTapHome: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeSupervisorPage()),
          );
        },
        onTapCalls: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LlamadasPage()),
          );
        },
        onTapUsers: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UsersPage()),
          );
        },
        onTapTelemarketers: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WorkersPage()),
          );
        },
        onTapPreferences: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PreferencesPage()),
          );
        },
        onTapNotifications: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsPage()),
          );
        },
        onTapEmergencyContacts: () {
          Navigator.pop(context);
        },
        onLogoutConfirmed: () async {
          await ref.read(authProvider.notifier).logout();
          if (!context.mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.emergencyContacts,
              style: textTheme.titleMedium?.copyWith(fontSize: 27),
            ),
            Text(l10n.searchEmergencyContacts, style: textTheme.bodyMedium),
            const SizedBox(height: 7),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Material(
                  borderRadius: BorderRadius.circular(30),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                          onChanged: _onSearchChanged,
                        ),
                        const SizedBox(height: 8),
                        Divider(
                          height: 8,
                          color: colorScheme.primary.withValues(alpha: 0.3),
                        ),
                        Expanded(
                          child: FutureBuilder<List<ContactoEmergencia>>(
                            future: _contactosFuture,
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

                              final contactos = snapshot.data ?? [];
                              final contactosFiltrados = _aplicarFiltros(
                                contactos,
                              );

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
                                          '${l10n.noResultsFound}: ${contactosFiltrados.length}',
                                          style: textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: contactosFiltrados.length,
                                      itemBuilder: (context, index) {
                                        final contacto =
                                            contactosFiltrados[index];
                                        return Card(
                                          margin: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor:
                                                  colorScheme.primaryContainer,
                                              child: Icon(
                                                Icons.contact_emergency,
                                                color: colorScheme
                                                    .onPrimaryContainer,
                                              ),
                                            ),
                                            title: Text(
                                              '${contacto.nombre} ${contacto.apellidos}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Text(
                                              '${l10n.relation}: ${contacto.relacion} · ${l10n.refersToUser}: ${_pacienteTexto(contacto)}',
                                            ),
                                            trailing: isSupervisor
                                                ? PopupMenuButton<String>(
                                                    onSelected: (value) {
                                                      if (value == 'edit') {
                                                        _abrirFormularioContacto(
                                                          contacto: contacto,
                                                        );
                                                      }
                                                      if (value == 'delete') {
                                                        _confirmarEliminar(
                                                          contacto,
                                                        );
                                                      }
                                                    },
                                                    itemBuilder: (context) => [
                                                      PopupMenuItem(
                                                        value: 'edit',
                                                        child: Text(l10n.edit),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 'delete',
                                                        child: Text(
                                                          l10n.delete,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : null,
                                            onTap: () =>
                                                _mostrarDetalleContacto(
                                                  context,
                                                  contacto,
                                                  isSupervisor,
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
      ),
      floatingActionButton: isSupervisor
          ? general_floatingbutton(
              Icons.add,
              onPressed: () => _abrirFormularioContacto(),
            )
          : null,
    );
  }
}
