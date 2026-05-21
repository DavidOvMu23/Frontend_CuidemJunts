import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/calls_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/emergency_contacts_page.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/grupos_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_create_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/notifications_page.dart';
import 'package:intl/intl.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/users_page_enums.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/widgets/users_scaffold_body.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/widgets/user_detail_dialog.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/usuario_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/contacto_emergencia_service.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

// -------- PANTALLA DE USUARIOS --------
// Controlador principal de la vista de usuarios (personas atendidas por el servicio).
// Gestiona el estado (filtros, búsqueda, ordenación) y la carga de datos desde el servidor.
class UsersPage extends ConsumerStatefulWidget {
  // Si es true, la página se muestra incrustada dentro de otra sin barra de navegación propia.
  final bool embedded;

  const UsersPage({
    super.key,
    this.embedded = false,
  });

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  // Filtro actualmente seleccionado (por defecto se muestran todos).
  late UsersPageFilter filtroSeleccionado;

  // Texto que el usuario escribe en la barra de búsqueda.
  String textoFiltro = '';

  // Orden actualmente seleccionado (por defecto A→Z).
  UsersPageSort ordenSeleccionado = UsersPageSort.noneAZ;

  // Controla si se está mostrando el formulario de creación de usuario.
  bool _esCreacion = false;

  // Usuario que se está editando. Si es null, no hay edición activa.
  Usuario? _usuarioEnEdicion;

  // Se ejecuta una sola vez al abrir la página para cargar los datos iniciales.
  @override
  void initState() {
    super.initState();
    // Por defecto mostramos todos los usuarios sin filtrar.
    filtroSeleccionado = UsersPageFilter.all;
  }

  // --- Métodos que actualizan el estado cuando los widgets hijos cambian algo ---

  // Actualiza el texto de búsqueda y refiltra la lista.
  void _onSearchChanged(String value) {
    setState(() => textoFiltro = value);
  }

  // Actualiza el filtro de nivel de dependencia y refiltra la lista.
  void _onFilterChanged(UsersPageFilter value) {
    setState(() => filtroSeleccionado = value);
  }

  // Actualiza el orden y reordena la lista.
  void _onSortChanged(UsersPageSort value) {
    setState(() => ordenSeleccionado = value);
  }

  // Abre el diálogo de detalle de un usuario concreto.
  // Intenta cargar también sus contactos de emergencia del servidor.
  Future<void> _mostrarDetalleUsuario(
    BuildContext context,
    Usuario usuario,
    DateFormat dateFormatter,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    // Intentamos obtener la lista actualizada de contactos de emergencia del usuario.
    List<ContactoEmergencia> contactosCanonicos = [];
    try {
      final contactoService = ref.read(contactoEmergenciaServiceProvider);
      contactosCanonicos = await contactoService.getByUsuario(usuario.dni);
    } catch (e) {
      // Si falla, continuamos mostrando los contactos que ya vienen con el usuario.
    }

    // Comprobamos si el usuario conectado es supervisor para mostrar botones de edición/borrado.
    final isSupervisor = (ref.read(authProvider).rol ?? '').toLowerCase() == AppRoles.supervisor;

    showDialog(
      context: context,
      builder: (ctx) => UserDetailDialog(
        usuario: usuario,
        dateFormatter: dateFormatter,
        contactosCanonicos: contactosCanonicos,
        // El botón de borrar solo aparece si es supervisor.
        onDelete: isSupervisor ? () async {
          try {
            final usuarioService = ref.read(usuarioServiceProvider);
            // Borramos el usuario del servidor usando su DNI.
            await usuarioService.delete(usuario.dni);
            if (!context.mounted) return;
            Navigator.pop(ctx);
            general_snackbar(context, l10n.userDeletedSuccessfully, 2);
            // Invalidamos el provider para que el polling traiga la lista
            // actualizada inmediatamente.
            ref.invalidate(usuariosProvider);
          } catch (e) {
            if (!context.mounted) return;
            general_snackbar_error(context, '${l10n.error}: ${extractErrorMessage(e)}', 5);
          }
        } : null,
        // El botón de editar solo aparece si es supervisor.
        onEdit: isSupervisor ? () => _editarUsuario(context, usuario) : null,
      ),
    );
  }

  // Activa el modo edición para un usuario concreto, mostrando el formulario de edición.
  void _editarUsuario(BuildContext context, Usuario usuario) {
    setState(() {
      _usuarioEnEdicion = usuario;
      _esCreacion = false;
    });
  }

