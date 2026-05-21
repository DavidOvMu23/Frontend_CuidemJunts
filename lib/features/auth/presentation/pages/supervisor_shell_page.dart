// Permite crear efectos de desenfoque (blur) en la interfaz.
import 'dart:ui';

// Librería principal de Flutter para construir la interfaz visual.
import 'package:flutter/material.dart';
// Constantes globales (puntos de ruptura de pantalla, roles…).
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';

// Riverpod: permite leer y escribir datos del estado global.
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Paleta de colores personalizada de la app.
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';
// Sistema de traducciones de la app.
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
// Importamos todas las pantallas que se pueden mostrar dentro del shell.
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/calls_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/emergency_contacts_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_operador_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/notifications_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/grupos_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
// Provider con el estado de autenticación del usuario.
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
// Modelo de datos de una llamada (se usa para editar llamadas pendientes).
import 'package:frontend_cuidemjunts/features/auth/data/models/llamadas.dart';
// Provider de llamadas y provider específico para la llamada que está pendiente de editar.
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/llamadas_provider.dart';
// Provider con el contador de notificaciones sin leer.
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';
// Widget del drawer (menú lateral) que define los DrawerItem (enum de secciones).
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';

// -------- PANTALLA MARCO (SHELL) DEL SUPERVISOR/OPERADOR --------
// SupervisorShellPage es el "contenedor" principal de toda la app tras el login.
// Gestiona la navegación entre secciones (Inicio, Llamadas, Usuarios…) SIN
// recargar la pantalla completa: solo cambia el panel de contenido central.
//
// En escritorio: muestra una barra lateral fija a la izquierda + contenido a la derecha.
// En móvil/tablet: la barra lateral se oculta en un Drawer (se abre con el menú hamburguesa).
class SupervisorShellPage extends ConsumerStatefulWidget {
  // Sección que se muestra al entrar (por defecto: Inicio).
  final DrawerItem initialSection;

  const SupervisorShellPage({
    super.key,
    this.initialSection = DrawerItem.home,
  });

  @override
  ConsumerState<SupervisorShellPage> createState() => _SupervisorShellPageState();
}

// -------- ESTADO INTERNO DEL SHELL --------
class _SupervisorShellPageState extends ConsumerState<SupervisorShellPage> {
  // Sección actualmente visible en el panel de contenido.
  late DrawerItem _selectedSection;
  // Si true, la barra lateral se muestra en modo compacto (solo iconos, sin texto).
  bool _compactSidebar = false;

  // -------- INICIALIZACIÓN --------
  // Establecemos la sección inicial según lo que nos pase el constructor.
  @override
  void initState() {
    super.initState();
    _selectedSection = widget.initialSection;
  }

