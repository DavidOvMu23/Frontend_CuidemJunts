import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/core/widgets/loading_skeleton.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/notificacion.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/calls_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/emergency_contacts_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/grupos_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  final bool embedded;

  const NotificationsPage({super.key, this.embedded = false});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  String _selectedEstado = 'todos';
  String _selectedTipo = 'todos';

  static const _tipoColors = {
    'call':        Color(0xFF2196F3), // azul
    'system':      Color(0xFFFF9800), // naranja
    'supervision': Color(0xFF4CAF50), // verde
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
    final userRole = authState.rol;
    final notificacionesAsync = ref.watch(notificacionesProvider);
    final notificacionesSinLeerAsync = ref.watch(notificacionesSinLeerProvider);
    final unreadCount = notificacionesSinLeerAsync.when(
      data: (count) => count,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final horizontalPadding = isDesktop ? 20.0 : 12.0;

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
                      // Filtros — estado (izquierda) + tipo (derecha)
                      Row(
                        children: [
                          // Estado
                          Wrap(
                            spacing: 8,
                            children: [
                              _TipoChip(
                                label: l10n.all,
                                selected: _selectedEstado == 'todos',
                                color: colorScheme.primary,
                                onTap: () => setState(() => _selectedEstado = 'todos'),
                              ),
                              _TipoChip(
                                label: l10n.unread,
                                selected: _selectedEstado == 'sin_leer',
                                color: colorScheme.primary,
                                onTap: () => setState(() => _selectedEstado = 'sin_leer'),
                              ),
                              _TipoChip(
                                label: l10n.read,
                                selected: _selectedEstado == 'leida',
                                color: colorScheme.primary,
                                onTap: () => setState(() => _selectedEstado = 'leida'),
                              ),
                              _TipoChip(
                                label: l10n.archived,
                                selected: _selectedEstado == 'archivada',
                                color: colorScheme.primary,
                                onTap: () => setState(() => _selectedEstado = 'archivada'),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Tipo
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
                      Divider(
                        height: 8,
                        color: colorScheme.primary.withValues(alpha: 0.3),
                      ),

                      // Lista
                      Expanded(
                        child: notificacionesAsync.when(
                          data: (notificaciones) {
                            final filtered = notificaciones.where((n) {
                              final estadoOk = _selectedEstado == 'todos' || n.estado == _selectedEstado;
                              final tipoOk = _selectedTipo == 'todos' || n.tipo == _selectedTipo;
                              return estadoOk && tipoOk;
                            }).toList();

                            if (filtered.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
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

                            return RefreshIndicator(
                              onRefresh: () async {
                                ref.invalidate(notificacionesProvider);
                                await ref.read(notificacionesProvider.future);
                              },
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (ctx, i) {
                                  final notif = filtered[i];
                                  return _NotificationCard(
                                    notif: notif,
                                    l10n: l10n,
                                    onMarkAsRead: () async {
                                      await ref.read(notificacionServiceProvider).markAsRead(notif.id);
                                      ref.invalidate(notificacionesProvider);
                                      if (context.mounted) general_snackbar(context, l10n.read, 1);
                                    },
                                    onArchive: () async {
                                      await ref.read(notificacionServiceProvider).archive(notif.id);
                                      ref.invalidate(notificacionesProvider);
                                      if (context.mounted) general_snackbar(context, l10n.archived, 1);
                                    },
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
                          loading: () => const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: AppSkeletonList(count: 5),
                          ),
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

    if (widget.embedded) return content;

    return Scaffold(
      appBar: appMainAppBar(
        numeroNotificaciones: unreadCount,
        onNotifications: () {
          general_snackbar(context, l10n.notificationsPressed, 1);
        },
        context: context,
      ),
      drawer: appDrawer(
        userName: userName,
        userRole: userRole,
        context: context,
        selected: DrawerItem.notifications,
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
        onLogoutConfirmed: () async {
          await ref.read(authProvider.notifier).logout();
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        },
      ),
      body: content,
    );
  }
}

class _NotificationCard extends StatefulWidget {
  final Notificacion notif;
  final AppLocalizations l10n;
  final VoidCallback onMarkAsRead;
  final VoidCallback onArchive;
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
  bool _hovered = false;

  String _formatDate(DateTime date) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} · ${two(date.hour)}:${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final notif = widget.notif;

    const tipoColors = _NotificationsPageState._tipoColors;
    final tipoColor = tipoColors[notif.tipo] ?? colorScheme.primary;
    final accentColor = notif.esArchivada ? colorScheme.outline : tipoColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 170),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
      child: Material(
        color: notif.esSinLeer
            ? tipoColor.withValues(alpha: 0.13)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        elevation: _hovered ? 2 : (notif.esSinLeer ? 1 : 0),
        shadowColor: tipoColor.withValues(alpha: 0.25),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onHover: (v) { if (_hovered != v) setState(() => _hovered = v); },
          onTap: notif.esSinLeer ? widget.onMarkAsRead : null,
          child: Stack(
            children: [
              // Borde izquierdo de color por tipo
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
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 48, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icono tipo notificación
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título + punto de no leído
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (notif.esSinLeer) ...[
                                Container(
                                  width: 9,
                                  height: 9,
                                  margin: const EdgeInsets.only(right: 8, top: 1),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorScheme.primary.withValues(alpha: 0.85),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (notif.titulo != null) ...[
                                      Text(
                                        notif.titulo!,
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontWeight: notif.esSinLeer ? FontWeight.w700 : FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        notif.tipoLegible,
                                        style: textTheme.labelSmall?.copyWith(
                                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ] else
                                      Text(
                                        notif.tipoLegible,
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontWeight: notif.esSinLeer ? FontWeight.w700 : FontWeight.w600,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notif.contenido,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: notif.esSinLeer ? 0.9 : 0.65,
                              ),
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 13,
                                color: colorScheme.primary,
                              ),
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

              // Menú de acciones
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
                    onSelected: (value) {
                      if (value == 'read') widget.onMarkAsRead();
                      if (value == 'archive') widget.onArchive();
                      if (value == 'delete') widget.onDelete();
                    },
                    itemBuilder: (ctx) => [
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

class _TipoChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final IconData? icon;
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.35),
            width: selected ? 0 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: selected ? Colors.white : color),
              const SizedBox(width: 5),
            ],
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
