import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
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

class NotificationsPageV2 extends ConsumerStatefulWidget {
  final bool embedded;

  const NotificationsPageV2({super.key, this.embedded = false});

  @override
  ConsumerState<NotificationsPageV2> createState() =>
      _NotificationsPageV2State();
}

class _NotificationsPageV2State extends ConsumerState<NotificationsPageV2> {
  String _searchQuery = '';
  String? _selectedEstado;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
    final userRole = authState.rol;

    final notificacionesAsync = ref.watch(notificacionesProvider);
    final notificacionesSinLeerAsync = ref.watch(notificacionesSinLeerProvider);

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final horizontalPadding = isDesktop ? 20.0 : 12.0;

    final bodyContent = Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
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
                      // 1. Búsqueda + filtro
                      _SearchAndFiltersBar(
                        searchQuery: _searchQuery,
                        selectedEstado: _selectedEstado,
                        onSearchChanged: (value) => setState(() => _searchQuery = value),
                        onEstadoChanged: (value) => setState(() => _selectedEstado = value),
                        onMarkAllRead: () => general_snackbar(context, 'Función proximamente', 2),
                      ),
                      const SizedBox(height: 10),
                      Divider(height: 8, color: colorScheme.primary.withValues(alpha: 0.3)),
                      // 2. Lista
                      Expanded(
                        child: notificacionesAsync.when(
                          data: (notificaciones) {
                            var filtered = notificaciones;

                            if (_searchQuery.isNotEmpty) {
                              filtered = filtered
                                  .where((n) => n.contenido.toLowerCase().contains(_searchQuery.toLowerCase()))
                                  .toList();
                            }
                            if (_selectedEstado != null) {
                              filtered = filtered.where((n) => n.estado == _selectedEstado).toList();
                            }

                            final sinLeerCount = notificacionesSinLeerAsync.maybeWhen(data: (c) => c, orElse: () => 0);
                            final totalText = _searchQuery.isEmpty && _selectedEstado == null
                                ? '${l10n.totalNotifications}: ${notificaciones.length}'
                                : '${l10n.results}: ${filtered.length}';

                            if (filtered.isEmpty) {
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Text(totalText, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 16))),
                                      IconButton(
                                        icon: Icon(Icons.refresh, color: colorScheme.primary),
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () => ref.refresh(notificacionesProvider),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.notifications_off_outlined, size: 64, color: colorScheme.outline),
                                          const SizedBox(height: 12),
                                          Text(
                                            notificaciones.isEmpty ? l10n.noNotifications : l10n.noResultsFound,
                                            style: textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }

                            final sinLeer = filtered.where((n) => n.esSinLeer).toList();
                            final leidas = filtered.where((n) => n.esLeida).toList();
                            final archivadas = filtered.where((n) => n.esArchivada).toList();

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(totalText, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 16))),
                                    if (sinLeerCount > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Text('$sinLeerCount ${l10n.unread}', style: textTheme.bodySmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600)),
                                      ),
                                    IconButton(
                                      icon: Icon(Icons.refresh, color: colorScheme.primary),
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => ref.refresh(notificacionesProvider),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: ListView(
                                    children: [
                                      if (sinLeer.isNotEmpty)
                                        _NotificationGroup(
                                          title: '${l10n.unread} (${sinLeer.length})',
                                          notifications: sinLeer,
                                          backgroundColor: colorScheme.primaryContainer,
                                          onRefresh: () => ref.refresh(notificacionesProvider),
                                        ),
                                      if (sinLeer.isNotEmpty && leidas.isNotEmpty) const SizedBox(height: 16),
                                      if (leidas.isNotEmpty)
                                        _NotificationGroup(
                                          title: '${l10n.read} (${leidas.length})',
                                          notifications: leidas,
                                          backgroundColor: colorScheme.surface,
                                          onRefresh: () => ref.refresh(notificacionesProvider),
                                        ),
                                      if (leidas.isNotEmpty && archivadas.isNotEmpty) const SizedBox(height: 16),
                                      if (archivadas.isNotEmpty)
                                        _NotificationGroup(
                                          title: '${l10n.archivedNotifications} (${archivadas.length})',
                                          notifications: archivadas,
                                          backgroundColor: colorScheme.outlineVariant.withValues(alpha: 0.1),
                                          onRefresh: () => ref.refresh(notificacionesProvider),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, stack) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.errorNotificationsLoading,
                                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                          onPressed: () => ref.refresh(notificacionesProvider),
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

    if (widget.embedded) {
      return bodyContent;
    }

    return Scaffold(
      appBar: appMainAppBar(
        numeroNotificaciones: notificacionesSinLeerAsync.when(
          data: (count) => count,
          loading: () => 0,
          error: (_, __) => 0,
        ),
        onNotifications: () {},
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LlamadasPage()),
          );
        },
        onTapUsers: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UsersPage()),
          );
        },
        onTapEmergencyContacts: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EmergencyContactsPage()),
          );
        },
        onTapTelemarketers: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WorkersPage()),
          );
        },
        onTapGroups: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GruposPage()),
          );
        },
        onTapPreferences: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PreferencesPage()),
          );
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
      body: bodyContent,
    );
  }
}