  // -------- CAMBIAR SECCIÓN ACTIVA --------
  // Cuando el usuario pulsa un elemento de la barra lateral, llamamos a esta función.
  // Si venimos de un Drawer en móvil, también lo cerramos (closeDrawer: true).
  void _selectSection(DrawerItem item, {bool closeDrawer = false}) {
    // Si hay una ruta encima (el drawer abierto), la cerramos.
    if (closeDrawer && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    // Si ya estamos en esa sección, no hacemos nada (evitamos redibujar sin necesidad).
    if (_selectedSection == item) return;

    // Actualizamos la sección activa y Flutter redibuja el contenido.
    setState(() {
      _selectedSection = item;
    });
  }

  // -------- CERRAR SESIÓN --------
  // Limpia el estado de autenticación y lleva al usuario de vuelta al login.
  Future<void> _logout() async {
    // Borramos token y datos del usuario del estado global.
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;

    // Navegamos al login eliminando todas las rutas anteriores del stack.
    // Así el botón "atrás" no devuelve al usuario a la app.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // -------- TÍTULO DE LA SECCIÓN ACTIVA --------
  // Devuelve el texto que aparece en la barra superior según la sección visible.
  String _sectionTitle(AppLocalizations l10n) {
    switch (_selectedSection) {
      case DrawerItem.home:
        return l10n.supervisonPanel;
      case DrawerItem.calls:
        return l10n.calls;
      case DrawerItem.users:
        return l10n.users;
      case DrawerItem.emergencyContacts:
        return l10n.emergencyContacts;
      case DrawerItem.telemarketers:
        return l10n.telemarketers;
      case DrawerItem.groups:
        return l10n.groups;
      case DrawerItem.notifications:
        return l10n.notifications;
      case DrawerItem.preferences:
        return l10n.preferences;
    }
  }

  // -------- SUBTÍTULO DE LA SECCIÓN ACTIVA --------
  // Texto descriptivo pequeño que aparece debajo del título en la barra superior.
  // Para la pantalla de inicio adaptamos el texto al rol: "Supervisión" si es
  // supervisor, "Teleoperador" si es teleoperador.
  String _sectionSubtitle(AppLocalizations l10n, {required bool isSupervisor}) {
    switch (_selectedSection) {
      case DrawerItem.home:
        return isSupervisor ? l10n.supervison : l10n.teleoperator;
      case DrawerItem.calls:
        return l10n.superviseCalls;
      case DrawerItem.users:
        return l10n.manageUsers;
      case DrawerItem.emergencyContacts:
        return l10n.manageEmergencyContacts;
      case DrawerItem.telemarketers:
        return l10n.manageWorkers;
      case DrawerItem.groups:
        return l10n.manageGroups;
      case DrawerItem.notifications:
        return l10n.notificationsPressed;
      case DrawerItem.preferences:
        return l10n.appPreferences;
    }
  }

  // -------- LISTA DE ENTRADAS DE NAVEGACIÓN --------
  // Construye la lista de secciones que aparecen en la barra lateral.
  // Si el usuario es supervisor, se añaden "Teleoperadores" y "Grupos".
  // Si es operador, esas dos secciones NO aparecen.
  List<_ShellNavigationEntry> _entries(AppLocalizations l10n, {required bool isSupervisor}) {
    return [
      _ShellNavigationEntry(
        item: DrawerItem.home,
        icon: Icons.dashboard_rounded,
        label: l10n.mainPage,
      ),
      _ShellNavigationEntry(
        item: DrawerItem.calls,
        icon: Icons.phone_in_talk_rounded,
        label: l10n.calls,
      ),
      _ShellNavigationEntry(
        item: DrawerItem.users,
        icon: Icons.people_alt_rounded,
        label: l10n.users,
      ),
      _ShellNavigationEntry(
        item: DrawerItem.emergencyContacts,
        icon: Icons.contact_emergency_rounded,
        label: l10n.emergencyContacts,
      ),
      // Secciones exclusivas del supervisor (gestión de teleoperadores y grupos).
      if (isSupervisor)
        _ShellNavigationEntry(
          item: DrawerItem.telemarketers,
          icon: Icons.support_agent_rounded,
          label: l10n.telemarketers,
        ),
      if (isSupervisor)
        _ShellNavigationEntry(
          item: DrawerItem.groups,
          icon: Icons.group_work_rounded,
          label: l10n.groups,
        ),
      _ShellNavigationEntry(
        item: DrawerItem.notifications,
        icon: Icons.notifications_active_rounded,
        label: l10n.notifications,
      ),
      _ShellNavigationEntry(
        item: DrawerItem.preferences,
        icon: Icons.settings_rounded,
        label: l10n.preferences,
      ),
    ];
  }

  // -------- WIDGET DE LA SECCIÓN ACTIVA --------
  // Devuelve el widget (pantalla) que se muestra en el panel de contenido central
  // según la sección que el usuario haya seleccionado.
  Widget _sectionWidget(bool isSupervisor) {
    switch (_selectedSection) {
      case DrawerItem.home:
        // El supervisor ve su pantalla; el operador ve la suya.
        return isSupervisor
            ? const HomeSupervisorPage(embedded: true)
            : const HomeOperadorPage(embedded: true);
      case DrawerItem.calls:
        // Si hay una llamada pendiente de editar, la abrimos directamente en modo edición.
        return LlamadasPage(
          embedded: true,
          llamadaParaEditar: ref.read(pendingCallEditProvider),
        );
      case DrawerItem.users:
        return const UsersPage(embedded: true);
      case DrawerItem.emergencyContacts:
        return const EmergencyContactsPage(embedded: true);
      case DrawerItem.telemarketers:
        return const WorkersPage(embedded: true);
      case DrawerItem.groups:
        return const GruposPage(embedded: true);
      case DrawerItem.notifications:
        return const NotificationsPage(embedded: true);
      case DrawerItem.preferences:
        return const PreferencesPage(embedded: true);
    }
  }

  // -------- CONSTRUCCIÓN DE LA PANTALLA COMPLETA --------
  @override
  Widget build(BuildContext context) {
    // Textos traducidos al idioma activo.
    final l10n = AppLocalizations.of(context)!;
    // Estado del usuario autenticado.
    final authState = ref.watch(authProvider);
    // Número de notificaciones sin leer (para el badge de la campana).
    final unreadCountAsync = ref.watch(notificacionesSinLeerProvider);

    // -------- ESCUCHA DE LLAMADAS PENDIENTES DE EDITAR --------
    // Cuando otra parte de la app pone una llamada en pendingCallEditProvider
    // (por ejemplo, al pulsar "editar" en una llamada), navegamos automáticamente
    // a la sección de llamadas para que el formulario de edición se abra.
    ref.listen<Llamadas?>(pendingCallEditProvider, (_, next) {
      if (next != null) _selectSection(DrawerItem.calls);
    });

    // -------- DETECCIÓN DE TAMAÑO DE PANTALLA --------
    final width = MediaQuery.of(context).size.width;
    // En escritorio (pantalla muy ancha), mostramos la barra lateral fija.
    final isDesktop = width >= AppBreakpoints.shell;
    // En tablet (mediano), el drawer es un poco más ancho.
    final isTablet = width >= 720;

    final userName = authState.nombre;
    final userRole = authState.rol;
    // Comprobamos si el rol del usuario es "supervisor" para mostrar/ocultar secciones.
    final isSupervisor = (userRole ?? '').toLowerCase() == AppRoles.supervisor;

    // Si no hay usuario logueado, mostramos un aviso en lugar de la app.
    if (userName == null) {
      return Scaffold(
        body: Center(child: Text(l10n.noAuthenticatedUser)),
      );
    }

    // Extraemos el número entero de notificaciones del AsyncValue.
    final unreadCount = unreadCountAsync.when(
      data: (count) => count,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Scaffold(
      // En escritorio no necesitamos el gesto de deslizar para abrir el drawer,
      // porque la barra lateral ya es visible permanentemente.
      drawerEnableOpenDragGesture: !isDesktop,

      // -------- DRAWER (solo en móvil/tablet) --------
      // En escritorio no lo usamos porque la barra lateral está fija en el layout.
      drawer: isDesktop
          ? null
          : Drawer(
              // En tablet el drawer es más ancho que en móvil.
              width: isTablet ? 320 : width * 0.82,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
                  // Reutilizamos el mismo widget de barra lateral que en escritorio.
                  child: _ShellSidebar(
                    entries: _entries(l10n, isSupervisor: isSupervisor),
                    compact: false, // En drawer nunca es compacto.
                    selectedSection: _selectedSection,
                    userName: userName,
                    userRole: userRole ?? '-',
                    // Al pulsar una sección, la seleccionamos y cerramos el drawer.
                    onSectionTap: (item) =>
                        _selectSection(item, closeDrawer: true),
                    onLogoutTap: _logout,
                  ),
                ),
              ),
            ),

      // -------- CUERPO PRINCIPAL --------
      body: Stack(
        children: [
          // Fondo de pantalla con el color del tema activo.
          const _ShellBackground(),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 20 : 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -------- BARRA LATERAL FIJA (solo en escritorio) --------
                  // Su ancho cambia entre modo compacto (solo iconos) y expandido (icono + texto).
                  if (isDesktop)
                    SizedBox(
                      width: _compactSidebar ? 90 : 278,
                      child: _ShellSidebar(
                        entries: _entries(l10n, isSupervisor: isSupervisor),
                        compact: _compactSidebar,
                        selectedSection: _selectedSection,
                        userName: userName,
                        userRole: userRole ?? '-',
                        onSectionTap: _selectSection,
                        // Botón para alternar entre modo compacto y expandido.
                        onCompactToggle: () {
                          setState(() {
                            _compactSidebar = !_compactSidebar;
                          });
                        },
                        onLogoutTap: _logout,
                      ),
                    ),
                  if (isDesktop) const SizedBox(width: 18),

                  // -------- COLUMNA DE CONTENIDO PRINCIPAL --------
                  // Ocupa todo el espacio restante a la derecha de la barra lateral.
                  Expanded(
                    child: Column(
                      children: [
                        // Barra superior con título, subtítulo, campana y avatar.
                        Builder(
                          builder: (context) {
                            return _ShellTopBar(
                              title: _sectionTitle(l10n),
                              subtitle: _sectionSubtitle(l10n, isSupervisor: isSupervisor),
                              // En móvil mostramos el botón de menú hamburguesa.
                              showMenuButton: !isDesktop,
                              unreadCount: unreadCount,
                              userName: userName,
                              // Al pulsar el menú hamburguesa, abrimos el drawer.
                              onMenuTap: () => Scaffold.of(context).openDrawer(),
                              // Al pulsar la campana, vamos a la sección de notificaciones.
                              onNotificationsTap: () =>
                                  _selectSection(DrawerItem.notifications),
                            );
                          },
                        ),
                        const SizedBox(height: 14),

                        // -------- PANEL DE CONTENIDO CON ANIMACIÓN --------
                        // AnimatedSwitcher anima la transición entre secciones:
                        // la sección anterior se desvanece y la nueva aparece
                        // deslizándose suavemente desde la derecha.
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 280),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            // Animación personalizada: fundido + deslizamiento horizontal leve.
                            transitionBuilder: (child, animation) {
                              final slide = Tween<Offset>(
                                begin: const Offset(0.06, 0), // Empieza ligeramente a la derecha.
                                end: Offset.zero,             // Termina en su posición normal.
                              ).animate(animation);
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: slide,
                                  child: child,
                                ),
                              );
                            },
                            // La key es la sección activa: cuando cambia, AnimatedSwitcher
                            // detecta el cambio y reproduce la animación.
                            child: Container(
                              key: ValueKey<DrawerItem>(_selectedSection),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  isDesktop ? 30 : 24,
                                ),
                                color: Theme.of(context).cardColor,
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.24),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.18),
                                    blurRadius: 20,
                                    offset: const Offset(0, 14),
                                  ),
                                ],
                              ),
                              // ClipRRect recorta el contenido a los bordes redondeados del contenedor.
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  isDesktop ? 30 : 24,
                                ),
                                // El widget de la sección seleccionada.
                                child: _sectionWidget(isSupervisor),
                              ),
                            ),
                          ),
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
    );
  }
}

