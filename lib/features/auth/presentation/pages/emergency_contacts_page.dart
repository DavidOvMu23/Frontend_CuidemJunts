import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/contacto_emergencia_service.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/calls_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/notifications_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/grupos_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/emergency_contacts/emergency_contacts_page_enums.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/emergency_contact_create_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';
import 'package:dio/dio.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/emergency_contacts/emergency_contacts_scaffold_body.dart';

// Pantalla principal de contactos de emergencia.
// Muestra la lista de contactos y permite buscar, filtrar, ordenar,
// ver el detalle, crear y editar contactos.
class EmergencyContactsPage extends ConsumerStatefulWidget {
  // Si es true, se muestra incrustada dentro de otra pantalla.
  final bool embedded;

  const EmergencyContactsPage({
    super.key,
    this.embedded = false,
  });

  @override
  ConsumerState<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

// Estado y lógica de la pantalla de contactos de emergencia.
class _EmergencyContactsPageState extends ConsumerState<EmergencyContactsPage> {
  // Servicio para comunicarse con el servidor sobre contactos de emergencia.
  late final ContactoEmergenciaService _contactoService;

  // Resultado de la petición al servidor con todos los contactos.
  late Future<List<ContactoEmergencia>> _contactosFuture;

  // Texto que el usuario escribe en el buscador.
  String textoFiltro = '';

  // Filtro seleccionado: todos, de sistema o externos.
  ContactoEmergenciaFilter filtroSeleccionado = ContactoEmergenciaFilter.all;

  // Orden seleccionado: por nombre A→Z, Z→A, sistema primero o externo primero.
  ContactoEmergenciaSort ordenSeleccionado = ContactoEmergenciaSort.nameAZ;

  // Controla si se está mostrando el formulario de creación de contacto.
  bool _esCreacion = false;

  // Contacto que se está editando. Si es null, no hay edición activa.
  ContactoEmergencia? _contactoEnEdicion;

  // Inicializa el servicio y carga los contactos al abrir la página.
  @override
  void initState() {
    super.initState();
    _contactoService = ref.read(contactoEmergenciaServiceProvider);
    _contactosFuture = _cargarContactos();
  }

  // Pide al servidor la lista de todos los contactos de emergencia.
  Future<List<ContactoEmergencia>> _cargarContactos() async {
    return _contactoService.getAll();
  }

  // Vuelve a cargar los contactos y actualiza la interfaz.
  // Se llama después de crear, editar o eliminar un contacto.
  void _recargarContactos() {
    setState(() {
      _contactosFuture = _cargarContactos();
    });
  }

  // Actualiza el texto de búsqueda y refiltra la lista.
  void _onSearchChanged(String value) {
    setState(() => textoFiltro = value);
  }

  // Actualiza el filtro seleccionado y refiltra la lista.
  void _onFilterChanged(ContactoEmergenciaFilter value) {
    setState(() => filtroSeleccionado = value);
  }

  // Actualiza el orden seleccionado y reordena la lista.
  void _onSortChanged(ContactoEmergenciaSort value) {
    setState(() => ordenSeleccionado = value);
  }

  // Filtra y ordena la lista de contactos en el dispositivo sin llamar al servidor.
  List<ContactoEmergencia> _aplicarFiltros(List<ContactoEmergencia> contactos) {
    final query = textoFiltro.trim().toLowerCase();

    // Paso 1: Filtramos por texto y tipo de contacto.
    final filtrados = contactos.where((contacto) {
      final nombreCompleto = '${contacto.nombre} ${contacto.apellidos}'.toLowerCase();
      // El nombre del paciente con el que está vinculado.
      final paciente = (contacto.pacienteNombre ?? '').toLowerCase();

      // El contacto coincide si el texto aparece en su nombre, teléfono o paciente vinculado.
      final coincideTexto = query.isEmpty ||
          nombreCompleto.contains(query) ||
          contacto.telefono.contains(query) ||
          paciente.contains(query);

      // Los contactos "del sistema" son los que están vinculados a un usuario registrado.
      final esSistema = (contacto.dniUsuarioRef ?? '').isNotEmpty;

      // Filtramos por tipo de contacto según la opción elegida.
      final coincideFiltro = switch (filtroSeleccionado) {
        ContactoEmergenciaFilter.all => true,
        ContactoEmergenciaFilter.sistema => esSistema,
        ContactoEmergenciaFilter.externo => !esSistema,
      };

      return coincideTexto && coincideFiltro;
    }).toList();

    // Paso 2: Ordenamos la lista filtrada.
    filtrados.sort((a, b) {
      final aSistema = (a.dniUsuarioRef ?? '').isNotEmpty;
      final bSistema = (b.dniUsuarioRef ?? '').isNotEmpty;
      return switch (ordenSeleccionado) {
        ContactoEmergenciaSort.nameAZ => a.nombre.compareTo(b.nombre),
        ContactoEmergenciaSort.nameZA => b.nombre.compareTo(a.nombre),
        // Primero los del sistema; si son del mismo tipo, orden alfabético.
        ContactoEmergenciaSort.sistemaPrimero =>
          aSistema == bSistema ? a.nombre.compareTo(b.nombre) : (aSistema ? -1 : 1),
        // Primero los externos; si son del mismo tipo, orden alfabético.
        ContactoEmergenciaSort.externoPrimero =>
          aSistema == bSistema ? a.nombre.compareTo(b.nombre) : (aSistema ? 1 : -1),
      };
    });
    return filtrados;
  }

