import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/core/widgets/loading_skeleton.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/grupo.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/groups/widgets/grupo_card.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/calls_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/emergency_contacts_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/grupo_create_edit_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/notifications_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/grupo_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';

class GruposPage extends ConsumerStatefulWidget {
  final bool embedded;

  const GruposPage({
    super.key,
    this.embedded = false,
  });

  @override
  ConsumerState<GruposPage> createState() => _GruposPageState();
}

enum GrupoFilter { all, active, inactive }

enum GrupoSort { nameAZ, nameZA, mostTeleoperators, fewestTeleoperators }

class _GruposPageState extends ConsumerState<GruposPage> {
  late Future<List<Grupo>> _gruposFuture;
  GrupoFilter filtroSeleccionado = GrupoFilter.all;
  GrupoSort ordenSeleccionado = GrupoSort.nameAZ;
  String textoFiltro = '';

  bool _esCreacion = false;
  Grupo? _grupoEnEdicion;

  @override
  void initState() {
    super.initState();
    _gruposFuture = _cargarGrupos();
  }

  Future<List<Grupo>> _cargarGrupos() async {
    final grupoService = ref.read(grupoServiceProvider);
    return grupoService.findAll();
  }

  void _recargarGrupos() {
    setState(() {
      _gruposFuture = _cargarGrupos();
    });
  }

