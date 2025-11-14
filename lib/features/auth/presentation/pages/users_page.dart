import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:frontend_cuidemjunts/features/auth/data/service/usuario_service.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/supervisor/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/llamadas_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/teleoperador_page.dart';

// -------- PANTALLA DE USUARIOS --------
// Aquí el supervisor consulta, busca y ordena usuarios llegados del backend.
class UsersPage extends StatefulWidget {
  // Callback que cambia el tema de la app.
  // Si es true, activa modo oscuro; si es false, modo claro.
  // Se utiliza para que el cambio de tema afecte a toda la app.
  final void Function(bool) onToggleTheme;

  // Callback que cambia el idioma de la app.
  // Se utiliza para que el cambio de idioma afecte a toda la app.
  final void Function(Locale) onChangeLocale;

  const UsersPage({
    super.key,
    required this.onToggleTheme,
    required this.onChangeLocale,
  });

  @override
  State<UsersPage> createState() => _UsersPageState();
}

// Filtros disponibles de la busqueda de usuarios.
enum UserFilter { all, active, inactive, leve, moderada, severa, ninguna }

// Modos de ordenación disponibles para la lista de usuarios.
enum UserSort {
  none,
  nameZA,
  dependencyHighLow,
  dependencyLowHigh,
  accountStatusOrder,
}

class _UsersPageState extends State<UsersPage> {
  // Servicio que trae los usuarios desde el backend.
  late final UsuarioService _usuarioService;
  // Future que cacheamos para no disparar peticiones en cada build.
  late Future<List<Usuario>> _usuariosFuture;
  // Estado del filtro seleccionado y del texto del buscador.
  late UserFilter filtroSeleccionado;
  late String textoFiltro = '';

  /// Orden actualmente seleccionado para la lista.
  UserSort ordenSeleccionado = UserSort.none;

  @override
  void initState() {
    super.initState();
    filtroSeleccionado = UserFilter.all; // De inicio mostramos todos.
    _usuarioService = UsuarioService(baseUrl: 'http://localhost:3000');
    _usuariosFuture = _usuarioService.getAll(); // Carga inicial.
  }

  // Aplica búsqueda + filtro + ordenación sobre la lista original.
  List<Usuario> _aplicarFiltros(List<Usuario> usuarios) {
    final query = textoFiltro.trim().toLowerCase();
    final filtrados = usuarios.where((usuario) {
      final nombreCompleto = '${usuario.nombre} ${usuario.apellidos}'
          .toLowerCase();
      final coincideTexto =
          query.isEmpty ||
          nombreCompleto.contains(query) ||
          usuario.dni.toLowerCase().contains(query);

      final coincideFiltro = switch (filtroSeleccionado) {
        UserFilter.all => true,
        UserFilter.active => usuario.estadoCuenta.toLowerCase() == 'activo',
        UserFilter.inactive => usuario.estadoCuenta.toLowerCase() != 'activo',
        UserFilter.leve => usuario.nivelDependencia.toUpperCase() == 'G1',
        UserFilter.moderada => usuario.nivelDependencia.toUpperCase() == 'G2',
        UserFilter.severa => usuario.nivelDependencia.toUpperCase() == 'G3',
        UserFilter.ninguna =>
          usuario.nivelDependencia.toUpperCase() == 'NINGUNA',
      };

      return coincideTexto && coincideFiltro;
    }).toList();

    filtrados.sort((a, b) {
      switch (ordenSeleccionado) {
        case UserSort.nameZA:
          return b.nombre.compareTo(a.nombre);
        case UserSort.dependencyHighLow:
          return _dependencyRank(b.nivelDependencia) -
              _dependencyRank(a.nivelDependencia);
        case UserSort.dependencyLowHigh:
          return _dependencyRank(a.nivelDependencia) -
              _dependencyRank(b.nivelDependencia);
        case UserSort.accountStatusOrder:
          return _estadoCuentaRank(a.estadoCuenta) -
              _estadoCuentaRank(b.estadoCuenta);
        case UserSort.none:
          return 0;
      }
    });

    return filtrados;
  }

  // Convierte los grados de dependencia en una prioridad numérica.
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

  // Primero los activos, después el resto.
  int _estadoCuentaRank(String estado) {
    return estado.toLowerCase() == 'activo' ? 0 : 1;
  }

