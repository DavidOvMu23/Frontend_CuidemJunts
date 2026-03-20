import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/grupo_service.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/trabajador.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/calls_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/emergency_contacts_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/notifications_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_create_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/grupo_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/trabajador_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';

class WorkersPage extends ConsumerStatefulWidget {
  const WorkersPage({super.key});

  @override
  ConsumerState<WorkersPage> createState() => _WorkersPageState();
}

enum WorkerFilter { all, supervisors, teleoperators, withGroup, withoutGroup }

enum WorkerSort { nameAZ, nameZA, roleAZ, groupAZ, groupZA }

class _WorkersPageState extends ConsumerState<WorkersPage> {
  late Future<List<Trabajador>> _trabajadoresFuture;
  WorkerFilter filtroSeleccionado = WorkerFilter.all;
  WorkerSort ordenSeleccionado = WorkerSort.nameAZ;
  String textoFiltro = '';

  @override
  void initState() {
    super.initState();
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

  List<Trabajador> _aplicarFiltros(List<Trabajador> trabajadores) {
    final query = textoFiltro.trim().toLowerCase();

    final filtrados = trabajadores.where((trabajador) {
      final nombreCompleto = '${trabajador.nombre} ${trabajador.apellidos}'
          .toLowerCase();
      final grupoNombre = (trabajador.grupoNombre ?? '').toLowerCase();
      final rol = trabajador.rol.toLowerCase();

      final coincideTexto =
          query.isEmpty ||
          nombreCompleto.contains(query) ||
          trabajador.correo.toLowerCase().contains(query) ||
          rol.contains(query) ||
          grupoNombre.contains(query);

      final tieneGrupo = (trabajador.grupoNombre ?? '').trim().isNotEmpty;
      final coincideFiltro = switch (filtroSeleccionado) {
        WorkerFilter.all => true,
        WorkerFilter.supervisors => rol == 'supervisor',
        WorkerFilter.teleoperators => rol == 'teleoperador',
        WorkerFilter.withGroup => tieneGrupo,
        WorkerFilter.withoutGroup => !tieneGrupo,
      };

      return coincideTexto && coincideFiltro;
    }).toList();

    filtrados.sort((a, b) {
      final grupoA = (a.grupoNombre ?? '').toLowerCase();
      final grupoB = (b.grupoNombre ?? '').toLowerCase();
      switch (ordenSeleccionado) {
        case WorkerSort.nameAZ:
          return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
        case WorkerSort.nameZA:
          return b.nombre.toLowerCase().compareTo(a.nombre.toLowerCase());
        case WorkerSort.roleAZ:
          return a.rol.toLowerCase().compareTo(b.rol.toLowerCase());
        case WorkerSort.groupAZ:
          return grupoA.compareTo(grupoB);
        case WorkerSort.groupZA:
          return grupoB.compareTo(grupoA);
      }
    });

    return filtrados;
  }

  void _onSortChanged(WorkerSort sort) {
    setState(() {
      ordenSeleccionado = sort;
    });
  }

  void _showSortBottomSheet(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.sortType,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            general_listtile(
              context: context,
              icon: Icons.sort_by_alpha,
              texto: l10n.sortNameAZ,
              onTap: () {
                _onSortChanged(WorkerSort.nameAZ);
                Navigator.pop(ctx);
              },
            ),
            general_listtile(
              context: context,
              icon: Icons.sort_by_alpha,
              texto: l10n.sortNameZA,
              onTap: () {
                _onSortChanged(WorkerSort.nameZA);
                Navigator.pop(ctx);
              },
            ),
            general_listtile(
              context: context,
              icon: Icons.badge,
              texto: l10n.sortedStatusAccount,
              onTap: () {
                _onSortChanged(WorkerSort.roleAZ);
                Navigator.pop(ctx);
              },
            ),
            general_listtile(
              context: context,
              icon: Icons.group_work,
              texto: l10n.sortDependencyLowHigh,
              onTap: () {
                _onSortChanged(WorkerSort.groupAZ);
                Navigator.pop(ctx);
              },
            ),
            general_listtile(
              context: context,
              icon: Icons.group_work,
              texto: l10n.sortDependencyHighLow,
              onTap: () {
                _onSortChanged(WorkerSort.groupZA);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkerDetail(BuildContext context, Trabajador trabajador) {
    final l10n = AppLocalizations.of(context)!;
    final grupo = (trabajador.grupoNombre ?? '').trim();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${trabajador.nombre} ${trabajador.apellidos}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(l10n.email_label, trabajador.correo),
            _buildInfoRow(l10n.role_label, trabajador.rol),
            _buildInfoRow(
              l10n.group_label,
              grupo.isEmpty ? l10n.noGroupAssigned : grupo,
            ),
          ],
        ),
        actions: [
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
    final userRole = authState.rol;
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
        onTapNotifications: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsPage()),
          );
        },
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
        onTapTelemarketers: () {
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
              l10n.telemarketers,
              style: textTheme.titleMedium?.copyWith(fontSize: 27),
            ),
            Text(l10n.manageWorkers, style: textTheme.bodyMedium),
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
                          l10n.searchWorkers,
                          style: textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 5),
                        general_busqueda_textfield(
                          l10n.searchWorkers,
                          icono: Icons.search,
                          onChanged: (value) {
                            setState(() {
                              textoFiltro = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              filtroSeleccionado != WorkerFilter.all
                                  ? Icons.filter_alt
                                  : Icons.filter_alt_off,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<WorkerFilter>(
                                initialValue: filtroSeleccionado,
                                icon: const Icon(Icons.arrow_drop_down),
                                borderRadius: BorderRadius.circular(12),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: WorkerFilter.all,
                                    child: Text(l10n.searchAllWorkers),
                                  ),
                                  DropdownMenuItem(
                                    value: WorkerFilter.supervisors,
                                    child: Text(l10n.supervisor),
                                  ),
                                  DropdownMenuItem(
                                    value: WorkerFilter.teleoperators,
                                    child: Text(l10n.telemarketers),
                                  ),
                                  DropdownMenuItem(
                                    value: WorkerFilter.withGroup,
                                    child: Text(
                                      '${l10n.group_label}: ${l10n.active}',
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: WorkerFilter.withoutGroup,
                                    child: Text(l10n.noGroupAssigned),
                                  ),
                                ],
                                onChanged: (newValue) {
                                  setState(() {
                                    filtroSeleccionado =
                                        newValue ?? WorkerFilter.all;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Divider(
                          height: 8,
                          color: colorScheme.primary.withValues(alpha: 0.3),
                        ),
                        Expanded(
                          child: FutureBuilder<List<Trabajador>>(
                            future: _trabajadoresFuture,
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
                                    l10n.errorLoadingWorkers,
                                    style: textTheme.bodyMedium,
                                  ),
                                );
                              }

                              final trabajadores = snapshot.data ?? [];
                              final trabajadoresFiltrados = _aplicarFiltros(
                                trabajadores,
                              );

                              if (trabajadoresFiltrados.isEmpty) {
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
                                          '${l10n.workersFound}: ${trabajadoresFiltrados.length}',
                                          style: textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      general_iconbutton(
                                        Icons.filter_list,
                                        onPressed: () =>
                                            _showSortBottomSheet(context, l10n),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: ListView.separated(
                                      padding: EdgeInsets.zero,
                                      itemCount: trabajadoresFiltrados.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 8),
                                      itemBuilder: (context, index) {
                                        final trabajador =
                                            trabajadoresFiltrados[index];
                                        final grupo =
                                            (trabajador.grupoNombre ?? '')
                                                .trim();

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
                                            '${l10n.email_label}: ${trabajador.correo} · ${l10n.role_label}: ${trabajador.rol} · ${l10n.group_label}: ${grupo.isEmpty ? l10n.noGroupAssigned : grupo}',
                                            style: textTheme.bodyMedium,
                                          ),
                                          trailing: const Icon(
                                            Icons.chevron_right,
                                          ),
                                          onTap: () => _showWorkerDetail(
                                            context,
                                            trabajador,
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
      floatingActionButton: general_floatingbutton(
        Icons.add,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CrearTrabajadorPage(),
            ),
          );

          setState(() {
            _trabajadoresFuture = _cargarTrabajadoresConGrupo();
          });
        },
      ),
    );
  }
}
