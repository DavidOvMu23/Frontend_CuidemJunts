import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';

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

// Pantalla principal que muestra la lista de trabajadores (teleoperadores y supervisores).
// Permite buscar, filtrar, ordenar, ver el detalle, crear y editar trabajadores.
class WorkersPage extends ConsumerStatefulWidget {
  // Si es true, la página se muestra incrustada dentro de otra (sin barra de navegación propia).
  final bool embedded;

  const WorkersPage({
    super.key,
    this.embedded = false,
  });

  @override
  ConsumerState<WorkersPage> createState() => _WorkersPageState();
}

// Opciones disponibles para filtrar la lista de trabajadores por tipo o estado.
enum WorkerFilter { all, supervisors, teleoperators, active, inactive }

// Opciones disponibles para ordenar la lista de trabajadores.
enum WorkerSort { nameAZ, nameZA, roleAZ, groupAZ, groupZA }

// Estado y lógica interna de la página de trabajadores.
class _WorkersPageState extends ConsumerState<WorkersPage> {
  // Resultado de la petición al servidor con todos los trabajadores.
  late Future<List<Trabajador>> _trabajadoresFuture;

  // Filtro actualmente seleccionado (por defecto se muestran todos).
  WorkerFilter filtroSeleccionado = WorkerFilter.all;

  // Orden actualmente seleccionado (por defecto A→Z por nombre).
  WorkerSort ordenSeleccionado = WorkerSort.nameAZ;

  // Texto que el usuario escribe en la barra de búsqueda.
  String textoFiltro = '';

  // Controla si se está mostrando el formulario de creación en línea.
  bool _esCreacion = false;

  // Trabajador que se está editando. Si es null, no hay edición activa.
  Trabajador? _trabajadorEnEdicion;

  // Se ejecuta una sola vez al abrir la página para cargar los datos iniciales.
  @override
  void initState() {
    super.initState();
    // Solo cargamos trabajadores si el usuario es supervisor,
    // porque el backend devuelve error 403 si lo solicita otro rol.
    final authState = ref.read(authProvider);
    final isSupervisor = (authState.rol ?? '').toString().toLowerCase() == AppRoles.supervisor;
    if (isSupervisor) {
      _trabajadoresFuture = _cargarTrabajadoresConGrupo();
    } else {
      // Si no es supervisor, devolvemos una lista vacía sin llamar al servidor.
      _trabajadoresFuture = Future.value(<Trabajador>[]);
    }
  }

  // Obtiene todos los trabajadores del servidor y les añade el nombre del grupo
  // al que pertenecen (solo para los teleoperadores que tienen grupo asignado).
  Future<List<Trabajador>> _cargarTrabajadoresConGrupo() async {
    final trabajadorService = ref.read(trabajadorServiceProvider);
    final gruposService = ref.read(grupoServiceProvider);

    // Pedimos la lista completa de trabajadores al servidor.
    final trabajadores = await trabajadorService.getAll();

    // Mapa que guarda los nombres de grupos ya consultados para no repetir peticiones.
    final Map<int, String?> cache = {};

    // Para cada trabajador, buscamos el nombre de su grupo si es teleoperador.
    final enriched = await Future.wait(
      trabajadores.map((trabajador) async {
        final esTeleoperador = trabajador.rol.toLowerCase() == AppRoles.teleoperador;
        final grupoId = trabajador.grupoId;

        // Si no es teleoperador o no tiene grupo, lo devolvemos sin cambios.
        if (!esTeleoperador || grupoId == null) {
          return trabajador;
        }

        // Obtenemos el nombre del grupo usando el caché para evitar llamadas repetidas.
        final nombreGrupo = await _obtenerNombreGrupo(
          grupoId,
          cache,
          gruposService,
        );

        // Si no se encontró el grupo, devolvemos el trabajador sin nombre de grupo.
        if (nombreGrupo == null) {
          return trabajador;
        }

        // Devolvemos el trabajador con el nombre del grupo añadido.
        return trabajador.copyWith(grupoNombre: nombreGrupo);
      }),
    );

    return enriched;
  }

