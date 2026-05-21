// Librería principal de Flutter para construir la interfaz visual.
import 'package:flutter/material.dart';
// Constantes globales (puntos de ruptura de pantalla).
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';

// Riverpod: permite leer y escribir datos del estado global.
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Sistema de traducciones de la app.
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
// Widgets reutilizables: appbar, drawer, snackbar…
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
// Widget de esqueleto de carga (muestra barras grises mientras cargan los datos).
import 'package:frontend_cuidemjunts/core/widgets/loading_skeleton.dart';
// Modelo de datos de una notificación.
import 'package:frontend_cuidemjunts/features/auth/data/models/notificacion.dart';
// Pantallas a las que se puede navegar desde el menú lateral.
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/calls_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/emergency_contacts_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/grupos_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
// Provider con el estado del usuario autenticado.
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
// Providers con los datos de notificaciones y el servicio para gestionarlas.
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';
// Enum DrawerItem: identifica cada sección del menú lateral.
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';

// -------- PANTALLA DE NOTIFICACIONES --------
// Muestra la lista de notificaciones del usuario.
// Permite filtrarlas por estado (todas, sin leer, leídas, archivadas)
// y por tipo (llamada, sistema, supervisión).
// Desde cada notificación se puede marcarla como leída, archivarla o borrarla.
class NotificationsPage extends ConsumerStatefulWidget {
  // Si embedded es true, esta pantalla se muestra dentro del shell (sin su propio AppBar).
  final bool embedded;

  const NotificationsPage({super.key, this.embedded = false});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  // -------- FILTROS ACTIVOS --------
  // _selectedEstado: qué estado de notificación estamos viendo.
  // Valores posibles: 'todos', 'sin_leer', 'leida', 'archivada'.
  String _selectedEstado = 'todos';
  // _selectedTipo: qué tipo de notificación estamos viendo.
  // Valores posibles: 'todos', 'call', 'system', 'supervision'.
  String _selectedTipo = 'todos';

  // -------- COLORES POR TIPO DE NOTIFICACIÓN --------
  // Cada tipo tiene un color asociado para la franja izquierda y el badge de categoría.
  // static const significa que es compartido por toda la clase (no depende de instancias).
  static const _tipoColors = {
    'call':        Color(0xFF2196F3), // Azul: notificaciones de llamadas.
    'system':      Color(0xFFFF9800), // Naranja: notificaciones del sistema.
    'supervision': Color(0xFF4CAF50), // Verde: notificaciones de supervisión.
  };

