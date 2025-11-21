import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/llamadas.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/llamadas_service.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/grupo_service.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';

class LlamadasPage extends ConsumerStatefulWidget {
  const LlamadasPage({super.key});

  @override
  ConsumerState<LlamadasPage> createState() => _LlamadasPageState();
}

// Filtros disponibles de la busqueda de usuarios.
enum CallFilter { all, complete, pending, incomplete, g1, g2, g3 }

// Modos de ordenación disponibles para la lista de usuarios.
enum CallSort {
  none,
  dateLatest,
  nameAZ,
  nameZA,
  callDurationShortLong,
  callDurationLongShort,
  dependencyHighLow,
  dependencyLowHigh,
}

class _LlamadasPageState extends ConsumerState<LlamadasPage> {
  late final LlamadasService _llamadasService;
  late Future<List<Llamadas>> _llamadasFuture;
  late final GrupoService _gruposService;
  // Filtro de usuarios seleccionado actualmente.
  late CallFilter filtroSeleccionado;
  late String textoFiltro = '';

  /// Orden actualmente seleccionado para la lista.
  CallSort ordenSeleccionado = CallSort.none;

  @override
  void initState() {
    super.initState();
    filtroSeleccionado = CallFilter.all;
    _llamadasService = LlamadasService(
      baseUrl: 'http://cuidemjunts.zapto.org:3000',
    );
    _gruposService = GrupoService(baseUrl: 'http://cuidemjunts.zapto.org:3000');
    _llamadasFuture = _cargarLlamadasConGrupo();
  }

  Future<List<Llamadas>> _cargarLlamadasConGrupo() async {
    final llamadas = await _llamadasService.getAll();
    final Map<int, String?> cache = {};

    final enriched = await Future.wait(
      llamadas.map((llamada) async {
        // Si el backend ya incluye el nombre del grupo en la comunicación,
        // no necesitamos hacer una petición adicional.
        if (llamada.grupoNombre != null && llamada.grupoNombre!.isNotEmpty) {
          return llamada;
        }

        final grupoId = llamada.grupoId;
        if (grupoId == 0) return llamada;

        final nombreGrupo = await _obtenerNombreGrupo(grupoId, cache);
        if (nombreGrupo == null) return llamada;
        return llamada.copyWith(grupoNombre: nombreGrupo);
      }),
    );

    return enriched;
  }

  Future<String?> _obtenerNombreGrupo(
    int grupoId,
    Map<int, String?> cache,
  ) async {
    if (cache.containsKey(grupoId)) {
      return cache[grupoId];
    }

    try {
      final grupo = await _gruposService.getById(grupoId);
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
        context: context,
        selected: DrawerItem.calls,
        onTapHome: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeSupervisorPage()),
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
                      l10n.calls,
                      style: textTheme.titleMedium?.copyWith(fontSize: 27),
                    ),
                    // Subtítulo
                    Text(l10n.superviseCalls, style: textTheme.bodyMedium),
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
                              l10n.allCalls,
                              textAlign: TextAlign.left,
                              style: textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // TextField de búsqueda
                            general_busqueda_textfield(
                              l10n.searchCalls,
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
                                  filtroSeleccionado != CallFilter.all
                                      ? Icons.filter_alt
                                      : Icons.filter_alt_off,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 16),

