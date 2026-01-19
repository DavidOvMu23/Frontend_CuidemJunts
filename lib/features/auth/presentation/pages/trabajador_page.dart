import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/trabajador.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/grupo_service.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/calls_page.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/emergency_contacts_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_create_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/trabajador_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/grupo_provider.dart';

class WorkersPage extends ConsumerStatefulWidget {
  const WorkersPage({super.key});

  @override
  ConsumerState<WorkersPage> createState() => _WorkersPageState();
}

// Filtros disponibles de la busqueda de usuarios.
enum UserFilter { all, active, inactive, g1, g2, g3 }

// Modos de ordenación disponibles para la lista de usuarios.
enum UserSort {
  none,
  nameZA,
  dependencyHighLow,
  dependencyLowHigh,
  accountStatusOrder,
}

class _WorkersPageState extends ConsumerState<WorkersPage> {
  late Future<List<Trabajador>> _trabajadoresFuture;
  // Filtro de usuarios seleccionado actualmente.
  late UserFilter filtroSeleccionado;
  late String textoFiltro = '';

  /// Orden actualmente seleccionado para la lista.
  UserSort ordenSeleccionado = UserSort.none;

  @override
  void initState() {
    super.initState();
    filtroSeleccionado = UserFilter.all;
    _trabajadoresFuture = _cargarTrabajadoresConGrupo();
  }

  Future<List<Trabajador>> _cargarTrabajadoresConGrupo() async {
    final trabajadorService = ref.read(trabajadorServiceProvider);
    final gruposService = ref.read(grupoServiceProvider);

    final trabajadores = await trabajadorService.getAll();
    final Map<int, String?> cache = {};

    final enriched = await Future.wait(
      trabajadores.map((trabajador) async {
        final esTeleoperador = trabajador.rol.toLowerCase() == 'teleoperador';
        final grupoId = trabajador.grupoId;
        if (!esTeleoperador || grupoId == null) {
          return trabajador;
        }

        final nombreGrupo = await _obtenerNombreGrupo(
          grupoId,
          cache,
          gruposService,
        );
        if (nombreGrupo == null) {
          return trabajador;
        }
        return trabajador.copyWith(grupoNombre: nombreGrupo);
      }),
    );

    return enriched;
  }

  Future<String?> _obtenerNombreGrupo(
    int grupoId,
    Map<int, String?> cache,
    GrupoService gruposService,
  ) async {
    if (cache.containsKey(grupoId)) {
      return cache[grupoId];
    }

    try {
      final grupo = await gruposService.getById(grupoId);
      cache[grupoId] = grupo.nombre;
      return grupo.nombre;
    } catch (_) {
      cache[grupoId] = null;
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos tipografías y paleta del tema actual para mantener
    // estilos consistentes en toda la app.
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Textos traducidos (según el idioma seleccionado en la app).
    final l10n = AppLocalizations.of(context)!;

    // -------- OBTENER NOMBRE DEL USUARIO DESDE RIVERPOD --------
    // Obtenemos el estado de autenticación del provider
    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
    final userRole = authState.rol;

    return Scaffold(
      // -------- BARRA SUPERIOR --------
      // AppBar: barra superior con título centrado e iconos de acción a la derecha.
      appBar: appMainAppBar(
        onNotifications: () {
          // TODO: Acción al pulsar el icono de notificaciones.
        },
      ),

      // -------- MENÚ LATERAL (DRAWER) --------
      // Drawer: menú que se abre desde el lateral con opciones de navegación.
      drawer: appDrawer(
        userName: userName,
        userRole: userRole,
        context: context,
        selected: DrawerItem.telemarketers,
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
        onTapNotifications: () {},
        onTapPreferences: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PreferencesPage()),
          );
        },
        onTapUsers: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UsersPage()),
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