  // -------- CONSTRUCCIÓN DE LA PANTALLA --------
  @override
  Widget build(BuildContext context) {
    // Textos en el idioma activo.
    final l10n = AppLocalizations.of(context)!;
    // Colores y estilos del tema activo.
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // -------- DATOS DEL USUARIO Y NOTIFICACIONES --------
    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
    final userRole = authState.rol;
    final isSupervisor = userRole?.toLowerCase() == AppRoles.supervisor;
    // Lista completa de notificaciones del usuario.
    final notificacionesAsync = ref.watch(notificacionesProvider);
    // Número de notificaciones sin leer (para el badge de la campana).
    final notificacionesSinLeerAsync = ref.watch(notificacionesSinLeerProvider);
    final unreadCount = notificacionesSinLeerAsync.when(
      data: (count) => count,
      loading: () => 0,
      error: (_, __) => 0,
    );

    // -------- DETECCIÓN DE TAMAÑO DE PANTALLA --------
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppBreakpoints.desktop;
    final horizontalPadding = isDesktop ? 20.0 : 12.0;

    // -------- CONTENIDO PRINCIPAL --------
    // Esta variable guarda el cuerpo de la pantalla (los filtros + la lista).
    // Si embedded es true, lo devolvemos directamente.
    // Si es false, lo envolvemos en un Scaffold con AppBar y Drawer.
    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Material(
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 22 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // -------- BARRA DE FILTROS --------
                      // Izquierda: filtros de estado (Todos, Sin leer, Leídas, Archivadas).
                      // Derecha: filtros de tipo (Todos, Llamada, Sistema, Supervisión).
                      Row(
                        children: [
                          // Filtros de estado: chips a la izquierda.
                          Wrap(
                            spacing: 8,
                            children: [
                              // Chip "Todos": muestra todas las notificaciones sin filtrar.
                              _TipoChip(
                                label: l10n.all,
                                selected: _selectedEstado == 'todos',
                                color: colorScheme.primary,
                                onTap: () => setState(() => _selectedEstado = 'todos'),
                              ),
                              // Chip "Sin leer": solo muestra las no leídas.
                              _TipoChip(
                                label: l10n.unread,
                                selected: _selectedEstado == 'sin_leer',
                                color: colorScheme.primary,
                                onTap: () => setState(() => _selectedEstado = 'sin_leer'),
                              ),
                              // Chip "Leídas": solo muestra las ya leídas.
                              _TipoChip(
                                label: l10n.read,
                                selected: _selectedEstado == 'leida',
                                color: colorScheme.primary,
                                onTap: () => setState(() => _selectedEstado = 'leida'),
                              ),
                              // Chip "Archivadas": solo muestra las archivadas.
                              _TipoChip(
                                label: l10n.archived,
                                selected: _selectedEstado == 'archivada',
                                color: colorScheme.primary,
                                onTap: () => setState(() => _selectedEstado = 'archivada'),
                              ),
                            ],
                          ),
                          // Spacer empuja los filtros de tipo hacia la derecha.
                          const Spacer(),
                          // Filtros de tipo: chips a la derecha.
                          Wrap(
                            spacing: 8,
                            children: [
                              _TipoChip(
                                label: l10n.all,
                                selected: _selectedTipo == 'todos',
                                color: colorScheme.primary,
                                onTap: () => setState(() => _selectedTipo = 'todos'),
                              ),
                              _TipoChip(
                                label: 'Llamada',
                                selected: _selectedTipo == 'call',
                                color: _tipoColors['call']!,
                                icon: Icons.call_outlined,
                                onTap: () => setState(() => _selectedTipo = 'call'),
                              ),
                              _TipoChip(
                                label: 'Sistema',
                                selected: _selectedTipo == 'system',
                                color: _tipoColors['system']!,
                                icon: Icons.settings_outlined,
                                onTap: () => setState(() => _selectedTipo = 'system'),
                              ),
                              // Chip "Supervisión": solo visible para supervisores.
                              if (isSupervisor)
                                _TipoChip(
                                  label: 'Supervisión',
                                  selected: _selectedTipo == 'supervision',
                                  color: _tipoColors['supervision']!,
                                  icon: Icons.supervisor_account_outlined,
                                  onTap: () => setState(() => _selectedTipo = 'supervision'),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Línea separadora entre los filtros y la lista.
                      Divider(
                        height: 8,
                        color: colorScheme.primary.withValues(alpha: 0.3),
                      ),

                      // -------- LISTA DE NOTIFICACIONES --------
                      // Ocupa todo el espacio restante de la tarjeta.
                      Expanded(
                        child: notificacionesAsync.when(
                          // -------- CUANDO LOS DATOS ESTÁN LISTOS --------
                          data: (notificaciones) {
                            // Aplicamos los dos filtros activos (estado Y tipo).
                            final filtered = notificaciones.where((n) {
                              final estadoOk = _selectedEstado == 'todos' || n.estado == _selectedEstado;
                              final tipoOk = _selectedTipo == 'todos' || n.tipo == _selectedTipo;
                              return estadoOk && tipoOk;
                            }).toList();

                            // Si no hay notificaciones que coincidan con los filtros,
                            // mostramos un mensaje vacío centrado.
                            if (filtered.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      // Si no hay notificaciones en total: icono de campana apagada.
                                      // Si las hay pero el filtro no devuelve nada: icono de búsqueda vacía.
                                      notificaciones.isEmpty
                                          ? Icons.notifications_off_outlined
                                          : Icons.search_off_outlined,
                                      size: 48,
                                      color: colorScheme.onSurface.withValues(alpha: 0.25),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      notificaciones.isEmpty
                                          ? l10n.noNotifications
                                          : l10n.noResultsFound,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurface.withValues(alpha: 0.45),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Lista desplazable con las notificaciones filtradas.
                            // RefreshIndicator permite recargar tirando hacia abajo.
                            return RefreshIndicator(
                              onRefresh: () async {
                                // Invalidamos el provider para que vuelva a pedir datos al servidor.
                                ref.invalidate(notificacionesProvider);
                                await ref.read(notificacionesProvider.future);
                              },
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                itemCount: filtered.length,
                                // Espaciado entre cada tarjeta de notificación.
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (ctx, i) {
                                  final notif = filtered[i];
                                  // Cada notificación es una tarjeta con acciones.
                                  return _NotificationCard(
                                    notif: notif,
                                    l10n: l10n,
                                    // Al marcar como leída: llamamos al servicio y recargamos la lista.
                                    onMarkAsRead: () async {
                                      await ref.read(notificacionServiceProvider).markAsRead(notif.id);
                                      ref.invalidate(notificacionesProvider);
                                      if (context.mounted) general_snackbar(context, l10n.read, 1);
                                    },
                                    // Al archivar: llamamos al servicio y recargamos la lista.
                                    onArchive: () async {
                                      await ref.read(notificacionServiceProvider).archive(notif.id);
                                      ref.invalidate(notificacionesProvider);
                                      if (context.mounted) general_snackbar(context, l10n.archived, 1);
                                    },
                                    // Al borrar: llamamos al servicio y recargamos la lista.
                                    onDelete: () async {
                                      await ref.read(notificacionServiceProvider).delete(notif.id);
                                      ref.invalidate(notificacionesProvider);
                                      if (context.mounted) general_snackbar(context, l10n.delete, 1);
                                    },
                                  );
                                },
                              ),
                            );
                          },
                          // -------- MIENTRAS CARGA: BARRAS DE ESQUELETO --------
                          // AppSkeletonList muestra 5 barras grises animadas para
                          // indicar que los datos están cargando.
                          loading: () => const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: AppSkeletonList(count: 5),
                          ),
                          // -------- SI HAY UN ERROR --------
                          error: (err, st) => Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                                const SizedBox(height: 14),
                                Text(
                                  l10n.errorNotificationsLoading,
                                  style: textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
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

    // -------- MODO EMBEBIDO: solo el contenido, sin AppBar ni Drawer --------
    if (widget.embedded) return content;

    // -------- MODO INDEPENDIENTE: con su propio AppBar y Drawer --------
    return Scaffold(
      appBar: appMainAppBar(
        numeroNotificaciones: unreadCount,
        // Al pulsar la campana en el AppBar, mostramos un mensaje
        // (ya estamos en notificaciones, así que no navegamos a otra pantalla).
        onNotifications: () {
          general_snackbar(context, l10n.notificationsPressed, 1);
        },
        context: context,
      ),
      drawer: appDrawer(
        userName: userName,
        userRole: userRole,
        context: context,
        // Marcamos "Notificaciones" como sección activa en el drawer.
        selected: DrawerItem.notifications,
        // Navegación desde el menú lateral a otras secciones.
        onTapHome: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeSupervisorPage()),
          );
        },
        onTapCalls: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LlamadasPage()));
        },
        onTapUsers: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const UsersPage()));
        },
        onTapEmergencyContacts: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyContactsPage()));
        },
        onTapTelemarketers: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkersPage()));
        },
        onTapGroups: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const GruposPage()));
        },
        onTapPreferences: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PreferencesPage()));
        },
        // Cerrar sesión: limpia el estado global y navega al login.
        onLogoutConfirmed: () async {
          await ref.read(authProvider.notifier).logout();
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false, // Elimina todas las rutas anteriores.
          );
        },
      ),
      body: content,
    );
  }
}