  List<Grupo> _aplicarFiltros(List<Grupo> grupos) {
    final query = textoFiltro.trim().toLowerCase();

    final filtrados = grupos.where((grupo) {
      final nombre = grupo.nombre.toLowerCase();
      final descripcion = grupo.descripcion.toLowerCase();

      final coincideTexto = query.isEmpty ||
          nombre.contains(query) ||
          descripcion.contains(query);

      final coincideFiltro = switch (filtroSeleccionado) {
        GrupoFilter.all => true,
        GrupoFilter.active => grupo.activo,
        GrupoFilter.inactive => !grupo.activo,
      };

      return coincideTexto && coincideFiltro;
    }).toList();

    filtrados.sort((a, b) {
      switch (ordenSeleccionado) {
        case GrupoSort.nameAZ:
          return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
        case GrupoSort.nameZA:
          return b.nombre.toLowerCase().compareTo(a.nombre.toLowerCase());
        case GrupoSort.mostTeleoperators:
          return b.teleoperadoresCount.compareTo(a.teleoperadoresCount);
        case GrupoSort.fewestTeleoperators:
          return a.teleoperadoresCount.compareTo(b.teleoperadoresCount);
      }
    });

    return filtrados;
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
                setState(() => ordenSeleccionado = GrupoSort.nameAZ);
                Navigator.pop(ctx);
              },
            ),
            general_listtile(
              context: context,
              icon: Icons.sort_by_alpha,
              texto: l10n.sortNameZA,
              onTap: () {
                setState(() => ordenSeleccionado = GrupoSort.nameZA);
                Navigator.pop(ctx);
              },
            ),
            general_listtile(
              context: context,
              icon: Icons.arrow_downward,
              texto: l10n.sortMostTeleoperators,
              onTap: () {
                setState(() => ordenSeleccionado = GrupoSort.mostTeleoperators);
                Navigator.pop(ctx);
              },
            ),
            general_listtile(
              context: context,
              icon: Icons.arrow_upward,
              texto: l10n.sortFewestTeleoperators,
              onTap: () {
                setState(
                    () => ordenSeleccionado = GrupoSort.fewestTeleoperators);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGrupoDetail(BuildContext context, Grupo grupo, bool isSupervisor) {
    final l10n = AppLocalizations.of(context)!;

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

        final activoBg = grupo.activo
            ? (isDark ? AppPalette.successDark : AppPalette.successLight)
            : (isDark ? AppPalette.errorDark : AppPalette.errorLight);
        final activoFg = grupo.activo
            ? (isDark
                ? AppPalette.successFontDark
                : AppPalette.successFontLight)
            : (isDark ? AppPalette.errorFontDark : AppPalette.errorFontLight);

        return AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  grupo.nombre,
                  style: textTheme.headlineLarge
                      ?.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
                  softWrap: true,
                ),
              ),
              if (isSupervisor)
                IconButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _grupoEnEdicion = grupo;
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
                  if (grupo.descripcion.trim().isNotEmpty)
                    detailRow(Icons.description_outlined, l10n.description,
                        grupo.descripcion),
                  detailRow(
                    Icons.support_agent_outlined,
                    l10n.telemarketers,
                    '${grupo.teleoperadoresCount}',
                  ),
                  const SizedBox(height: 4),
                  Text(l10n.groupStatus,
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
                      grupo.activo ? l10n.active : l10n.inactive,
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
            if (isSupervisor)
              general_deletebutton(
                ctx,
                l10n.delete,
                onPressed: () {
                  Navigator.pop(ctx);
                  _confirmarEliminar(grupo);
                },
              ),
          ],
        );
      },
    );
  }

  Future<void> _confirmarEliminar(Grupo grupo) async {
    final l10n = AppLocalizations.of(context)!;
    if (grupo.teleoperadoresCount > 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.cannotDeleteGroup),
          content: Text(
            '${l10n.cannotDeleteGroupContent} ${grupo.teleoperadoresCount} teleoperador(es).',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.accept),
            ),
          ],
        ),
      );
      return;
    }

    await showConfirmDialog(
      context,
      title: l10n.delete,
      content: '${l10n.deleteGroupContent}\n\n${grupo.nombre}',
      confirmText: l10n.accept,
      cancelText: l10n.cancel,
      onConfirm: () async {
        try {
          final grupoService = ref.read(grupoServiceProvider);
          await grupoService.delete(grupo.id);
          if (!mounted) return;
          _recargarGrupos();
          general_snackbar(context, l10n.groupDeletedSuccessfully, 2);
        } catch (e) {
          if (!mounted) return;
          general_snackbar_error(
              context, '${l10n.error}: ${extractErrorMessage(e)}', 4);
        }
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
    final isSupervisor = userRole?.toLowerCase() == 'supervisor';
    final notificacionesSinLeerAsync = ref.watch(notificacionesSinLeerProvider);

    final fab = isSupervisor
        ? general_floatingbutton(
            Icons.add,
            onPressed: () {
              setState(() {
                _esCreacion = true;
                _grupoEnEdicion = null;
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
                              l10n.searchGroups,
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
                                  filtroSeleccionado != GrupoFilter.all
                                      ? Icons.filter_alt
                                      : Icons.filter_alt_off,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonFormField<GrupoFilter>(
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
                                        value: GrupoFilter.all,
                                        child: Text(l10n.allGroups),
                                      ),
                                      DropdownMenuItem(
                                        value: GrupoFilter.active,
                                        child: Text(l10n.activeGroups),
                                      ),
                                      DropdownMenuItem(
                                        value: GrupoFilter.inactive,
                                        child: Text(l10n.inactiveGroups),
                                      ),
                                    ],
                                    onChanged: (newValue) {
                                      setState(() {
                                        filtroSeleccionado =
                                            newValue ?? GrupoFilter.all;
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
                        child: FutureBuilder<List<Grupo>>(
                          future: _gruposFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const AppSkeletonList(count: 4);
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  l10n.noGroupsFound,
                                  style: textTheme.bodyMedium,
                                ),
                              );
                            }

                            final grupos = snapshot.data ?? [];
                            final gruposFiltrados = _aplicarFiltros(grupos);

                            if (gruposFiltrados.isEmpty) {
                              return Center(
                                child: Text(
                                  l10n.noResultsFound,
                                  style: textTheme.bodyMedium,
                                ),
                              );
                            }

                            final totalText = textoFiltro.isEmpty &&
                                    filtroSeleccionado == GrupoFilter.all
                                ? '${l10n.totalGroups}: ${grupos.length}'
                                : '${l10n.groupsFound} ${gruposFiltrados.length}';

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
                                        ordenSeleccionado == GrupoSort.nameAZ
                                            ? Icons.filter_list_off
                                            : Icons.filter_list,
                                        color: colorScheme.primary,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () =>
                                          _showSortBottomSheet(context, l10n),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    itemCount: gruposFiltrados.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final grupo = gruposFiltrados[index];
                                      return GrupoCard(
                                        grupo: grupo,
                                        onTap: () => _showGrupoDetail(
                                            context, grupo, isSupervisor),
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

    final showForm = _esCreacion || _grupoEnEdicion != null;

    final pageBody = showForm
        ? GrupoCreateEditPage(
            grupo: _grupoEnEdicion,
            onCancel: () => setState(() {
              _esCreacion = false;
              _grupoEnEdicion = null;
            }),
            onSaved: () {
              setState(() {
                _esCreacion = false;
                _grupoEnEdicion = null;
                _gruposFuture = _cargarGrupos();
              });
            },
          )
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
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const NotificationsPage()));
        },
        context: context,
      ),
      drawer: appDrawer(
        userName: userName,
        userRole: userRole,
        context: context,
        selected: DrawerItem.groups,
        onTapHome: () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomeSupervisorPage()));
        },
        onTapCalls: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LlamadasPage()));
        },
        onTapUsers: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const UsersPage()));
        },
        onTapEmergencyContacts: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const EmergencyContactsPage()));
        },
        onTapTelemarketers: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const WorkersPage()));
        },
        onTapGroups: () {
          Navigator.pop(context);
        },
        onTapNotifications: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const NotificationsPage()));
        },
        onTapPreferences: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const PreferencesPage()));
        },
        onLogoutConfirmed: () async {
          await ref.read(authProvider.notifier).logout();
          if (!context.mounted) return;
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LoginPage()));
        },
      ),
      body: pageBody,
      floatingActionButton: showForm ? null : fab,
    );
  }
}