// -------- FONDO DE LA PANTALLA SHELL --------
// Widget simple que pinta el fondo con el color del tema activo.
// Está en un widget separado para mantener el código organizado.
class _ShellBackground extends StatelessWidget {
  const _ShellBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
      ),
      child: const SizedBox.expand(),
    );
  }
}

// -------- BARRA SUPERIOR DEL SHELL --------
// Muestra: [botón menú (solo móvil)] [título + subtítulo] [campana] [avatar usuario]
// Tiene un efecto de cristal esmerilado (blur) para un aspecto moderno.
class _ShellTopBar extends StatelessWidget {
  // Título principal (nombre de la sección activa).
  final String title;
  // Subtítulo descriptivo de la sección.
  final String subtitle;
  // Si true, se muestra el botón de menú hamburguesa (en móvil).
  final bool showMenuButton;
  // Número de notificaciones sin leer (para el badge rojo).
  final int unreadCount;
  // Nombre del usuario autenticado (para el avatar con iniciales).
  final String userName;
  // Acción al pulsar el botón de menú hamburguesa.
  final VoidCallback onMenuTap;
  // Acción al pulsar el icono de la campana.
  final VoidCallback onNotificationsTap;

  const _ShellTopBar({
    required this.title,
    required this.subtitle,
    required this.showMenuButton,
    required this.unreadCount,
    required this.userName,
    required this.onMenuTap,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // -------- INICIALES DEL USUARIO --------
    // Tomamos las primeras letras de cada palabra del nombre (máximo 2).
    // Ejemplo: "Maria García" → "MG"
    final initials = userName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.substring(0, 1).toUpperCase())
        .join();

    // ClipRRect + BackdropFilter crean el efecto de cristal esmerilado (blur).
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16), // Intensidad del desenfoque.
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            // Fondo semitransparente para que se vea el efecto blur.
            color: Theme.of(context).colorScheme.surface.withOpacity(0.82),
            border: Border.all(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.20),
            ),
          ),
          child: Row(
            children: [
              // Botón de menú hamburguesa: solo se muestra en móvil.
              if (showMenuButton)
                IconButton(
                  onPressed: onMenuTap,
                  icon: const Icon(Icons.menu_rounded),
                ),
              if (showMenuButton) const SizedBox(width: 8),

              // Título y subtítulo de la sección activa.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // -------- ICONO DE NOTIFICACIONES CON BADGE --------
              // El badge (número rojo) solo es visible si hay notificaciones sin leer.
              Badge(
                isLabelVisible: unreadCount > 0,
                label: Text(unreadCount.toString()),
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: onNotificationsTap,
                  icon: const Icon(Icons.notifications_outlined),
                ),
              ),
              const SizedBox(width: 10),

              // -------- AVATAR DEL USUARIO --------
              // Círculo con las iniciales del usuario. Al pasar el ratón por encima
              // (en escritorio) muestra el nombre completo como tooltip.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Tooltip(
                  message: userName,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      // Si no hay iniciales (nombre vacío), mostramos "?".
                      initials.isEmpty ? '?' : initials,
                      style: textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

// -------- BARRA LATERAL DE NAVEGACIÓN --------
// Panel vertical con logo, lista de secciones y datos del usuario + botón de cerrar sesión.
// Funciona tanto en modo expandido (icono + texto) como en modo compacto (solo icono).
class _ShellSidebar extends StatelessWidget {
  // Lista de secciones a mostrar en el menú.
  final List<_ShellNavigationEntry> entries;
  // Si true, solo se muestran iconos (sin texto).
  final bool compact;
  // Sección actualmente seleccionada (para resaltarla).
  final DrawerItem selectedSection;
  // Nombre del usuario autenticado.
  final String userName;
  // Rol del usuario ("supervisor" u "operador").
  final String userRole;
  // Acción al pulsar una sección del menú.
  final void Function(DrawerItem) onSectionTap;
  // Acción opcional para alternar modo compacto (solo en escritorio).
  final VoidCallback? onCompactToggle;
  // Acción al pulsar el botón de cerrar sesión.
  final VoidCallback onLogoutTap;

  const _ShellSidebar({
    required this.entries,
    required this.compact,
    required this.selectedSection,
    required this.userName,
    required this.userRole,
    required this.onSectionTap,
    this.onCompactToggle,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // ClipRRect + BackdropFilter: efecto de cristal esmerilado en la barra lateral.
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: colorScheme.surface,
            border: Border.all(color: colorScheme.secondary.withOpacity(0.20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
        children: [
          // -------- CABECERA: LOGO + NOMBRE DE LA APP --------
          Padding(
            padding: EdgeInsets.fromLTRB(compact ? 4 : 10, 10, compact ? 4 : 10, 6),
            child: Row(
              children: [
                // Logo de la app (más pequeño en modo compacto).
                Image.asset(
                  'assets/images/Logo_CuidemJunts.png',
                  height: compact ? 38 : 48,
                ),
                if (!compact) const SizedBox(width: 10),
                // Nombre y lema de la app (solo en modo expandido).
                if (!compact)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cuidem-nos en xarxa',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          l10n.controlAndMonitoring,
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                // Botón para colapsar/expandir la barra lateral (solo en escritorio).
                if (onCompactToggle != null)
                  IconButton(
                    tooltip: compact ? l10n.expandMenu : l10n.compactMenu,
                    onPressed: onCompactToggle,
                    icon: Icon(
                      compact
                          ? Icons.keyboard_double_arrow_right_rounded
                          : Icons.keyboard_double_arrow_left_rounded,
                    ),
                  ),
              ],
            ),
          ),
          // Línea separadora entre cabecera y lista de secciones.
          Divider(
            height: 1,
            color: colorScheme.secondary.withOpacity(0.30),
          ),

          // -------- LISTA DE SECCIONES --------
          // ListView.builder construye solo los elementos visibles (eficiente).
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(4, 6, 4, 4),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                // Cada sección es un item de la barra lateral con icono y texto.
                return _SidebarNavItem(
                  compact: compact,
                  label: entry.label,
                  icon: entry.icon,
                  // Marcamos como seleccionado el item que coincide con la sección activa.
                  selected: selectedSection == entry.item,
                  onTap: () => onSectionTap(entry.item),
                );
              },
            ),
          ),

          // Línea separadora antes del área de usuario.
          Divider(
            height: 1,
            color: colorScheme.primary.withOpacity(0.14),
          ),

          // -------- PIE DE LA BARRA: DATOS DEL USUARIO Y CERRAR SESIÓN --------
          Padding(
            padding: EdgeInsets.fromLTRB(compact ? 4 : 8, 6, compact ? 4 : 8, 6),
            child: compact
                // Modo compacto: solo avatar y botón de logout apilados.
                ? Column(
                    children: [
                      // Avatar con tooltip que muestra nombre y rol al pasar el ratón.
                      Tooltip(
                        message: '$userName ($userRole)',
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: colorScheme.primary,
                          child: const Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Botón de cerrar sesión.
                      IconButton(
                        tooltip: l10n.logOut,
                        onPressed: onLogoutTap,
                        icon: const Icon(Icons.logout_rounded),
                      ),
                    ],
                  )
                // Modo expandido: avatar + nombre + rol en fila, y botón de logout.
                : Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: colorScheme.primary,
                        child: const Icon(Icons.person_outline),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nombre del usuario (cortado con "…" si es muy largo).
                            Text(
                              userName,
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Rol del usuario debajo del nombre.
                            Text(
                              userRole,
                              style: textTheme.labelSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Botón de cerrar sesión al final de la fila.
                      IconButton(
                        tooltip: l10n.logOut,
                        onPressed: onLogoutTap,
                        icon: const Icon(Icons.logout_rounded),
                      ),
                    ],
                  ),
          ),
        ],
      ),
          ),
        ),
    );
  }
}