  // Obtiene el nombre de un grupo por su ID. Usa un caché para no repetir peticiones
  // al servidor cuando varios trabajadores pertenecen al mismo grupo.
  Future<String?> _obtenerNombreGrupo(
    int grupoId,
    Map<int, String?> cache,
    GrupoService gruposService,
  ) async {
    // Si ya lo consultamos antes, devolvemos el valor guardado.
    if (cache.containsKey(grupoId)) {
      return cache[grupoId];
    }

    try {
      final grupo = await gruposService.getById(grupoId);
      cache[grupoId] = grupo.nombre;
      return grupo.nombre;
    } catch (_) {
      // Si falla la consulta, guardamos null para no volver a intentarlo.
      cache[grupoId] = null;
      return null;
    }
  }

  // Filtra y ordena la lista de trabajadores según el texto buscado,
  // el filtro seleccionado y el orden elegido.
  List<Trabajador> _aplicarFiltros(List<Trabajador> trabajadores) {
    final query = textoFiltro.trim().toLowerCase();

    // Primero filtramos por texto y por tipo/estado.
    final filtrados = trabajadores.where((trabajador) {
      final nombreCompleto = '${trabajador.nombre} ${trabajador.apellidos}'
          .toLowerCase();
      final grupoNombre = (trabajador.grupoNombre ?? '').toLowerCase();
      final rol = trabajador.rol.toLowerCase();

      // El trabajador coincide con el texto si algún campo lo contiene.
      final coincideTexto =
          query.isEmpty ||
          nombreCompleto.contains(query) ||
          trabajador.correo.toLowerCase().contains(query) ||
          rol.contains(query) ||
          grupoNombre.contains(query);

      // El trabajador coincide con el filtro según el tipo seleccionado.
      final coincideFiltro = switch (filtroSeleccionado) {
        WorkerFilter.all => true,
        WorkerFilter.supervisors => rol == AppRoles.supervisor,
        WorkerFilter.teleoperators => rol == AppRoles.teleoperador,
        WorkerFilter.active => trabajador.activo,
        WorkerFilter.inactive => !trabajador.activo,
      };

      return coincideTexto && coincideFiltro;
    }).toList();

    // Luego ordenamos la lista según la opción elegida.
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

  // Actualiza el orden seleccionado y redibuja la pantalla.
  void _onSortChanged(WorkerSort sort) {
    setState(() {
      ordenSeleccionado = sort;
    });
  }

  // Muestra un panel deslizable desde abajo con las opciones de ordenación disponibles.
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
                _onSortChanged(WorkerSort.nameAZ);
                Navigator.pop(ctx);
              },
            ),
            // Opción: ordenar por nombre Z→A
            general_listtile(
              context: context,
              icon: Icons.sort_by_alpha,
              texto: l10n.sortNameZA,
              onTap: () {
                _onSortChanged(WorkerSort.nameZA);
                Navigator.pop(ctx);
              },
            ),
            // Opción: ordenar por rol (supervisores primero)
            general_listtile(
              context: context,
              icon: Icons.badge,
              texto: l10n.sortRoleSupervisorFirst,
              onTap: () {
                _onSortChanged(WorkerSort.roleAZ);
                Navigator.pop(ctx);
              },
            ),
            // Opción: ordenar por nombre de grupo A→Z
            general_listtile(
              context: context,
              icon: Icons.group_work,
              texto: l10n.sortGroupAZ,
              onTap: () {
                _onSortChanged(WorkerSort.groupAZ);
                Navigator.pop(ctx);
              },
            ),
            // Opción: ordenar por nombre de grupo Z→A
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

  // Abre un cuadro de diálogo con todos los datos del trabajador seleccionado.
  // Desde ahí se puede editar o eliminar el trabajador.
  void _showWorkerDetail(BuildContext context, Trabajador trabajador) {
    final l10n = AppLocalizations.of(context)!;
    final grupo = (trabajador.grupoNombre ?? '').trim();

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

        // Color de fondo del estado: verde si está activo, rojo si no.
        final activoBg = trabajador.activo
            ? (isDark ? AppPalette.successDark : AppPalette.successLight)
            : (isDark ? AppPalette.errorDark : AppPalette.errorLight);

        // Color del texto del estado: según modo claro/oscuro y si está activo.
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
              // Botón de editar: cierra este diálogo y abre el formulario de edición.
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
                  // Fila con el correo electrónico del trabajador.
                  detailRow(Icons.email_outlined, l10n.email_label, trabajador.correo),
                  // Fila con el rol (supervisor o teleoperador).
                  detailRow(Icons.badge_outlined, l10n.role_label, trabajador.rol),
                  // Si es teleoperador, mostramos su grupo y NIA.
                  if (trabajador.rol.toLowerCase() == AppRoles.teleoperador) ...[
                    detailRow(Icons.group_outlined, l10n.group_label,
                        grupo.isEmpty ? l10n.noGroupAssigned : grupo),
                    if (trabajador.nia != null && trabajador.nia!.isNotEmpty)
                      detailRow(Icons.numbers_outlined, 'NIA', trabajador.nia!),
                  ],
                  // Si es supervisor, mostramos su DNI.
                  if (trabajador.rol.toLowerCase() == AppRoles.supervisor &&
                      trabajador.dni != null && trabajador.dni!.isNotEmpty)
                    detailRow(Icons.credit_card_outlined, 'DNI', trabajador.dni!),
                  const SizedBox(height: 4),
                  // Título de la sección de estado de la cuenta.
                  Text(l10n.accountStatus,
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  // Etiqueta de color que indica si la cuenta está activa o inactiva.
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
            // Botón para cerrar el diálogo sin hacer nada.
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.close),
            ),
            // Botón de eliminar: primero pide confirmación y luego borra el trabajador.
            general_deletebutton(
              ctx,
              l10n.delete,
              onPressed: () {
                // Primer diálogo: confirmación antes de borrar.
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
                      // Segundo botón de confirmar: ejecuta el borrado real.
                      general_deletebutton(
                        confirmCtx,
                        l10n.delete,
                        onPressed: () async {
                          Navigator.pop(confirmCtx);
                          Navigator.pop(ctx);
                          try {
                            // Llamamos al servidor para eliminar el trabajador.
                            await ref.read(trabajadorServiceProvider).delete(trabajador.id);
                            if (!context.mounted) return;
                            general_snackbar(context, l10n.workerDeletedSuccessfully, 2);
                            // Recargamos la lista para reflejar el cambio.
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

  // Construye toda la interfaz visual de la página.
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Leemos los datos del usuario que ha iniciado sesión.
    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
    final userRole = authState.rol;

    // Número de notificaciones sin leer para mostrarlo en la barra superior.
    final notificacionesSinLeerAsync = ref.watch(notificacionesSinLeerProvider);

    // El botón flotante para crear trabajadores solo aparece si es supervisor.
    final fab = (userRole?.toLowerCase() == AppRoles.supervisor)
        ? general_floatingbutton(
            Icons.add,
            onPressed: () {
              // Al pulsar, activamos el modo creación y ocultamos el formulario de edición.
              setState(() {
                _esCreacion = true;
                _trabajadorEnEdicion = null;
              });
            },
          )
        : null;

    // Detectamos el ancho de la pantalla para ajustar el diseño en escritorio.
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppBreakpoints.desktop;
    final horizontalPadding = isDesktop ? 20.0 : 12.0;

    // Contenido principal: buscador, filtro y lista de trabajadores.
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
                              l10n.searchWorkers,
                              icono: Icons.search,
                              onChanged: (value) {
                                setState(() => textoFiltro = value);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Desplegable para filtrar por tipo/estado de trabajador.
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                // Icono que cambia según si hay un filtro activo.
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
                                    // Al cambiar la opción, actualizamos el filtro y la lista.
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
                      // Línea separadora decorativa.
                      Divider(
                        height: 8,
                        color: colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      // Área principal donde se muestra la lista o mensajes de estado.
                      Expanded(
                        child: FutureBuilder<List<Trabajador>>(
                          future: _trabajadoresFuture,
                          builder: (context, snapshot) {
                            // Mientras carga, mostramos una animación de esqueleto.
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const AppSkeletonList(count: 4);
                            }

                            // Si hay error, mostramos un mensaje.
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  l10n.errorLoadingWorkers,
                                  style: textTheme.bodyMedium,
                                ),
                              );
                            }

                            final trabajadores = snapshot.data ?? [];

                            // Aplicamos los filtros y el orden actual a la lista cargada.
                            final trabajadoresFiltrados = _aplicarFiltros(
                              trabajadores,
                            );

                            // Si no hay resultados tras filtrar, lo indicamos.
                            if (trabajadoresFiltrados.isEmpty) {
                              return Center(
                                child: Text(
                                  l10n.noResultsFound,
                                  style: textTheme.bodyMedium,
                                ),
                              );
                            }

                            // Texto que muestra el total o la cantidad filtrada.
                            final totalText = textoFiltro.isEmpty && filtroSeleccionado == WorkerFilter.all
                                ? '${l10n.totalWorkers}: ${trabajadores.length}'
                                : '${l10n.workersFound}: ${trabajadoresFiltrados.length}';

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    // Contador de trabajadores mostrados.
                                    Expanded(
                                      child: Text(
                                        totalText,
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    // Botón para abrir el panel de opciones de orden.
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
                                // Lista desplazable de tarjetas de trabajadores.
                                Expanded(
                                  child: ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    itemCount: trabajadoresFiltrados.length,
                                    // Separador visual entre tarjetas.
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 8),
                                    // Cada elemento de la lista es una tarjeta de trabajador.
                                    itemBuilder: (context, index) {
                                      final trabajador =
                                          trabajadoresFiltrados[index];
                                      return WorkerCard(
                                        trabajador: trabajador,
                                        // Al pulsar en la tarjeta, abrimos el detalle.
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

    // Determinamos si hay que mostrar un formulario (creación o edición) en lugar de la lista.
    final showForm = _esCreacion || _trabajadorEnEdicion != null;

    // Si hay formulario activo, mostramos el formulario; si no, la lista.
    final pageBody = showForm
        ? (_esCreacion
            ? CrearTrabajadorPage(
                // Al cancelar, volvemos a la lista sin guardar cambios.
                onCancel: () => setState(() {
                  _esCreacion = false;
                }),
                // Al guardar, volvemos a la lista y recargamos los datos.
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

    // Si la página está incrustada en otra, no usamos Scaffold propio.
    if (widget.embedded) {
      return Stack(
        children: [
          Positioned.fill(child: pageBody),
          // El botón flotante se posiciona en la esquina inferior derecha.
          if (!showForm && fab != null)
            Positioned(right: 18, bottom: 18, child: fab),
        ],
      );
    }

    // Versión de página completa con barra superior, menú lateral y botón flotante.
    return Scaffold(
      appBar: appMainAppBar(
        // Número de notificaciones sin leer que aparece en el icono de la campana.
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
      // Menú lateral con acceso a las demás secciones de la aplicación.
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
        // Ya estamos en la página de trabajadores, solo cerramos el menú.
        onTapTelemarketers: () {
          Navigator.pop(context);
        },
        onTapGroups: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GruposPage()),
          );
        },
        // Al cerrar sesión, limpiamos el estado y volvemos al login.
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
      // Ocultamos el botón flotante cuando hay un formulario abierto.
      floatingActionButton: showForm ? null : fab,
    );
  }
}
