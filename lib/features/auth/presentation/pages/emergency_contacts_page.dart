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
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/emergency_contact_create_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';
import 'package:dio/dio.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/emergency_contacts/emergency_contacts_scaffold_body.dart';

class EmergencyContactsPage extends ConsumerStatefulWidget {
  final bool embedded;

  const EmergencyContactsPage({
    super.key,
    this.embedded = false,
  });

  @override
  ConsumerState<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
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
      final paciente = (contacto.pacienteNombre ?? '').toLowerCase();
        return query.isEmpty ||
          nombreCompleto.contains(query) ||
          contacto.telefono.contains(query) ||
          paciente.contains(query);
    }).toList();

    filtrados.sort((a, b) => a.nombre.compareTo(b.nombre));
    return filtrados;
  }

  Future<void> _mostrarDetalleContacto(BuildContext context, ContactoEmergencia contacto, bool isSupervisor, Map<String, String> usuariosMap) async {
    final l10n = AppLocalizations.of(context)!;

    final asociados = contacto.usuariosDnis.map((d) => usuariosMap[d] ?? d).toList();

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
                (contacto.dniUsuarioRef == null || contacto.dniUsuarioRef!.trim().isEmpty)
                  ? IconButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        // Esperar un microtask antes de abrir otro diálogo para evitar
                        // conflictos en el árbol de widgets (evita la assertion sobre ancestor).
                        Future.microtask(() => _abrirFormularioContacto(contacto: contacto));
                      },
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: l10n.edit,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      style: IconButton.styleFrom(
                        foregroundColor: Theme.of(ctx).colorScheme.primary,
                        padding: EdgeInsets.zero,
                      ),
                    )
                  : IconButton(
                      onPressed: () {
                        general_snackbar(context, 'Edita este contacto desde el perfil del usuario asociado', 3);
                      },
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'No editable desde aquí',
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      style: IconButton.styleFrom(
                        foregroundColor: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.4),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.phone_outlined),
                  const SizedBox(width: 12),
                  Expanded(child: Text('${l10n.phone}: ${contacto.telefono}')),
                ],
              ),
                    const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.badge_outlined),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Usuarios: ${asociados.isEmpty ? '-' : asociados.join(', ')}')),
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
          // Intentar manejar caso en que backend devuelve 400 porque el contacto
          // está asociado a usuarios. En ese caso ofrecemos desvincular y borrar.
          String mensaje = '$e';
          if (e is DioException) {
            final resp = e.response;
            if (resp != null && resp.statusCode == 400) {
              mensaje = resp.data?.toString() ?? e.message ?? e.toString();
              final lower = mensaje.toLowerCase();
              if (lower.contains('asociado') || lower.contains('asociadas')) {
                // Ofrecer desvincular asociaciones many-to-many y borrar
                await showConfirmDialog(
                  context,
                  title: l10n.delete,
                  content: 'Este contacto está asociado a uno o varios usuarios. ¿Deseas desvincularlo de todos los usuarios y eliminarlo?',
                  confirmText: l10n.accept,
                  cancelText: l10n.cancel,
                  onConfirm: () async {
                    try {
                      // Desvincular associations mediante PATCH { usuariosDnis: [] }
                      await _contactoService.update(contacto.id, {'usuariosDnis': []});
                      await _contactoService.delete(contacto.id);
                      if (!mounted) return;
                      _recargarContactos();
                      general_snackbar(context, l10n.userDeletedSuccessfully, 2);
                    } catch (e2) {
                      if (!mounted) return;
                      general_snackbar_error(context, '${l10n.error}: $e2', 4);
                    }
                  },
                );
                return;
              }
              if (lower.contains('vinculad') || lower.contains('referenc')) {
                // Indicar que debe desvincularse desde el perfil del usuario
                general_snackbar_error(context, 'Este contacto está referenciado desde el perfil de un usuario. Elimina la referencia desde el perfil del cliente.', 5);
                return;
              }
            }
            // si no era 400 con mensaje esperable, usar el mensaje bruto
            mensaje = resp?.data?.toString() ?? e.message ?? e.toString();
          }
          general_snackbar_error(context, '${l10n.error}: $mensaje', 3);
        }
      },
    );
  }

  Future<void> _abrirFormularioContacto({ContactoEmergencia? contacto}) async {
    // Navegar a la página de crear/editar contactos en vez de abrir un diálogo.
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EmergencyContactCreatePage(contacto: contacto)),
    );

    if (resultado == true) _recargarContactos();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
    final userRole = authState.rol;
    final isSupervisor = userRole?.toLowerCase() == 'supervisor';

    final notificacionesSinLeerAsync = ref.watch(notificacionesSinLeerProvider);

    final pageBody = EmergencyContactsScaffoldBody(
      contactosFuture: _contactosFuture,
      textoFiltro: textoFiltro,
      aplicarFiltros: _aplicarFiltros,
      onSearchChanged: _onSearchChanged,
      onContactoTap: (context, contacto, isSupervisor, usuariosMap) => _mostrarDetalleContacto(context, contacto, isSupervisor, usuariosMap),
      onContactoEdit: (contacto) => _abrirFormularioContacto(contacto: contacto),
    );

    final fab = isSupervisor
        ? general_floatingbutton(
            Icons.add,
            onPressed: () => _abrirFormularioContacto(),
          )
        : null;

    if (widget.embedded) {
      if (fab == null) {
        return pageBody;
      }

      return Stack(
        children: [
          pageBody,
          Positioned(right: 18, bottom: 18, child: fab),
        ],
      );
    }

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
      body: pageBody,
      floatingActionButton: fab,
    );
  }
}