  // Abre un diálogo con todos los detalles del contacto de emergencia seleccionado.
  // Desde ahí se puede editar (si es supervisor) o eliminar el contacto.
  Future<void> _mostrarDetalleContacto(BuildContext context, ContactoEmergencia contacto, bool isSupervisor, Map<String, String> usuariosMap) async {
    final l10n = AppLocalizations.of(context)!;

    // Obtenemos los nombres de los usuarios asociados a este contacto.
    final asociados = contacto.usuariosDnis.map((d) => usuariosMap[d] ?? d).toList();

    await showDialog(
      context: context,
      builder: (ctx) {
        final textTheme = Theme.of(ctx).textTheme;
        final colorScheme = Theme.of(ctx).colorScheme;
        // Si el contacto tiene DNI de usuario de referencia, es un usuario del sistema.
        final isUsuario = (contacto.dniUsuarioRef ?? '').isNotEmpty;
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        // Función auxiliar que construye una fila con icono, etiqueta y valor.
        Widget detailRow(IconData icon, String label, String value) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 20, color: colorScheme.onSurface),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(value,
                            style: textTheme.bodyMedium
                                ?.copyWith(fontSize: 15)),
                      ],
                    ),
                  ),
                ],
              ),
            );

        // Color de la etiqueta de tipo: verde para sistema, amarillo para externo.
        final badgeBg = isUsuario
            ? (isDark ? AppPalette.successDark : AppPalette.successLight)
            : (isDark ? AppPalette.warningDark : AppPalette.warningLight);
        final badgeFg = isUsuario
            ? (isDark ? AppPalette.successFontDark : AppPalette.successFontLight)
            : (isDark ? AppPalette.warningFontDark : AppPalette.warningFontLight);

        return AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  '${contacto.nombre} ${contacto.apellidos}',
                  style: textTheme.headlineLarge
                      ?.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
                  softWrap: true,
                ),
              ),
              // El botón de editar solo aparece si el usuario es supervisor.
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
                    foregroundColor: colorScheme.primary,
                    padding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Teléfono del contacto.
                  detailRow(Icons.phone_outlined, l10n.telephone,
                      contacto.telefono.isNotEmpty ? contacto.telefono : l10n.notSpecified),
                  // Dirección (solo si tiene una).
                  if (contacto.direccion.isNotEmpty)
                    detailRow(Icons.location_on_outlined, l10n.address, contacto.direccion),
                  // Usuarios con los que está asociado este contacto.
                  detailRow(
                    Icons.people_outline,
                    l10n.users,
                    asociados.isEmpty ? '-' : asociados.join(', '),
                  ),
                  const SizedBox(height: 4),
                  // Tipo de contacto (rol dentro de la aplicación).
                  Text(l10n.role,
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  // Etiqueta de color que indica si es usuario del sistema o contacto externo.
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isUsuario
                              ? Icons.verified_user_outlined
                              : Icons.person_outline,
                          size: 16,
                          color: badgeFg,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isUsuario ? l10n.systemUser : l10n.externalContact,
                          style: textTheme.titleMedium?.copyWith(
                            color: badgeFg,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            // Botón para cerrar sin hacer cambios.
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.close),
            ),
            // El botón de eliminar solo aparece para supervisores y en contactos externos
            // (los contactos del sistema no se pueden borrar directamente).
            if (isSupervisor && (contacto.dniUsuarioRef ?? '').isEmpty)
              general_deletebutton(
                ctx,
                l10n.delete,
                onPressed: () {
                  Navigator.pop(ctx);
                  _confirmarEliminar(contacto);
                },
              ),
          ],
        );
      },
    );
  }

  // Muestra un diálogo de confirmación antes de eliminar un contacto.
  // Maneja casos especiales cuando el contacto está asociado a usuarios.
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
          // Intentamos borrar el contacto del servidor.
          await _contactoService.delete(contacto.id);
          if (!mounted) return;
          _recargarContactos();
          general_snackbar(context, l10n.userDeletedSuccessfully, 2);
        } catch (e) {
          if (!mounted) return;

          // Si el servidor devuelve error 400, puede ser que el contacto esté asociado a usuarios.
          String mensaje = '$e';
          if (e is DioException) {
            final resp = e.response;
            if (resp != null && resp.statusCode == 400) {
              mensaje = resp.data?.toString() ?? e.message ?? e.toString();
              final lower = mensaje.toLowerCase();

              // Si el error indica que hay asociaciones, ofrecemos desvincularlas y borrar.
              if (lower.contains('asociado') || lower.contains('asociadas')) {
                await showConfirmDialog(
                  context,
                  title: l10n.delete,
                  content: 'Este contacto está asociado a uno o varios usuarios. ¿Deseas desvincularlo de todos los usuarios y eliminarlo?',
                  confirmText: l10n.accept,
                  cancelText: l10n.cancel,
                  onConfirm: () async {
                    try {
                      // Primero desvinculamos todas las asociaciones enviando una lista vacía.
                      await _contactoService.update(contacto.id, {'usuariosDnis': []});
                      // Luego borramos el contacto.
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

              // Si el error indica que hay referencias desde el perfil del usuario,
              // indicamos que deben eliminarse desde ahí.
              if (lower.contains('vinculad') || lower.contains('referenc')) {
                general_snackbar_error(context, 'Este contacto está referenciado desde el perfil de un usuario. Elimina la referencia desde el perfil del cliente.', 5);
                return;
              }
            }
            // Para otros errores, mostramos el mensaje del servidor.
            mensaje = resp?.data?.toString() ?? e.message ?? e.toString();
          }
          general_snackbar_error(context, '${l10n.error}: $mensaje', 3);
        }
      },
    );
  }

  // Activa el modo creación o edición de un contacto, mostrando el formulario.
  // Si no se pasa contacto, se crea uno nuevo; si se pasa, se edita el existente.
  void _abrirFormularioContacto({ContactoEmergencia? contacto}) {
    setState(() {
      _contactoEnEdicion = contacto;
      _esCreacion = contacto == null;
    });
  }

  // Construye la interfaz visual completa de la pantalla de contactos.
  @override
  Widget build(BuildContext context) {
    // Leemos los datos del usuario conectado.
    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
    final userRole = authState.rol;
    // Solo los supervisores pueden crear, editar y eliminar contactos.
    final isSupervisor = userRole?.toLowerCase() == AppRoles.supervisor;

    // Número de notificaciones para la barra superior.
    final notificacionesSinLeerAsync = ref.watch(notificacionesSinLeerProvider);

    // Determinamos si hay que mostrar el formulario o la lista.
    final showForm = _esCreacion || _contactoEnEdicion != null;

    // Cuerpo con la lista de contactos, buscador, filtros y ordenación.
    final listBody = EmergencyContactsScaffoldBody(
      contactosFuture: _contactosFuture,
      textoFiltro: textoFiltro,
      filtroSeleccionado: filtroSeleccionado,
      ordenSeleccionado: ordenSeleccionado,
      aplicarFiltros: _aplicarFiltros,
      onSearchChanged: _onSearchChanged,
      onFilterChanged: _onFilterChanged,
      onSortChanged: _onSortChanged,
      onContactoTap: (context, contacto, isSupervisor, usuariosMap) => _mostrarDetalleContacto(context, contacto, isSupervisor, usuariosMap),
      onContactoEdit: (contacto) => _abrirFormularioContacto(contacto: contacto),
    );

    // Si hay formulario activo, lo mostramos en lugar de la lista.
    final pageBody = showForm
        ? EmergencyContactCreatePage(
            contacto: _contactoEnEdicion,
            onCancel: () => setState(() {
              _esCreacion = false;
              _contactoEnEdicion = null;
            }),
            onSaved: () {
              setState(() {
                _esCreacion = false;
                _contactoEnEdicion = null;
                // Recargamos los contactos para reflejar los cambios.
                _contactosFuture = _cargarContactos();
              });
            },
          )
        : listBody;

    // El botón flotante para crear contactos solo aparece si es supervisor.
    final fab = isSupervisor
        ? general_floatingbutton(
            Icons.add,
            onPressed: () => _abrirFormularioContacto(),
          )
        : null;

    // Si está incrustada en otra pantalla, usamos Stack.
    if (widget.embedded) {
      return Stack(
        children: [
          Positioned.fill(child: pageBody),
          if (!showForm && fab != null)
            Positioned(right: 18, bottom: 18, child: fab),
        ],
      );
    }

    // Versión de pantalla completa con barra superior, menú lateral y botón flotante.
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
        context: context,
      ),
      // Menú lateral con acceso a todas las secciones.
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
        onTapGroups: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const GruposPage()));
        },
        onTapPreferences: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PreferencesPage()));
        },
        onTapNotifications: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()));
        },
        // Ya estamos en contactos de emergencia, solo cerramos el menú.
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
      // Ocultamos el botón flotante cuando hay un formulario abierto.
      floatingActionButton: showForm ? null : fab,
    );
  }
}