// -------- ITEM DE NAVEGACIÓN DE LA BARRA LATERAL --------
// Cada sección del menú es un _SidebarNavItem.
// Tiene un efecto visual cuando el ratón pasa por encima (hover) y
// un color de fondo diferente cuando está seleccionado.
class _SidebarNavItem extends StatefulWidget {
  // Si true, solo se muestra el icono (sin texto).
  final bool compact;
  // Texto de la sección.
  final String label;
  // Icono de la sección.
  final IconData icon;
  // Si true, este item está seleccionado actualmente.
  final bool selected;
  // Acción al pulsar este item.
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.compact,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  // Registramos si el ratón está encima del item para cambiar el color de fondo.
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // -------- COLOR DE FONDO DEL ITEM --------
    // Seleccionado → fondo con tinte primario más fuerte.
    // Con hover → fondo con tinte primario suave.
    // Normal → sin fondo.
    final bgColor = widget.selected
      ? colorScheme.primary.withOpacity(0.22)
      : _hovered
        ? colorScheme.primary.withOpacity(0.12)
        : Colors.transparent;

    // -------- COLOR DEL ICONO Y TEXTO --------
    // Seleccionado → color de texto sobre primario.
    // Normal → color de superficie con leve transparencia.
    final fgColor = widget.selected
      ? colorScheme.onPrimary
      : colorScheme.onSurface.withOpacity(0.84);