// -------- TARJETA DE NOTIFICACIÓN --------
// Representa visualmente una notificación individual en la lista.
// Muestra: icono de tipo, título, etiqueta de tipo, contenido, fecha y menú de acciones.
// Al pasar el ratón por encima se eleva ligeramente (efecto hover).
class _NotificationCard extends StatefulWidget {
  // Datos de la notificación a mostrar.
  final Notificacion notif;
  // Textos traducidos para los botones del menú de acciones.
  final AppLocalizations l10n;
  // Acción al marcar como leída.
  final VoidCallback onMarkAsRead;
  // Acción al archivar la notificación.
  final VoidCallback onArchive;
  // Acción al eliminar la notificación.
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notif,
    required this.l10n,
    required this.onMarkAsRead,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  // Registramos si el ratón está encima de la tarjeta para el efecto hover.
  bool _hovered = false;

  // -------- FORMATEO DE FECHA --------
  // Convierte un DateTime en "DD/MM/AAAA · HH:MM" para mostrarlo al usuario.
  // padLeft(2, '0') asegura que los números de un dígito lleven un cero delante (ej: "04").
  String _formatDate(DateTime date) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} · ${two(date.hour)}:${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final notif = widget.notif;

    // Obtenemos el mapa de colores definido en la pantalla padre.
    const tipoColors = _NotificationsPageState._tipoColors;
    // Color del tipo de esta notificación (o el color primario si no está en el mapa).
    final tipoColor = tipoColors[notif.tipo] ?? colorScheme.primary;
    // Si la notificación está archivada, usamos un color neutro (outline) en vez del de tipo.
    final accentColor = notif.esArchivada ? colorScheme.outline : tipoColor;

    // AnimatedContainer anima el desplazamiento vertical al hacer hover.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 170),
      curve: Curves.easeOutCubic,
      // Cuando el ratón está encima, la tarjeta sube 2 píxeles.
      transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
      child: Material(
        color: Theme.of(context).cardColor,
        // Solo las esquinas derechas son redondeadas para que la franja izquierda
        // de color quede limpia (sin bordes redondeados).
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        // Elevación (sombra) solo cuando el ratón está encima.
        elevation: _hovered ? 2 : 0,
        shadowColor: tipoColor.withValues(alpha: 0.25),
        child: InkWell(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          // Detectamos el hover para actualizar el estado de la tarjeta.
          onHover: (v) { if (_hovered != v) setState(() => _hovered = v); },
          // Al pulsar una notificación sin leer, la marcamos como leída.
          onTap: notif.esSinLeer ? widget.onMarkAsRead : null,
          child: Stack(
            children: [
              // -------- CONTENIDO PRINCIPAL DE LA TARJETA --------
              // El padding derecho (48) deja espacio al menú de 3 puntos.
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 48, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -------- ICONO DE TIPO --------
                    // Cuadrado redondeado con el icono del tipo de notificación.
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(notif.tipoIcono, size: 21, color: accentColor),
                    ),
                    const SizedBox(width: 12),
                    // -------- COLUMNA CON TÍTULO, TIPO, CONTENIDO Y FECHA --------
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Fila con el punto de "no leído" (si aplica) y el título.
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Punto azul que indica que la notificación no ha sido leída.
                              if (notif.esSinLeer)
                                Container(
                                  width: 9,
                                  height: 9,
                                  margin: const EdgeInsets.only(right: 8, top: 4),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                    // Brillo difuso para que destaque más.
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorScheme.primary.withValues(alpha: 0.85),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Título de la notificación (más negrita si no leída).
                                    Text(
                                      notif.titulo ?? notif.tipoLegible,
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontWeight: notif.esSinLeer ? FontWeight.w700 : FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    // Badge de categoría con el tipo legible (ej: "Llamada").
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: accentColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        notif.tipoLegible,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: accentColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Contenido/descripción de la notificación (máximo 2 líneas).
                          Text(
                            notif.contenido,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              // Las notificaciones no leídas tienen texto más visible.
                              color: colorScheme.onSurface.withValues(
                                alpha: notif.esSinLeer ? 0.9 : 0.65,
                              ),
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Fecha y hora de creación de la notificación.
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 13, color: colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(notif.createdAt),
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // -------- FRANJA IZQUIERDA DE COLOR --------
              // Barra vertical de 4px en el lado izquierdo de la tarjeta.
              // Su color indica el tipo de notificación de un vistazo.
              Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
              ),

              // -------- MENÚ DE ACCIONES (3 PUNTOS) --------
              // Aparece en la esquina derecha. Al pulsarlo, se abre un menú
              // con las opciones: marcar como leída, archivar y eliminar.
              Positioned(
                right: 4,
                top: 0,
                bottom: 0,
                child: Center(
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 18,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    // Según la opción elegida, llamamos a la acción correspondiente.
                    onSelected: (value) {
                      if (value == 'read') widget.onMarkAsRead();
                      if (value == 'archive') widget.onArchive();
                      if (value == 'delete') widget.onDelete();
                    },
                    itemBuilder: (ctx) => [
                      // "Marcar como leída" solo aparece si la notificación está sin leer.
                      if (notif.esSinLeer)
                        PopupMenuItem(
                          value: 'read',
                          child: Row(
                            children: [
                              const Icon(Icons.mark_email_read_outlined, size: 18),
                              const SizedBox(width: 10),
                              Text(widget.l10n.read),
                            ],
                          ),
                        ),
                      // "Archivar": mueve la notificación al estado archivado.
                      PopupMenuItem(
                        value: 'archive',
                        child: Row(
                          children: [
                            const Icon(Icons.archive_outlined, size: 18),
                            const SizedBox(width: 10),
                            Text(widget.l10n.archived),
                          ],
                        ),
                      ),
                      // "Eliminar": borra la notificación definitivamente.
                      // Se muestra en rojo para advertir que es una acción destructiva.
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: Theme.of(ctx).colorScheme.error),
                            const SizedBox(width: 10),
                            Text(
                              widget.l10n.delete,
                              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------- CHIP DE FILTRO --------
// Botón pequeño y redondeado que representa una opción de filtro.
// Cuando está seleccionado, tiene fondo de color sólido.
// Cuando no está seleccionado, tiene fondo transparente con borde de color.
class _TipoChip extends StatelessWidget {
  // Texto que se muestra dentro del chip.
  final String label;
  // Si true, este chip está activo (seleccionado).
  final bool selected;
  // Color asociado a este tipo de filtro.
  final Color color;
  // Icono opcional que aparece a la izquierda del texto.
  final IconData? icon;
  // Acción al pulsar el chip.
  final VoidCallback onTap;

  const _TipoChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // AnimatedContainer anima el cambio de color al seleccionar/deseleccionar.
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          // Seleccionado: color sólido. No seleccionado: color muy transparente.
          color: selected ? color : color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.35),
            width: selected ? 0 : 1, // Borde solo cuando no está seleccionado.
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Si tiene icono, lo mostramos a la izquierda del texto.
            if (icon != null) ...[
              Icon(icon, size: 15, color: selected ? Colors.white : color),
              const SizedBox(width: 5),
            ],
            // Texto del chip: blanco si seleccionado, del color del tipo si no.
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