      // Usamos un Stack para poder colocar el botón flotante encima del contenido scrolleable.
      body: Stack(
        children: [
          //El posicined fill hace que el SingleChildScrollView ocupe todo el espacio disponible
          Positioned.fill(
            child: SingleChildScrollView(
              // SingleChildScrollView permite que toda la columna sea scrolleable
              padding: const EdgeInsets.symmetric(horizontal: 16.0),

              // ConstrainedBox sirve para que la columna ocupe todo el ancho disponible
              child: ConstrainedBox(
                // Hacemos que la columna ocupe todo el ancho disponible.

                // Esto es necesario para que los elementos dentro de la columna
                // (como las "tarjetas" de Material) ocupen todo el ancho posible.
                constraints: const BoxConstraints(minWidth: double.infinity),

                // Columna principal con todo el contenido de la página.
                child: Column(
                  // Alineamos todo a la izquierda.
                  crossAxisAlignment: CrossAxisAlignment.start,

                  // Elementos de la columna
                  children: [
                    // Título principal
                    Text(
                      l10n.telemarketers,
                      style: textTheme.titleMedium?.copyWith(fontSize: 27),
                    ),
                    // Subtítulo
                    Text(l10n.manageWorkers, style: textTheme.bodyMedium),
                    const SizedBox(height: 20),

                    // Tarjeta principal con filtros y lista de usuarios
                    Material(
                      borderRadius: BorderRadius.circular(30),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),

                        //Columna en la que van los filtros y la lista de usuarios
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título de la sección de búsqueda
                            Text(
                              l10n.searchWorkers,
                              textAlign: TextAlign.left,
                              style: textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // TextField de búsqueda
                            general_busqueda_textfield(
                              l10n.searchWorkers,
                              icono: Icons.search,
                              onChanged: (value) {
                                setState(() {
                                  textoFiltro = value;
                                });
                              },
                            ),
                            const SizedBox(height: 20),

                            //Row del filtro de búsqueda
                            Row(
                              children: [
                                // Ícono que indica si hay filtro activo o no
                                Icon(
                                  // Si el filtro seleccionado no es "Todos", mostramos el icono de filtro activo
                                  filtroSeleccionado != UserFilter.all
                                      ? Icons.filter_alt
                                      : Icons.filter_alt_off,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 16),

                                //Expanded para que el DropdownButtonFormField ocupe todo el espacio restante
                                Expanded(
                                  //Dropdown para seleccionar el filtro de búsqueda
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

                                    //Elementos del dropdown
                                    items: [
                                      DropdownMenuItem<UserFilter>(
                                        //seleccionamos el filtro "Todos"
                                        value: UserFilter.all,
                                        child: Text(l10n.searchAllWorkers),
                                      ),
                                    ],
                                    // Al cambiar el valor seleccionado, actualizamos el estado
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
                            FutureBuilder<List<Trabajador>>(
                              future: _trabajadoresFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 32),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                if (snapshot.hasError) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      l10n.errorLoadingWorkers,
                                      style: textTheme.bodyMedium,
                                    ),
                                  );
                                }

                                final trabajadores = snapshot.data ?? [];
                                final showingAll =
                                    textoFiltro.isEmpty &&
                                    filtroSeleccionado == UserFilter.all;
                                final totalText = showingAll
                                    ? '${l10n.totalWorkers}: ${trabajadores.length}'
                                    : '${l10n.workersFound}: ${trabajadores.length}';

                                if (trabajadores.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      l10n.noWorkersFound,
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
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: trabajadores.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 8),
                                      itemBuilder: (context, index) {
                                        final trabajador = trabajadores[index];
                                        final esTeleoperador =
                                            trabajador.rol.toLowerCase() ==
                                            'teleoperador';
                                        final grupoNombreLimpio =
                                            (trabajador.grupoNombre ?? '')
                                                .trim();
                                        final grupoTexto = esTeleoperador
                                            ? ' · ${l10n.group_label}: ${grupoNombreLimpio.isEmpty ? l10n.noGroupAssigned : grupoNombreLimpio}'
                                            : '';
                                        return ListTile(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          tileColor: Theme.of(
                                            context,
                                          ).cardColor,
                                          title: Text(
                                            '${trabajador.nombre} ${trabajador.apellidos}',
                                            style: textTheme.titleMedium,
                                          ),
                                          subtitle: Text(
                                            '${l10n.email_label}: ${trabajador.correo} · ${l10n.role_label}: ${trabajador.rol}$grupoTexto',
                                            style: textTheme.bodyMedium,
                                          ),
                                          trailing: const Icon(
                                            Icons.chevron_right,
                                          ),
                                          onTap: () {
                                            // TODO: navegar al detalle del trabajador
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

          // Botón flotante
          Positioned(
            right: 24,
            bottom: 32,
            child: SafeArea(
              child: general_floatingbutton(
                Icons.add,
                onPressed: () {
                  // Al pulsar el botón flotante abrimos la pantalla para crear
                  // un nuevo trabajador siguiendo el mismo patrón que para
                  // la creación de usuarios.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CrearTrabajadorPage(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