  @override
  Widget build(BuildContext context) {
    // Me guardo tipografías y paleta para reutilizarlas.
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Textos traducidos según el idioma actual.
    final l10n = AppLocalizations.of(context)!;

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
            MaterialPageRoute(
              builder: (context) => HomeSupervisorPage(
                onToggleTheme: widget.onToggleTheme,
                onChangeLocale: widget.onChangeLocale,
              ),
            ),
          );
        },
        onTapCalls: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LlamadasPage(
                onToggleTheme: widget.onToggleTheme,
                onChangeLocale: widget.onChangeLocale,
              ),
            ),
          );
        },
        onTapTelemarketers: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TelemarketersPage(
                onToggleTheme: widget.onToggleTheme,
                onChangeLocale: widget.onChangeLocale,
              ),
            ),
          );
        },
        onTapPreferences: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PreferencesPage(
                onToggleTheme: widget.onToggleTheme,
                onChangeLocale: widget.onChangeLocale,
              ),
            ),
          );
        },
        onLogoutConfirmed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(
                onToggleTheme: widget.onToggleTheme,
                onChangeLocale: widget.onChangeLocale,
              ),
            ),
          );
        },
      ),

      // -------- CONTENIDO PRINCIPAL --------
      // Stack para poder superponer el botón flotante.
      body: Stack(
        children: [
          // Positioned.fill para que el scroll ocupe todo el alto disponible.
          Positioned.fill(
            child: SingleChildScrollView(
              // Scroll general para toda la pantalla.
              padding: const EdgeInsets.symmetric(horizontal: 16.0),

              // ConstrainedBox para estirar la columna al ancho máximo.
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),

                // Columna general con todo el contenido.
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // -------- TITULAR --------
                    Text(
                      l10n.users,
                      style: textTheme.titleMedium?.copyWith(fontSize: 27),
                    ),
                    Text(l10n.manageUsers, style: textTheme.bodyMedium),
                    const SizedBox(height: 20),

                    // -------- TARJETA PRINCIPAL --------
                    Material(
                      borderRadius: BorderRadius.circular(30),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),

                        // Columna con filtros + lista.
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // -------- BÚSQUEDA --------
                            Text(
                              l10n.searchUsers,
                              textAlign: TextAlign.left,
                              style: textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // TextField de búsqueda.
                            general_busqueda_textfield(
                              l10n.searchUser,
                              icono: Icons.search,
                              onChanged: (value) {
                                setState(() {
                                  textoFiltro = value;
                                });
                              },
                            ),
                            const SizedBox(height: 20),

                            // -------- FILTRO --------
                            Row(
                              children: [
                                // Ícono que indica si hay filtro activo o no.
                                Icon(
                                  filtroSeleccionado != UserFilter.all
                                      ? Icons.filter_alt
                                      : Icons.filter_alt_off,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 16),

                                // Dropdown expandido para ocupar todo el ancho.
                                Expanded(
                                  // Dropdown para seleccionar el filtro.
                                  child: DropdownButtonFormField<UserFilter>(
                                    initialValue: filtroSeleccionado,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    borderRadius: BorderRadius.circular(12),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),

                                    // Opciones del dropdown.
                                    items: [
                                      DropdownMenuItem<UserFilter>(
                                        value: UserFilter.all,
                                        child: Text(l10n.searchAllUsers),
                                      ),
                                      DropdownMenuItem<UserFilter>(
                                        value: UserFilter.active,
                                        child: Text(l10n.searchActiveUsers),
                                      ),
                                      DropdownMenuItem<UserFilter>(
                                        value: UserFilter.inactive,
                                        child: Text(l10n.searchInactiveUsers),
                                      ),
                                      DropdownMenuItem<UserFilter>(
                                        value: UserFilter.leve,
                                        child: Text(
                                          l10n.searchModerateDependency,
                                        ),
                                      ),
                                      DropdownMenuItem<UserFilter>(
                                        value: UserFilter.moderada,
                                        child: Text(
                                          l10n.searchSevereDependency,
                                        ),
                                      ),
                                      DropdownMenuItem<UserFilter>(
                                        value: UserFilter.severa,
                                        child: Text(l10n.searchHighDependency),
                                      ),
                                    ],
                                    // Actualizamos el filtro cuando cambia.
                                    onChanged: (UserFilter? newValue) {
                                      setState(() {
                                        filtroSeleccionado =
                                            newValue ?? UserFilter.all;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Divider(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                            ),

                            const SizedBox(height: 10),
                            // -------- LISTA DE USUARIOS --------
                            // FutureBuilder conectado al endpoint de usuarios.
                            FutureBuilder<List<Usuario>>(
                              future: _usuariosFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  // Loader centrado mientras llega la respuesta.
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 32),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                if (snapshot.hasError) {
                                  // Mensaje genérico cuando algo falla.
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text('Error al cargar usuarios'),
                                  );
                                }

                                // Lista original del backend.
                                final usuarios = snapshot.data ?? [];
                                // Lista filtrada según búsqueda y dropdown.
                                final usuariosFiltrados = _aplicarFiltros(
                                  usuarios,
                                );
                                // Texto que alterna entre total general o resultados filtrados.
                                final totalText =
                                    textoFiltro.isEmpty &&
                                        filtroSeleccionado == UserFilter.all
                                    ? '${l10n.totalUsers}: ${usuarios.length}'
                                    : '${l10n.usersFound} ${usuariosFiltrados.length}';

                                if (usuarios.isEmpty) {
                                  // No hay usuarios cargados en la base de datos.
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'No se encontraron usuarios',
                                      style: textTheme.bodyMedium,
                                    ),
                                  );
                                }

                                return Column(
                                  children: [
                                    // Cabecera con contador y botón de orden.
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            totalText,
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                          ),
                                        ),
                                        general_iconbutton(
                                          ordenSeleccionado == UserSort.none
                                              ? Icons.filter_list_off
                                              : Icons.filter_list,
                                          onPressed: () {
                                            // Modal inferior con tipos de orden.
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (context) => Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      l10n.sortType,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    general_listtile(
                                                      context: context,
                                                      icon:
                                                          Icons.filter_list_off,
                                                      texto: l10n.noSortedUsers,
                                                      onTap: () {
                                                        setState(() {
                                                          ordenSeleccionado =
                                                              UserSort.none;
                                                        });
                                                        general_snackbar(
                                                          context,
                                                          l10n.noSortedUsers,
                                                          2,
                                                        );
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                    general_listtile(
                                                      context: context,
                                                      icon: Icons.sort_by_alpha,
                                                      texto: l10n.sortNameZA,
                                                      onTap: () {
                                                        setState(() {
                                                          ordenSeleccionado =
                                                              UserSort.nameZA;
                                                        });
                                                        Navigator.pop(context);
                                                        general_snackbar(
                                                          context,
                                                          l10n.sortedZASnackbar,
                                                          2,
                                                        );
                                                      },
                                                    ),
                                                    general_listtile(
                                                      context: context,
                                                      icon: Icons.bar_chart,
                                                      texto: l10n
                                                          .sortDependencyHighLow,
                                                      onTap: () {
                                                        setState(() {
                                                          ordenSeleccionado =
                                                              UserSort
                                                                  .dependencyHighLow;
                                                        });
                                                        Navigator.pop(context);
                                                        general_snackbar(
                                                          context,
                                                          l10n.sortedDependencyLevelHighLow,
                                                          2,
                                                        );
                                                      },
                                                    ),
                                                    general_listtile(
                                                      context: context,
                                                      icon: Icons.bar_chart,
                                                      texto: l10n
                                                          .sortDependencyLowHigh,
                                                      onTap: () {
                                                        setState(() {
                                                          ordenSeleccionado =
                                                              UserSort
                                                                  .dependencyLowHigh;
                                                        });
                                                        Navigator.pop(context);
                                                        general_snackbar(
                                                          context,
                                                          l10n.sortedDependencyLevelLowHigh,
                                                          2,
                                                        );
                                                      },
                                                    ),
                                                    general_listtile(
                                                      context: context,
                                                      icon: Icons.check,
                                                      texto: l10n
                                                          .sortedStatusAccount,
                                                      onTap: () {
                                                        setState(() {
                                                          ordenSeleccionado =
                                                              UserSort
                                                                  .accountStatusOrder;
                                                        });
                                                        Navigator.pop(context);
                                                        general_snackbar(
                                                          context,
                                                          l10n.sortedStatusAccount,
                                                          2,
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    if (usuariosFiltrados.isEmpty)
                                      // Hay usuarios pero el filtro deja la lista vacía.
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          'No se encontraron usuarios',
                                          style: textTheme.bodyMedium,
                                        ),
                                      )
                                    else
                                      // Lista sin scroll propio (el padre ya scrollea).
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: usuariosFiltrados.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 8),
                                        itemBuilder: (context, index) {
                                          final usuario =
                                              usuariosFiltrados[index];
                                          // Tarjeta compacta con info básica.
                                          return ListTile(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            tileColor: Theme.of(
                                              context,
                                            ).cardColor,
                                            title: Text(
                                              '${usuario.nombre} ${usuario.apellidos}',
                                              style: textTheme.titleMedium,
                                            ),
                                            subtitle: Text(
                                              'Estado: ${usuario.estadoCuenta} · Dependencia: ${usuario.nivelDependencia}',
                                              style: textTheme.bodyMedium,
                                            ),
                                            trailing: const Icon(
                                              Icons.chevron_right,
                                            ),
                                            onTap: () {
                                              // TODO: navegar al detalle del usuario
                                            },
                                          );
                                        },
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // -------- BOTÓN FLOTANTE --------
          Positioned(
            right: 24,
            bottom: 32,
            child: SafeArea(
              child: general_floatingbutton(
                Icons.add,
                onPressed: () {
                  //TODO: IMPLEMENTAR AÑADIR USUARIO, se edita buscandolo
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
