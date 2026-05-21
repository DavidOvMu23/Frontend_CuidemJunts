import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';

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
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/trabajador_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';

// Pantalla principal que muestra la lista de grupos de teleoperadores.
// Permite buscar, filtrar, ordenar, ver el detalle, crear y editar grupos.
class GruposPage extends ConsumerStatefulWidget {
  // Si es true, se muestra incrustada dentro de otra pantalla (sin barra de navegación propia).
  final bool embedded;

  const GruposPage({
    super.key,
    this.embedded = false,
  });

  @override
  ConsumerState<GruposPage> createState() => _GruposPageState();
}

// Opciones para filtrar la lista de grupos por su estado.
enum GrupoFilter { all, active, inactive }

// Opciones para ordenar la lista de grupos.
enum GrupoSort { nameAZ, nameZA, mostTeleoperators, fewestTeleoperators }

// Estado y lógica interna de la página de grupos.
class _GruposPageState extends ConsumerState<GruposPage> {
  // Filtro actualmente seleccionado (por defecto todos).
  GrupoFilter filtroSeleccionado = GrupoFilter.all;

  // Orden actualmente seleccionado (por defecto A→Z por nombre).
  GrupoSort ordenSeleccionado = GrupoSort.nameAZ;

  // Texto que el usuario escribe en el buscador.
  String textoFiltro = '';

  // Controla si se está mostrando el formulario de creación.
  bool _esCreacion = false;

  // Grupo que se está editando. Si es null, no hay edición activa.
  Grupo? _grupoEnEdicion;

  // Fuerza al provider a refrescar inmediatamente (sin esperar al siguiente
  // tick del polling). Se llama después de crear, editar o eliminar un grupo.
  void _recargarGrupos() {
    ref.invalidate(gruposProvider);
  }

  // Filtra y ordena la lista de grupos según el texto buscado,
  // el filtro de estado y el orden elegido.
  List<Grupo> _aplicarFiltros(List<Grupo> grupos) {
    final query = textoFiltro.trim().toLowerCase();

    // Filtramos primero por texto y luego por estado activo/inactivo.
    final filtrados = grupos.where((grupo) {
      final nombre = grupo.nombre.toLowerCase();
      final descripcion = grupo.descripcion.toLowerCase();

      // El grupo coincide si el texto buscado aparece en el nombre o la descripción.
      final coincideTexto = query.isEmpty ||
          nombre.contains(query) ||
          descripcion.contains(query);

      // Filtramos por estado según la opción elegida en el desplegable.
      final coincideFiltro = switch (filtroSeleccionado) {
        GrupoFilter.all => true,
        GrupoFilter.active => grupo.activo,
        GrupoFilter.inactive => !grupo.activo,
      };

      return coincideTexto && coincideFiltro;
    }).toList();

    // Ordenamos la lista según la opción de ordenación elegida.
    filtrados.sort((a, b) {
      switch (ordenSeleccionado) {
        case GrupoSort.nameAZ:
          return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
        case GrupoSort.nameZA:
          return b.nombre.toLowerCase().compareTo(a.nombre.toLowerCase());
        // De más a menos teleoperadores.
        case GrupoSort.mostTeleoperators:
          return b.teleoperadoresCount.compareTo(a.teleoperadoresCount);
        // De menos a más teleoperadores.
        case GrupoSort.fewestTeleoperators:
          return a.teleoperadoresCount.compareTo(b.teleoperadoresCount);
      }
    });

    return filtrados;
  }

  // Muestra un panel deslizable desde abajo con las opciones de orden.
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
            // Opción: ordenar por nombre A→Z
            general_listtile(
              context: context,
              icon: Icons.sort_by_alpha,
              texto: l10n.sortNameAZ,
              onTap: () {
                setState(() => ordenSeleccionado = GrupoSort.nameAZ);
                Navigator.pop(ctx);
              },
            ),
            // Opción: ordenar por nombre Z→A
            general_listtile(
              context: context,
              icon: Icons.sort_by_alpha,
              texto: l10n.sortNameZA,
              onTap: () {
                setState(() => ordenSeleccionado = GrupoSort.nameZA);
                Navigator.pop(ctx);
              },
            ),
            // Opción: mostrar primero los grupos con más teleoperadores
            general_listtile(
              context: context,
              icon: Icons.arrow_downward,
              texto: l10n.sortMostTeleoperators,
              onTap: () {
                setState(() => ordenSeleccionado = GrupoSort.mostTeleoperators);
                Navigator.pop(ctx);
              },
            ),
            // Opción: mostrar primero los grupos con menos teleoperadores
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