  // Filtra y ordena la lista de usuarios en el dispositivo (sin llamar al servidor de nuevo).
  // Se ejecuta cada vez que cambia el texto de búsqueda, el filtro o el orden.
  List<Usuario> _aplicarFiltros(List<Usuario> usuarios) {
    final query = textoFiltro.trim().toLowerCase();

    // Paso 1: Filtrado por texto y nivel de dependencia.
    final filtrados = usuarios.where((usuario) {
      // Buscamos en el nombre completo y en el teléfono.
      final nombreCompleto = '${usuario.nombre} ${usuario.apellidos}'
          .toLowerCase();

      final coincideTexto =
          query.isEmpty ||
          nombreCompleto.contains(query) ||
          usuario.telefono.contains(query);

      // Filtramos por el nivel de dependencia seleccionado.
      final coincideFiltro = switch (filtroSeleccionado) {
        UsersPageFilter.all => true,
        UsersPageFilter.ningunaDep =>
          usuario.nivelDependencia.toLowerCase() == 'ninguna' ||
              usuario.nivelDependencia.isEmpty,
        UsersPageFilter.leve =>
          usuario.nivelDependencia.toLowerCase() == 'leve',
        UsersPageFilter.medio =>
          usuario.nivelDependencia.toLowerCase() == 'moderada',
        UsersPageFilter.severo =>
          usuario.nivelDependencia.toLowerCase() == 'severa',
      };

      return coincideTexto && coincideFiltro;
    }).toList();

    // Paso 2: Ordenación de la lista filtrada.
    filtrados.sort((a, b) {
      switch (ordenSeleccionado) {
        case UsersPageSort.nameZA:
          return b.nombre.compareTo(a.nombre);
        case UsersPageSort.noneAZ:
          return a.nombre.compareTo(b.nombre);
        // Los más mayores primero (fecha de nacimiento más antigua).
        case UsersPageSort.dateBirthOldest:
          return a.f_nac.compareTo(b.f_nac);
        // Los más jóvenes primero (fecha de nacimiento más reciente).
        case UsersPageSort.dateBirthNewest:
          return b.f_nac.compareTo(a.f_nac);
        // De mayor a menor dependencia (más grave primero).
        case UsersPageSort.dependencyHighLow:
          return _dependencyRank(b.nivelDependencia) -
              _dependencyRank(a.nivelDependencia);
        // De menor a mayor dependencia (menos grave primero).
        case UsersPageSort.dependencyLowHigh:
          return _dependencyRank(a.nivelDependencia) -
              _dependencyRank(b.nivelDependencia);
      }
    });

    return filtrados;
  }

  // Convierte el nivel de dependencia en un número para poder comparar y ordenar.
  // Mayor número = mayor nivel de dependencia.
  int _dependencyRank(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'severa':
        return 3;
      case 'moderada':
        return 2;
      case 'leve':
        return 1;
      default:
        // 'ninguna' u otros valores desconocidos = nivel 0.
        return 0;
    }
  }

  // Construye toda la interfaz visual de la pantalla de usuarios.
  @override
  Widget build(BuildContext context) {
    // Leemos los datos del usuario que ha iniciado sesión.
    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
    final userRole = authState.rol;
    // Solo los supervisores pueden crear, editar y borrar usuarios.
    final isSupervisor = (userRole ?? '').toLowerCase() == AppRoles.supervisor;
    // Número de notificaciones sin leer para la barra superior.
    final notificacionesSinLeerAsync = ref.watch(notificacionesSinLeerProvider);
    // Lista de usuarios en tiempo real (refresca sola cada 10s vía polling).
    final usuariosAsync = ref.watch(usuariosProvider);

    // Si es supervisor y hay formulario activo, mostramos el formulario.
    final showForm = isSupervisor && (_esCreacion || _usuarioEnEdicion != null);

    // Cuerpo de la lista de usuarios con buscador, filtro y ordenación.
    final listBody = UsersScaffoldBody(
      usuariosAsync: usuariosAsync,
      filtroSeleccionado: filtroSeleccionado,
      ordenSeleccionado: ordenSeleccionado,
      textoFiltro: textoFiltro,
      aplicarFiltros: _aplicarFiltros,
      onSearchChanged: _onSearchChanged,
      onFilterChanged: _onFilterChanged,
      onSortChanged: _onSortChanged,
      onUsuarioTap: _mostrarDetalleUsuario,
      onUsuarioEdit: _editarUsuario,
    );

    // Si hay formulario activo, lo mostramos en lugar de la lista.
    final pageBody = showForm
        ? CrearUserPage(
            usuario: _usuarioEnEdicion,
            // Al cancelar, volvemos a la lista sin guardar.
            onCancel: () => setState(() {
              _esCreacion = false;
              _usuarioEnEdicion = null;
            }),
            // Al guardar, volvemos a la lista y forzamos refresco inmediato.
            onSaved: () {
              setState(() {
                _esCreacion = false;
                _usuarioEnEdicion = null;
              });
              ref.invalidate(usuariosProvider);
            },
          )
        : listBody;

    // Botón flotante para crear un nuevo usuario.
    final fab = general_floatingbutton(
      Icons.add,
      onPressed: () {
        setState(() {
          _esCreacion = true;
          _usuarioEnEdicion = null;
        });
      },
    );

    // Si está incrustada en otra pantalla, usamos Stack para el botón flotante.
    if (widget.embedded) {
      return Stack(
        children: [
          Positioned.fill(child: pageBody),
          // El botón flotante solo aparece para supervisores y cuando no hay formulario.
          if (!showForm && isSupervisor) Positioned(right: 18, bottom: 18, child: fab),
        ],
      );
    }

    // Versión de pantalla completa con barra superior, menú lateral y botón flotante.
    return Scaffold(
      // -------- BARRA SUPERIOR --------
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
        context: context,
      ),

      // -------- MENÚ LATERAL --------
      drawer: appDrawer(
        userName: userName,
        userRole: userRole,
        context: context,
        selected: DrawerItem.users,
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
        onTapEmergencyContacts: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EmergencyContactsPage(),
            ),
          );
        },
        onTapTelemarketers: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WorkersPage()),
          );
        },
        onTapGroups: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GruposPage()),
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
        onLogoutConfirmed: () async {
          await ref.read(authProvider.notifier).logout();
          if (!context.mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
      ),

      // -------- CONTENIDO PRINCIPAL --------
      body: pageBody,

      // -------- BOTÓN FLOTANTE --------
      // Se oculta si hay un formulario abierto o si el usuario no es supervisor.
      floatingActionButton: (showForm || !isSupervisor) ? null : fab,
    );
  }
}
