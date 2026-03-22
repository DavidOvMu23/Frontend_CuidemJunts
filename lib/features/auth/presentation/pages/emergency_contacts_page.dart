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
import 'package:frontend_cuidemjunts/features/auth/presentation/emergency_contacts/emergency_contacts_scaffold_body.dart';

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
      final nombreCompleto = '${contacto.nombre} ${contacto.apellidos}'.toLowerCase();
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

    return (contacto.dniUsuarioRef ?? '').trim().isEmpty ? '-' : contacto.dniUsuarioRef!;
  }

  Future<void> _mostrarDetalleContacto(BuildContext context, ContactoEmergencia contacto, bool isSupervisor) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: Text(
                '${contacto.nombre} ${contacto.apellidos}',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (isSupervisor)
              IconButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _abrirFormularioContacto(contacto: contacto);
                },
                icon: const Icon(Icons.edit, size: 20),
                tooltip: l10n.edit,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  foregroundColor: Theme.of(ctx).colorScheme.primary,
                  padding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              // Teléfono
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.phone_outlined),
                  const SizedBox(width: 12),
                  Expanded(child: Text('${l10n.phone}: ${contacto.telefono}')),
                ],
              ),
              const SizedBox(height: 12),
              // Relación
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.people_outline),
                  const SizedBox(width: 12),
                  Expanded(child: Text('${l10n.relation}: ${contacto.relacion}')),
                ],
              ),
              const SizedBox(height: 12),
              // Referencia a usuario
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.badge_outlined),
                  const SizedBox(width: 12),
                  Expanded(child: Text('${l10n.refersToUser}: ${_pacienteTexto(contacto)}')),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close),
          ),
          if (isSupervisor)
            general_deletebutton(
              ctx,
              l10n.delete,
              onPressed: () {
                Navigator.pop(ctx);
                _confirmarEliminar(contacto);
              },
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
      content: '${l10n.deleteUserContent}\n\n${contacto.nombre} ${contacto.apellidos}',
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
    final apellidosCtrl = TextEditingController(text: contacto?.apellidos ?? '');
    final telefonoCtrl = TextEditingController(text: contacto?.telefono ?? '');
    final relacionCtrl = TextEditingController(text: contacto?.relacion ?? '');
    String? selectedDni = (contacto?.dniUsuarioRef ?? '').trim().isEmpty ? null : contacto!.dniUsuarioRef;

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
                  general_textfield_NoICON(l10n.lastName, controller: apellidosCtrl),
                  const SizedBox(height: 10),
                  general_textfield_NoICON(l10n.phone, controller: telefonoCtrl),
                  const SizedBox(height: 10),
                  general_textfield_NoICON(l10n.relation, controller: relacionCtrl),
                  const SizedBox(height: 10),
                  FutureBuilder<List<Usuario>>(
                    future: usuariosFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Text('${l10n.error}: ${snapshot.error}', style: TextStyle(color: Theme.of(context).colorScheme.error));
                      }

                      final usuarios = snapshot.data ?? [];
                      if (selectedDni != null && !usuarios.any((u) => u.dni == selectedDni)) {
                        selectedDni = null;
                      }

                      return DropdownButtonFormField<String?>(
                        value: selectedDni,
                        borderRadius: BorderRadius.circular(12),
                        decoration: InputDecoration(
                          labelText: l10n.refersToUser,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(value: null, child: Text('Sin paciente asignado')),
                          ...usuarios.map((u) => DropdownMenuItem<String?>(value: u.dni, child: Text('${u.nombre} ${u.apellidos} (${u.dni})', overflow: TextOverflow.ellipsis))),
                        ],
                        onChanged: (value) {
                          setLocalState(() { selectedDni = value; });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
              FilledButton(
                onPressed: () async {
                  final nombre = nombreCtrl.text.trim();
                  final apellidos = apellidosCtrl.text.trim();
                  final telefono = telefonoCtrl.text.trim();
                  final relacion = relacionCtrl.text.trim();

                  if (nombre.isEmpty || apellidos.isEmpty || telefono.isEmpty || relacion.isEmpty) {
                    general_snackbar_error(context, l10n.fillAllFields, 2);
                    return;
                  }

                  final payload = <String, dynamic>{'nombre': nombre, 'apellidos': apellidos, 'telefono': telefono, 'relacion': relacion};
                  if (selectedDni != null) payload['dniUsuarioRef'] = selectedDni; else if (isEdit) payload['dniUsuarioRef'] = '';

                  try {
                    if (isEdit) await _contactoService.update(contacto!.id, payload); else await _contactoService.create(payload);
                    if (!mounted) return;
                    Navigator.pop(ctx);
                    _recargarContactos();
                    general_snackbar(context, isEdit ? l10n.userUpdatedSuccess : l10n.userCreatedSuccess, 2);
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()));
        },
      ),
      drawer: appDrawer(
        userName: userName,
        userRole: userRole,
        context: context,
        selected: DrawerItem.emergencyContacts,
        onTapHome: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeSupervisorPage()));
        },
        onTapCalls: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const LlamadasPage()));
        },
        onTapUsers: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const UsersPage()));
        },
        onTapTelemarketers: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkersPage()));
        },
        onTapPreferences: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PreferencesPage()));
        },
        onTapNotifications: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()));
        },
        onTapEmergencyContacts: () {
          Navigator.pop(context);
        },
        onLogoutConfirmed: () async {
          await ref.read(authProvider.notifier).logout();
          if (!context.mounted) return;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
        },
      ),
      body: EmergencyContactsScaffoldBody(
        contactosFuture: _contactosFuture,
        textoFiltro: textoFiltro,
        aplicarFiltros: _aplicarFiltros,
        onSearchChanged: _onSearchChanged,
        onContactoTap: (context, contacto, isSupervisor) => _mostrarDetalleContacto(context, contacto, isSupervisor),
        onContactoEdit: (contacto) => _abrirFormularioContacto(contacto: contacto),
      ),
      floatingActionButton: isSupervisor ? general_floatingbutton(Icons.add, onPressed: () => _abrirFormularioContacto()) : null,
    );
  }
}
