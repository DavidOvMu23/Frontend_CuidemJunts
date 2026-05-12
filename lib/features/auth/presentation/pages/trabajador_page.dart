import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/core/widgets/loading_skeleton.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/grupo_service.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/trabajador.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/workers/widgets/worker_card.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/calls_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/emergency_contacts_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/grupos_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/notifications_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_create_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_edit_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/grupo_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/trabajador_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';

class WorkersPage extends ConsumerStatefulWidget {
  final bool embedded;

  const WorkersPage({
    super.key,
    this.embedded = false,
  });

  @override
  ConsumerState<WorkersPage> createState() => _WorkersPageState();
}

enum WorkerFilter { all, supervisors, teleoperators, active, inactive }

enum WorkerSort { nameAZ, nameZA, roleAZ, groupAZ, groupZA }

class _WorkersPageState extends ConsumerState<WorkersPage> {
  late Future<List<Trabajador>> _trabajadoresFuture;
  WorkerFilter filtroSeleccionado = WorkerFilter.all;
  WorkerSort ordenSeleccionado = WorkerSort.nameAZ;
  String textoFiltro = '';

  // Formulario inline
  bool _esCreacion = false;
  Trabajador? _trabajadorEnEdicion;

  @override
  void initState() {
    super.initState();
    // Only load workers if current user is supervisor to avoid 403 from backend
    final authState = ref.read(authProvider);
    final isSupervisor = (authState.rol ?? '').toString().toLowerCase() == 'supervisor';
    if (isSupervisor) {
      _trabajadoresFuture = _cargarTrabajadoresConGrupo();
    } else {
      _trabajadoresFuture = Future.value(<Trabajador>[]);
    }
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

      final coincideFiltro = switch (filtroSeleccionado) {
        WorkerFilter.all => true,
        WorkerFilter.supervisors => rol == 'supervisor',
        WorkerFilter.teleoperators => rol == 'teleoperador',
        WorkerFilter.active => trabajador.activo,
        WorkerFilter.inactive => !trabajador.activo,
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
              texto: l10n.sortRoleSupervisorFirst,
              onTap: () {
                _onSortChanged(WorkerSort.roleAZ);
                Navigator.pop(ctx);
              },
            ),
            general_listtile(
              context: context,
              icon: Icons.group_work,
              texto: l10n.sortGroupAZ,
              onTap: () {
                _onSortChanged(WorkerSort.groupAZ);
                Navigator.pop(ctx);
              },
            ),
            general_listtile(
              context: context,
              icon: Icons.group_work,
              texto: l10n.sortGroupZA,
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
      builder: (ctx) {
        final textTheme = Theme.of(ctx).textTheme;
        final colorScheme = Theme.of(ctx).colorScheme;
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

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
                            style:
                                textTheme.bodyMedium?.copyWith(fontSize: 15)),
                      ],
                    ),
                  ),
                ],
              ),
            );

        final activoBg = trabajador.activo
            ? (isDark ? AppPalette.successDark : AppPalette.successLight)
            : (isDark ? AppPalette.errorDark : AppPalette.errorLight);
        final activoFg = trabajador.activo
            ? (isDark ? AppPalette.successFontDark : AppPalette.successFontLight)
            : (isDark ? AppPalette.errorFontDark : AppPalette.errorFontLight);

        return AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  '${trabajador.nombre} ${trabajador.apellidos}',
                  style: textTheme.headlineLarge
                      ?.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
                  softWrap: true,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _trabajadorEnEdicion = trabajador;
                    _esCreacion = false;
                  });
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
                  detailRow(Icons.email_outlined, l10n.email_label, trabajador.correo),
                  detailRow(Icons.badge_outlined, l10n.role_label, trabajador.rol),
                  if (trabajador.rol.toLowerCase() == 'teleoperador') ...[
                    detailRow(Icons.group_outlined, l10n.group_label,
                        grupo.isEmpty ? l10n.noGroupAssigned : grupo),
                    if (trabajador.nia != null && trabajador.nia!.isNotEmpty)
                      detailRow(Icons.numbers_outlined, 'NIA', trabajador.nia!),
                  ],
                  if (trabajador.rol.toLowerCase() == 'supervisor' &&
                      trabajador.dni != null && trabajador.dni!.isNotEmpty)
                    detailRow(Icons.credit_card_outlined, 'DNI', trabajador.dni!),
                  const SizedBox(height: 4),
                  Text(l10n.accountStatus,
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: activoBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      trabajador.activo ? l10n.active : l10n.inactive,
                      style: textTheme.titleMedium?.copyWith(
                        color: activoFg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.close),
            ),
            general_deletebutton(
              ctx,
              l10n.delete,
              onPressed: () {
                showDialog(
                  context: ctx,
                  builder: (confirmCtx) => AlertDialog(
                    title: Text(l10n.deleteWorkerTitle),
                    content: Text(l10n.deleteWorkerContent),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(confirmCtx),
                        child: Text(l10n.cancel),
                      ),
                      general_deletebutton(
                        confirmCtx,
                        l10n.delete,
                        onPressed: () async {
                          Navigator.pop(confirmCtx);
                          Navigator.pop(ctx);
                          try {
                            await ref.read(trabajadorServiceProvider).delete(trabajador.id);
                            if (!context.mounted) return;
                            general_snackbar(context, l10n.workerDeletedSuccessfully, 2);
                            setState(() {
                              _trabajadoresFuture = _cargarTrabajadoresConGrupo();
                            });
                          } catch (e) {
                            if (!context.mounted) return;
                            general_snackbar_error(context, '${l10n.error}: ${e.toString()}', 5);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
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

    final fab = (userRole?.toLowerCase() == 'supervisor')
        ? general_floatingbutton(
            Icons.add,
            onPressed: () {
              setState(() {
                _esCreacion = true;
                _trabajadorEnEdicion = null;
              });
            },
          )
        : null;

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final horizontalPadding = isDesktop ? 20.0 : 12.0;

    final bodyContent = Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Material(
                color: colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 22 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: general_busqueda_textfield(
                              l10n.searchWorkers,
                              icono: Icons.search,
                              onChanged: (value) {
                                setState(() => textoFiltro = value);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Icon(
                                  filtroSeleccionado != WorkerFilter.all
                                      ? Icons.filter_alt
                                      : Icons.filter_alt_off,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
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
                                        value: WorkerFilter.active,
                                        child: Text(l10n.active),
                                      ),
                                      DropdownMenuItem(
                                        value: WorkerFilter.inactive,
                                        child: Text(l10n.inactive),
                                      ),
                                    ],
                                    onChanged: (newValue) {
                                      setState(() {
                                        filtroSeleccionado = newValue ?? WorkerFilter.all;
                                      });
                                    },
                                  ),
                                ),
                              ],
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
                              return const AppSkeletonList(count: 4);
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

                            final totalText = textoFiltro.isEmpty && filtroSeleccionado == WorkerFilter.all
                                ? '${l10n.totalWorkers}: ${trabajadores.length}'
                                : '${l10n.workersFound}: ${trabajadoresFiltrados.length}';

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        totalText,
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        ordenSeleccionado == WorkerSort.nameAZ
                                            ? Icons.filter_list_off
                                            : Icons.filter_list,
                                        color: colorScheme.primary,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => _showSortBottomSheet(context, l10n),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    itemCount: trabajadoresFiltrados.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final trabajador =
                                          trabajadoresFiltrados[index];
                                      return WorkerCard(
                                        trabajador: trabajador,
                                        onTap: () => _showWorkerDetail(context, trabajador),
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
    );

    final showForm = _esCreacion || _trabajadorEnEdicion != null;

    final pageBody = showForm
        ? (_esCreacion
            ? CrearTrabajadorPage(
                onCancel: () => setState(() {
                  _esCreacion = false;
                }),
                onSaved: () {
                  setState(() {
                    _esCreacion = false;
                    _trabajadoresFuture = _cargarTrabajadoresConGrupo();
                  });
                },
              )
            : EditarTrabajadorPage(
                trabajador: _trabajadorEnEdicion!,
                onCancel: () => setState(() {
                  _trabajadorEnEdicion = null;
                }),
                onSaved: () {
                  setState(() {
                    _trabajadorEnEdicion = null;
                    _trabajadoresFuture = _cargarTrabajadoresConGrupo();
                  });
                },
              ))
        : bodyContent;

    if (widget.embedded) {
      return Stack(
        children: [
          Positioned.fill(child: pageBody),
          if (!showForm && fab != null)
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsPage()),
          );
        },
        context: context,
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
        onTapGroups: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GruposPage()),
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
      body: pageBody,
      floatingActionButton: showForm ? null : fab,
    );
  }
}