  // Abre un cuadro de diálogo con todos los detalles del grupo seleccionado.
  // Desde ahí se puede editar (si es supervisor) o eliminar el grupo.
  void _showGrupoDetail(BuildContext context, Grupo grupo, bool isSupervisor) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) {
        final textTheme = Theme.of(ctx).textTheme;
        final colorScheme = Theme.of(ctx).colorScheme;
        // Detectamos si el tema es oscuro para usar los colores correctos.
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
                            style:
                                textTheme.bodyMedium?.copyWith(fontSize: 15)),
                      ],
                    ),
                  ),
                ],
              ),
            );

        // Color de fondo del estado: verde si activo, rojo si inactivo.
        final activoBg = grupo.activo
            ? (isDark ? AppPalette.successDark : AppPalette.successLight)
            : (isDark ? AppPalette.errorDark : AppPalette.errorLight);

        // Color del texto del estado según modo claro/oscuro.
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
              // El botón de editar solo aparece si el usuario es supervisor.
              if (isSupervisor)
                IconButton(
                  onPressed: () {
                    // Cerramos el diálogo y abrimos el formulario de edición.
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
                  // Descripción del grupo (solo si no está vacía).
                  if (grupo.descripcion.trim().isNotEmpty)
                    detailRow(Icons.description_outlined, l10n.description,
                        grupo.descripcion),
                  // Número de teleoperadores asignados al grupo.
                  detailRow(
                    Icons.support_agent_outlined,
                    l10n.telemarketers,
                    '${grupo.teleoperadoresCount}',
                  ),
                  const SizedBox(height: 4),
                  // Título de la sección de estado.
                  Text(l10n.groupStatus,
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  // Etiqueta de color que indica si el grupo está activo o inactivo.
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
                  const SizedBox(height: 12),
                  const Divider(),
                  Text(
                    l10n.groupMembers,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Consumer(
                    builder: (context, ref, _) {
                      final trabajadoresAsync =
                          ref.watch(trabajadoresProvider);
                      return trabajadoresAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, _) => Text('${l10n.error}: $e'),
                        data: (trabajadores) {
                          final miembros = trabajadores
                              .where((t) =>
                                  t.grupoId == grupo.id &&
                                  t.rol.toLowerCase() ==
                                      AppRoles.teleoperador)
                              .toList();
                          if (miembros.isEmpty) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                l10n.noGroupMembers,
                                style: textTheme.bodyMedium,
                              ),
                            );
                          }
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: miembros
                                .map((t) => ListTile(
                                      dense: true,
                                      leading: CircleAvatar(
                                        child: Text(
                                          '${t.nombre[0]}${t.apellidos[0]}',
                                        ),
                                      ),
                                      title: Text(
                                          '${t.nombre} ${t.apellidos}'),
                                      subtitle: Text(t.correo),
                                      trailing: !t.activo
                                          ? Text(
                                              l10n.inactive,
                                              style: TextStyle(
                                                color: colorScheme.error,
                                                fontSize: 12,
                                              ),
                                            )
                                          : null,
                                    ))
                                .toList(),
                          );
                        },
                      );
                    },
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
            // El botón de eliminar solo aparece si el usuario es supervisor.
            if (isSupervisor)
              general_deletebutton(
                ctx,
                l10n.delete,
                onPressed: () {
                  Navigator.pop(ctx);
                  // Mostramos un segundo diálogo de confirmación antes de borrar.
                  _confirmarEliminar(grupo);
                },
              ),
          ],
        );
      },
    );
  }

  // Muestra un diálogo de confirmación antes de eliminar un grupo.
  // Si el grupo tiene teleoperadores asignados, no se puede eliminar.
  Future<void> _confirmarEliminar(Grupo grupo) async {
    final l10n = AppLocalizations.of(context)!;

    // Si el grupo tiene teleoperadores, mostramos un aviso y no permitimos borrar.
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

    // Si no tiene teleoperadores, pedimos confirmación para proceder con el borrado.
    await showConfirmDialog(
      context,
      title: l10n.delete,
      content: '${l10n.deleteGroupContent}\n\n${grupo.nombre}',
      confirmText: l10n.accept,
      cancelText: l10n.cancel,
      onConfirm: () async {
        try {
          final grupoService = ref.read(grupoServiceProvider);
          // Enviamos la petición de borrado al servidor.
          await grupoService.delete(grupo.id);
          if (!mounted) return;
          // Actualizamos la lista para reflejar el borrado.
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

  // Construye toda la interfaz visual de la página de grupos.
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Leemos los datos del usuario que ha iniciado sesión.
    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
    final userRole = authState.rol;
    // Solo los supervisores pueden crear, editar y eliminar grupos.
    final isSupervisor = userRole?.toLowerCase() == AppRoles.supervisor;
    // Número de notificaciones sin leer para la barra superior.
    final notificacionesSinLeerAsync = ref.watch(notificacionesSinLeerProvider);
    // Lista de grupos en tiempo real (polling cada 10s vía gruposProvider).
    final gruposAsync = ref.watch(gruposProvider);

    // El botón flotante para crear grupos solo aparece si es supervisor.
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

    // Ajustamos el padding según el tamaño de pantalla.
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppBreakpoints.desktop;
    final horizontalPadding = isDesktop ? 20.0 : 12.0;

    // Contenido principal: buscador, filtro y lista de grupos.
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
                      // Fila superior con buscador de texto y desplegable de filtro.
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Campo de búsqueda por texto libre.
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
                          // Desplegable para filtrar grupos por estado.
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                // Icono que cambia según si hay un filtro activo.
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
                                    // Al cambiar el filtro, actualizamos la lista.
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
                      // Línea separadora decorativa.
                      Divider(
                        height: 8,
                        color: colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      // Área principal que muestra la lista o mensajes de estado.
                      Expanded(
                        child: gruposAsync.when(
                          loading: () => const AppSkeletonList(count: 4),
                          error: (_, __) => Center(
                            child: Text(
                              l10n.noGroupsFound,
                              style: textTheme.bodyMedium,
                            ),
                          ),
                          data: (grupos) {
                            // Aplicamos los filtros y el orden a los datos cargados.
                            final gruposFiltrados = _aplicarFiltros(grupos);

                            // Si no hay grupos tras filtrar, lo indicamos.
                            if (gruposFiltrados.isEmpty) {
                              return Center(
                                child: Text(
                                  l10n.noResultsFound,
                                  style: textTheme.bodyMedium,
                                ),
                              );
                            }

                            // Texto que muestra el total o la cantidad filtrada.
                            final totalText = textoFiltro.isEmpty &&
                                    filtroSeleccionado == GrupoFilter.all
                                ? '${l10n.totalGroups}: ${grupos.length}'
                                : '${l10n.groupsFound} ${gruposFiltrados.length}';

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    // Contador de grupos mostrados.
                                    Expanded(
                                      child: Text(
                                        totalText,
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    // Botón para abrir el panel de ordenación.
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
                                // Lista desplazable de tarjetas de grupos.
                                Expanded(
                                  child: ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    itemCount: gruposFiltrados.length,
                                    // Separador visual entre tarjetas.
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 8),
                                    // Cada elemento es una tarjeta de grupo.
                                    itemBuilder: (context, index) {
                                      final grupo = gruposFiltrados[index];
                                      return GrupoCard(
                                        grupo: grupo,
                                        // Al pulsar la tarjeta, abrimos el detalle.
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

    // Decidimos si mostrar el formulario (crear/editar) o la lista.
    final showForm = _esCreacion || _grupoEnEdicion != null;

    final pageBody = showForm
        ? GrupoCreateEditPage(
            grupo: _grupoEnEdicion,
            onCancel: () => setState(() {
              _esCreacion = false;
              _grupoEnEdicion = null;
            }),
            onSaved: () {
              // Al guardar, volvemos a la lista y forzamos refresco inmediato.
              setState(() {
                _esCreacion = false;
                _grupoEnEdicion = null;
              });
              ref.invalidate(gruposProvider);
            },
          )
        : bodyContent;

    // Si está incrustada, usamos un Stack para el botón flotante.
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
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const NotificationsPage()));
        },
        context: context,
      ),
      // Menú lateral con acceso a las demás secciones.
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
        // Ya estamos en grupos, solo cerramos el menú.
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
      // Ocultamos el botón flotante cuando hay un formulario abierto.
      floatingActionButton: showForm ? null : fab,
    );
  }
}
