import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/usuario_service.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/supervisor/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/llamadas_page.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/usersCreate_page.dart';
import 'package:intl/intl.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/users_page_enums.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/widgets/users_scaffold_body.dart';

// -------- PANTALLA DE USUARIOS --------
// Aquí el supervisor consulta, busca y ordena usuarios llegados del backend.
// Refactorizado siguiendo las mejoras del profesor: widgets separados y mejor organización.
class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  // Servicio que trae los usuarios desde el backend.
  late final UsuarioService _usuarioService;
  // Future cacheado para no lanzar la petición en cada build.
  late Future<List<Usuario>> _usuariosFuture;

  // Estado del filtro seleccionado y del texto del buscador.
  late UsersPageFilter filtroSeleccionado;
  String textoFiltro = '';

  // Orden actualmente seleccionado para la lista.
  UsersPageSort ordenSeleccionado = UsersPageSort.noneAZ;

  @override
  void initState() {
    super.initState();
    filtroSeleccionado = UsersPageFilter.all; // De inicio mostramos todos.
    _usuarioService = UsuarioService(
      baseUrl: 'http://cuidemjunts.zapto.org:3000',
    );
    _usuariosFuture = _cargarUsuariosConContactos(); // Carga inicial.
  }

  /// Llama a backend y trae usuarios (sin contactos de emergencia).
  Future<List<Usuario>> _cargarUsuariosConContactos() async {
    final usuarios = await _usuarioService.getAll();
    return usuarios;
  }

  // Callbacks para actualizar el estado desde los widgets hijos.
  void _onSearchChanged(String value) {
    setState(() => textoFiltro = value);
  }

  void _onFilterChanged(UsersPageFilter value) {
    setState(() => filtroSeleccionado = value);
  }

  void _onSortChanged(UsersPageSort value) {
    setState(() => ordenSeleccionado = value);
  }

  void _mostrarDetalleUsuario(
    BuildContext context,
    Usuario usuario,
    DateFormat dateFormatter,
  ) {
    // TODO: Implementar detalle usuario
  }

  // Aplica búsqueda + filtro + ordenación sobre la lista original.
  List<Usuario> _aplicarFiltros(List<Usuario> usuarios) {
    final query = textoFiltro.trim().toLowerCase();

    // 1) Filtrado por texto y dependencia.
    final filtrados = usuarios.where((usuario) {
      // Coincidencia de texto (nombre completo o DNI).
      final nombreCompleto = '${usuario.nombre} ${usuario.apellidos}'
          .toLowerCase();
      final coincideTexto =
          query.isEmpty ||
          nombreCompleto.contains(query) ||
          usuario.dni.toLowerCase().contains(query);

      // Coincidencia de filtro de dependencia.
      final coincideFiltro = switch (filtroSeleccionado) {
        UsersPageFilter.all => true,
        UsersPageFilter.ningunaDep => usuario.nivelDependencia.isEmpty,
        UsersPageFilter.leve => usuario.nivelDependencia.toUpperCase() == 'G1',
        UsersPageFilter.medio => usuario.nivelDependencia.toUpperCase() == 'G2',
        UsersPageFilter.severo =>
          usuario.nivelDependencia.toUpperCase() == 'G3',
      };

      return coincideTexto && coincideFiltro; // Debe pasar ambas condiciones.
    }).toList();

    // 2) Ordenamos según la opción seleccionada en el botón de filtro/orden.
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

  // Convierte los grados de dependencia en una prioridad numérica para ordenar.
  int _dependencyRank(String nivel) {
    switch (nivel.toUpperCase()) {
      case 'G3':
        return 3;
      case 'G2':
        return 2;
      case 'G1':
        return 1;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // -------- BARRA SUPERIOR --------
      // AppBar con botón de notificaciones (pendiente de implementar).
      appBar: appMainAppBar(
        onNotifications: () {
          // TODO: Acción al pulsar el icono de notificaciones.
        },
      ),

      // -------- MENÚ LATERAL --------
      // Drawer con las secciones principales del supervisor.
      drawer: appDrawer(
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
      // Refactorizado en un widget separado para mejor organización.
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
      ),

      // -------- BOTÓN FLOTANTE --------
      floatingActionButton: general_floatingbutton(
        Icons.add,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CrearUserPage()),
          );
        },
      ),
    );
  }
}