                                //Expanded para que el DropdownButtonFormField ocupe todo el espacio restante
                                Expanded(
                                  //Dropdown para seleccionar el filtro de búsqueda
                                  child: DropdownButtonFormField<CallFilter>(
                                    value: filtroSeleccionado,
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
                                      DropdownMenuItem<CallFilter>(
                                        //seleccionamos el filtro "Todos"
                                        value: CallFilter.all,
                                        child: Text(l10n.allCalls),
                                      ),
                                      DropdownMenuItem<CallFilter>(
                                        value: CallFilter.complete,
                                        child: Text(l10n.callCompleted),
                                      ),
                                      DropdownMenuItem<CallFilter>(
                                        value: CallFilter.pending,
                                        child: Text(l10n.callPending),
                                      ),
                                      DropdownMenuItem<CallFilter>(
                                        value: CallFilter.incomplete,
                                        child: Text(l10n.callNoAnswer),
                                      ),
                                      DropdownMenuItem<CallFilter>(
                                        value: CallFilter.g1,
                                        child: Text(
                                          l10n.searchModerateDependency,
                                        ),
                                      ),
                                      DropdownMenuItem<CallFilter>(
                                        value: CallFilter.g2,
                                        child: Text(l10n.searchHighDependency),
                                      ),
                                      DropdownMenuItem<CallFilter>(
                                        value: CallFilter.g3,
                                        child: Text(
                                          l10n.searchSevereDependency,
                                        ),
                                      ),
                                    ],
                                    // Al cambiar el valor seleccionado, actualizamos el estado
                                    onChanged: (CallFilter? newValue) {
                                      setState(() {
                                        filtroSeleccionado =
                                            newValue ?? CallFilter.all;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Divider(
                              color: colorScheme.primary.withOpacity(0.3),
                            ),

                            const SizedBox(height: 10),
                            FutureBuilder<List<Llamadas>>(
                              future: _llamadasFuture,
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
                                      'Error al cargar llamadas',
                                      style: textTheme.bodyMedium,
                                    ),
                                  );
                                }

                                final llamadas = snapshot.data ?? [];
                                final showingAll =
                                    textoFiltro.isEmpty &&
                                    filtroSeleccionado == CallFilter.all;
                                final totalText = showingAll
                                    ? '${l10n.totalCalls}: ${llamadas.length}'
                                    : '${l10n.callsFound}: ${llamadas.length}';

                                if (llamadas.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'No se encontraron llamadas',
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
                                          ordenSeleccionado == CallSort.none
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
                                                      texto: l10n.noSortedCalls,
                                                      onTap: () {
                                                        setState(() {
                                                          ordenSeleccionado =
                                                              CallSort.none;
                                                        });
                                                        general_snackbar(
                                                          context,
                                                          l10n.noSortedCalls,
                                                          2,
                                                        );
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                    general_listtile(
                                                      context: context,
                                                      icon: Icons.sort_by_alpha,
                                                      texto: l10n.sortNameAZ,
                                                      onTap: () {
                                                        setState(() {
                                                          ordenSeleccionado =
                                                              CallSort.nameAZ;
                                                        });
                                                        Navigator.pop(context);
                                                        general_snackbar(
                                                          context,
                                                          l10n.sortNameAZ,
                                                          2,
                                                        );
                                                      },
                                                    ),
                                                    general_listtile(
                                                      context: context,
                                                      icon: Icons.sort_by_alpha,
                                                      texto: l10n.sortNameZA,
                                                      onTap: () {
                                                        setState(() {
                                                          ordenSeleccionado =
                                                              CallSort.nameZA;
                                                        });
                                                        Navigator.pop(context);
                                                        general_snackbar(
                                                          context,
                                                          l10n.sortNameZA,
                                                          2,
                                                        );
                                                      },
                                                    ),
                                                    general_listtile(
                                                      context: context,
                                                      icon: Icons.timer,
                                                      texto: l10n
                                                          .sortCallDurationShortLong,
                                                      onTap: () {
                                                        setState(() {
                                                          ordenSeleccionado =
                                                              CallSort
                                                                  .callDurationShortLong;
                                                        });
                                                        Navigator.pop(context);
                                                        general_snackbar(
                                                          context,
                                                          l10n.sortCallDurationShortLong,
                                                          2,
                                                        );
                                                      },
                                                    ),
                                                    general_listtile(
                                                      context: context,
                                                      icon: Icons.timer,
                                                      texto: l10n
                                                          .sortCallDurationLongShort,
                                                      onTap: () {
                                                        setState(() {
                                                          ordenSeleccionado =
                                                              CallSort
                                                                  .callDurationLongShort;
                                                        });
                                                        Navigator.pop(context);
                                                        general_snackbar(
                                                          context,
                                                          l10n.sortCallDurationLongShort,
                                                          2,
                                                        );
                                                      },
                                                    ),
                                                    general_listtile(
                                                      context: context,
                                                      icon: Icons.filter_1,
                                                      texto: l10n
                                                          .sortDependencyHighLow,
                                                      onTap: () {
                                                        setState(() {
                                                          ordenSeleccionado =
                                                              CallSort
                                                                  .dependencyHighLow;
                                                        });
                                                        Navigator.pop(context);
                                                        general_snackbar(
                                                          context,
                                                          l10n.sortDependencyHighLow,
                                                          2,
                                                        );
                                                      },
                                                    ),
                                                    general_listtile(
                                                      context: context,
                                                      icon: Icons.filter_3,
                                                      texto: l10n
                                                          .sortDependencyLowHigh,
                                                      onTap: () {
                                                        setState(() {
                                                          ordenSeleccionado =
                                                              CallSort
                                                                  .dependencyLowHigh;
                                                        });
                                                        Navigator.pop(context);
                                                        general_snackbar(
                                                          context,
                                                          l10n.sortDependencyLowHigh,
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
                                      itemCount: llamadas.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 8),
                                      itemBuilder: (context, index) {
                                        final llamada = llamadas[index];
                                        final dateText = _formatDate(
                                          llamada.fecha,
                                        );
                                        final grupoTexto =
                                            ' · Grupo: ${llamada.grupoNombre?.isEmpty ?? true ? 'Sin grupo asignado' : llamada.grupoNombre}';
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
                                            '$dateText · ${llamada.hora}',
                                            style: textTheme.titleMedium,
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                llamada.resumen,
                                                style: textTheme.bodyMedium,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Duración: ${llamada.duracion} · Estado: ${llamada.estado} $grupoTexto',
                                                style: textTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                          isThreeLine: true,
                                          trailing: const Icon(
                                            Icons.chevron_right,
                                          ),
                                          onTap: () {
                                            // TODO: navegar al detalle de la llamada
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
                  //TODO: IMPLEMENTAR AÑADIR LLAMADA, se edita buscandola
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}
