import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/usuario_service.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/calls_page.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_create_page.dart';
import 'package:intl/intl.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/users_page_enums.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/widgets/users_scaffold_body.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_edit_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/widgets/user_detail_dialog.dart';

// -------- PANTALLA DE USUARIOS --------
// Controlador principal de la vista de usuarios
// Gestiona el estado (filtros, búsqueda, ordenación) y la carga de datos
class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  // Servicio para peticiones al backend
  late final UsuarioService _usuarioService;

  // Cache del Future para evitar recargas innecesarias al reconstruir el widget
  late Future<List<Usuario>> _usuariosFuture;

  // Estado local de la interfaz
  late UsersPageFilter filtroSeleccionado;
  String textoFiltro = '';
  UsersPageSort ordenSeleccionado = UsersPageSort.noneAZ;

  @override
  void initState() {
    super.initState();
    filtroSeleccionado = UsersPageFilter.all; // Por defecto mostramos todos
    _usuarioService = UsuarioService(
      baseUrl: 'http://cuidemjunts.zapto.org:3000',
    );
    _usuariosFuture = _cargarUsuariosConContactos(); // Iniciamos la carga
  }

  // Obtiene la lista completa de usuarios del servidor
  Future<List<Usuario>> _cargarUsuariosConContactos() async {
    final usuarios = await _usuarioService.getAll();
    return usuarios;
  }

  // --- Métodos para actualizar el estado desde los widgets hijos ---

  // Actualiza el texto de búsqueda
  void _onSearchChanged(String value) {
    setState(() => textoFiltro = value);
  }

  // Actualiza el filtro seleccionado
  void _onFilterChanged(UsersPageFilter value) {
    setState(() => filtroSeleccionado = value);
  }

  // Actualiza el orden seleccionado
  void _onSortChanged(UsersPageSort value) {
    setState(() => ordenSeleccionado = value);
  }

  // Muestra el detalle de un usuario
  void _mostrarDetalleUsuario(
    BuildContext context,
    Usuario usuario,
    DateFormat dateFormatter,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => UserDetailDialog(
        usuario: usuario,
        dateFormatter: dateFormatter,
        onDelete: () async {
          try {
            await _usuarioService.delete(usuario.dni);
            if (!context.mounted) return;
            Navigator.pop(ctx); // Cerrar diálogo
            general_snackbar(context, 'Usuario eliminado correctamente', 2);
            // Recargar lista
            setState(() {
              _usuariosFuture = _cargarUsuariosConContactos();
            });
          } catch (e) {
            if (!context.mounted) return;
            general_snackbar_error(context, 'Error al eliminar usuario', 3);
          }
        },
        onEdit: () => _editarUsuario(context, usuario),
      ),
    );
  }

  void _editarUsuario(BuildContext context, Usuario usuario) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditarUserPage(usuario: usuario)),
    );

    // Si se editó correctamente, recarga la lista
    if (resultado == true) {
      setState(() {
        _usuariosFuture = _cargarUsuariosConContactos();
      });
    }
  }

  // Filtra y ordena la lista de usuarios según el estado actual
  // Se ejecuta en el cliente sobre los datos ya cargados
  List<Usuario> _aplicarFiltros(List<Usuario> usuarios) {
    final query = textoFiltro.trim().toLowerCase();

    // 1. Filtrado
    final filtrados = usuarios.where((usuario) {
      // Coincidencia de texto (nombre completo o DNI)
      final nombreCompleto = '${usuario.nombre} ${usuario.apellidos}'
          .toLowerCase();

      print(
        'Usuario: ${usuario.nombre}, Dependencia: "${usuario.nivelDependencia}"',
      );
      final coincideTexto =
          query.isEmpty ||
          nombreCompleto.contains(query) ||
          usuario.telefono.contains(query);
      // Coincidencia de filtro de dependencia
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

    // 2. Ordenación
    filtrados.sort((a, b) {
      switch (ordenSeleccionado) {
        case UsersPageSort.nameZA:
          return b.nombre.compareTo(a.nombre);
        case UsersPageSort.noneAZ:
          return a.nombre.compareTo(b.nombre);
        case UsersPageSort.dateBirthOldest:
          return a.f_nac.compareTo(b.f_nac);
        case UsersPageSort.dateBirthNewest:
          return b.f_nac.compareTo(a.f_nac);
        case UsersPageSort.dependencyHighLow:
          return _dependencyRank(b.nivelDependencia) -
              _dependencyRank(a.nivelDependencia);
        case UsersPageSort.dependencyLowHigh:
          return _dependencyRank(a.nivelDependencia) -
              _dependencyRank(b.nivelDependencia);
      }
    });

    return filtrados;
  }

  // Helper para convertir el nivel de dependencia en un valor numérico comparable
  int _dependencyRank(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'severa':
        return 3;
      case 'moderada':
        return 2;
      case 'leve':
        return 1;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // -------- OBTENER NOMBRE DEL USUARIO DESDE RIVERPOD --------
    // Obtenemos el estado de autenticación del provider
    final authState = ref.watch(authProvider);
    String? userName;
    String? userRole;

    if (authState.userData != null) {
      try {
        // Convertimos el JSON a un Map
        final userData =
            jsonDecode(authState.userData!) as Map<String, dynamic>;

        // Intentamos obtener el nombre del usuario
        userName =
            userData['nombre']?.toString() ??
            userData['name']?.toString() ??
            userData['correo']?.toString() ??
            userData['email']?.toString();
        userRole = userData['rol']?.toString();
      } catch (e) {
        // Si hay error al parsear el JSON, simplemente no mostramos nombre
        userName = null;
      }
    }

    //
    return Scaffold(
      // -------- BARRA SUPERIOR --------
      appBar: appMainAppBar(
        onNotifications: () {
          // TODO: Acción al pulsar el icono de notificaciones.
        },
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
      body: UsersScaffoldBody(
        usuariosFuture: _usuariosFuture,
        filtroSeleccionado: filtroSeleccionado,
        ordenSeleccionado: ordenSeleccionado,
        textoFiltro: textoFiltro,
        aplicarFiltros: _aplicarFiltros,
        onSearchChanged: _onSearchChanged,
        onFilterChanged: _onFilterChanged,
        onSortChanged: _onSortChanged,
        onUsuarioTap: _mostrarDetalleUsuario,
        onUsuarioEdit: _editarUsuario,
      ),

      // -------- BOTÓN FLOTANTE --------
      floatingActionButton: general_floatingbutton(
        Icons.add,
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CrearUserPage()),
          );
          if (resultado == true) {
            setState(() {
              _usuariosFuture = _cargarUsuariosConContactos();
            });
          }
        },
      ),
    );
  }
}