    // AnimatedScale agranda levemente el item cuando el ratón está encima.
    final item = AnimatedScale(
      duration: const Duration(milliseconds: 160),
      scale: _hovered ? 1.01 : 1,
      child: AnimatedContainer(
        // AnimatedContainer anima suavemente los cambios de color de fondo.
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 6),
        padding: EdgeInsets.symmetric(
          horizontal: widget.compact ? 0 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          // Borde sutil solo cuando el item está seleccionado.
          border: Border.all(
            color: widget.selected
                ? colorScheme.primary.withOpacity(0.30)
                : Colors.transparent,
          ),
        ),
        // En modo compacto: solo el icono centrado.
        // En modo expandido: icono + texto en fila.
        child: widget.compact
            ? SizedBox(
                height: 36,
                child: Icon(widget.icon, color: fgColor),
              )
            : Row(
                children: [
                  Icon(widget.icon, color: fgColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: textTheme.bodyMedium?.copyWith(
                        color: fgColor,
                        // El item seleccionado tiene texto más grueso.
                        fontWeight:
                            widget.selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );

    // MouseRegion detecta cuando el ratón entra y sale del item (para el efecto hover).
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click, // Cambia el cursor del ratón a una mano.
      child: Tooltip(
        // En modo compacto, el tooltip muestra el nombre de la sección al hacer hover.
        // En modo expandido, el texto ya es visible, por lo que no necesitamos tooltip.
        message: widget.compact ? widget.label : '',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: widget.onTap,
            child: item,
          ),
        ),
      ),
    );
  }
}

// -------- MODELO DE DATO: ENTRADA DE NAVEGACIÓN --------
// Representa una sección de la barra lateral con su item (enum), icono y etiqueta.
// Es solo un contenedor de datos, no tiene interfaz visual propia.
class _ShellNavigationEntry {
  // Identificador de la sección (enum DrawerItem).
  final DrawerItem item;
  // Icono que se muestra en la barra lateral.
  final IconData icon;
  // Texto de la sección (traducido).
  final String label;

  const _ShellNavigationEntry({
    required this.item,
    required this.icon,
    required this.label,
  });
}