// Barra de búsqueda y filtros
class _SearchAndFiltersBar extends StatelessWidget {
  final String searchQuery;
  final String? selectedEstado;
  final Function(String) onSearchChanged;
  final Function(String?) onEstadoChanged;
  final VoidCallback onMarkAllRead;

  const _SearchAndFiltersBar({
    required this.searchQuery,
    required this.selectedEstado,
    required this.onSearchChanged,
    required this.onEstadoChanged,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: general_busqueda_textfield(
            l10n.searchNotifications,
            icono: Icons.search,
            onChanged: onSearchChanged,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Icon(
                selectedEstado != null ? Icons.filter_alt : Icons.filter_alt_off,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: selectedEstado,
                  icon: const Icon(Icons.arrow_drop_down),
                  borderRadius: BorderRadius.circular(12),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.allNotifications)),
                    DropdownMenuItem(value: 'sin_leer', child: Text(l10n.unreadNotifications)),
                    DropdownMenuItem(value: 'leida', child: Text(l10n.readNotifications)),
                    DropdownMenuItem(value: 'archivada', child: Text(l10n.archivedNotifications)),
                  ],
                  onChanged: onEstadoChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Grupo de notificaciones
class _NotificationGroup extends ConsumerWidget {
  final String title;
  final List<Notificacion> notifications;
  final Color backgroundColor;
  final VoidCallback onRefresh;

  const _NotificationGroup({
    required this.title,
    required this.notifications,
    required this.backgroundColor,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...notifications.asMap().entries.map(
            (entry) => _NotificationCard(
              notificacion: entry.value,
              isLast: entry.key == notifications.length - 1,
              onRefresh: onRefresh,
            ),
          ),
        ],
      ),
    );
  }
}

// Tarjeta de notificación mejorada
class _NotificationCard extends ConsumerWidget {
  final Notificacion notificacion;
  final bool isLast;
  final VoidCallback onRefresh;

  const _NotificationCard({
    required this.notificacion,
    required this.isLast,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final service = ref.read(notificacionServiceProvider);

    // Tiempo relativo
    final now = DateTime.now();
    final diff = now.difference(notificacion.createdAt);
    final timeAgo = diff.inMinutes < 1
        ? 'Hace un momento'
        : diff.inHours < 1
        ? 'Hace ${diff.inMinutes}m'
        : diff.inDays < 1
        ? 'Hace ${diff.inHours}h'
        : 'Hace ${diff.inDays}d';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Material(
            color: notificacion.esSinLeer
                ? colorScheme.primary.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => _showDetail(context, notificacion),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ícono del tipo
                    Icon(notificacion.tipoIcono, size: 24),
                    const SizedBox(width: 12),
                    // Contenido
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notificacion.tipoLegible,
                                  style: textTheme.labelMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (notificacion.esSinLeer)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notificacion.contenido,
                            style: textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            timeAgo,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Acciones
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        if (notificacion.esSinLeer)
                          PopupMenuItem(
                            child: const Row(
                              children: [
                                Icon(Icons.mail),
                                SizedBox(width: 8),
                                Text('Marcar leído'),
                              ],
                            ),
                            onTap: () async {
                              try {
                                await service.markAsRead(notificacion.id);
                                onRefresh();
                              } catch (e) {
                                if (context.mounted) {
                                  general_snackbar_error(context, extractErrorMessage(e), 4);
                                }
                              }
                            },
                          ),
                        if (!notificacion.esArchivada)
                          PopupMenuItem(
                            child: const Row(
                              children: [
                                Icon(Icons.archive),
                                SizedBox(width: 8),
                                Text('Archivar'),
                              ],
                            ),
                            onTap: () async {
                              try {
                                await service.archive(notificacion.id);
                                onRefresh();
                              } catch (e) {
                                if (context.mounted) {
                                  general_snackbar_error(context, extractErrorMessage(e), 4);
                                }
                              }
                            },
                          ),
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(Icons.delete),
                              SizedBox(width: 8),
                              Text('Eliminar'),
                            ],
                          ),
                          onTap: () async {
                            try {
                              await service.delete(notificacion.id);
                              onRefresh();
                            } catch (e) {
                              if (context.mounted) {
                                general_snackbar_error(context, extractErrorMessage(e), 4);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Divider(
              height: 1,
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
      ],
    );
  }

  void _showDetail(BuildContext context, Notificacion notif) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(notif.tipoIcono, size: 28, color: colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(notif.tipoLegible)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notif.contenido, style: textTheme.bodyMedium),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(label: 'ID:', value: notif.id.toString()),
                    const SizedBox(height: 6),
                    _DetailRow(label: 'Estado:', value: notif.estado),
                    const SizedBox(height: 6),
                    _DetailRow(label: 'Tipo:', value: notif.tipoLegible),
                    const SizedBox(height: 6),
                    _DetailRow(
                      label: 'Creada:',
                      value: _formatDate(notif.createdAt),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
