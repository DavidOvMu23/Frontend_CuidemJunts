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
  String _searchQuery = '';

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

    final bodyContent = Column(
      children: [
        // Header con búsqueda y filtros
        Container(
          color: colorScheme.surface,
          padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            children: [
              // Búsqueda
              SearchBar(
                hintText: l10n.search,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                backgroundColor: const WidgetStatePropertyAll(
                  Colors.transparent,
                ),
                side: WidgetStatePropertyAll(
                  BorderSide(color: colorScheme.outline),
                ),
              ),
              const SizedBox(height: 12),
              // Filtros
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(l10n.all),
                      selected: _selectedEstado == 'todos',
                      onSelected: (selected) {
                        setState(() => _selectedEstado = 'todos');
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(l10n.unread),
                      selected: _selectedEstado == 'sin_leer',
                      onSelected: (selected) {
                        setState(() => _selectedEstado = 'sin_leer');
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(l10n.read),
                      selected: _selectedEstado == 'leida',
                      onSelected: (selected) {
                        setState(() => _selectedEstado = 'leida');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Lista de notificaciones
        Expanded(
          child: notificacionesAsync.when(
            data: (notificaciones) {
              // Filtrar notificaciones
              var filtered = notificaciones.where((n) {
                final estadoMatch =
                    _selectedEstado == 'todos' || n.estado == _selectedEstado;
                final searchMatch =
                    _searchQuery.isEmpty ||
                    n.contenido.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    );
                return estadoMatch && searchMatch;
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    l10n.noNotifications,
                    style: textTheme.bodyMedium,
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(horizontalPadding),
                itemCount: filtered.length,
                itemBuilder: (ctx, index) {
                  final notif = filtered[index];
                  return _NotificationTimelineCard(
                    notif: notif,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    l10n: l10n,
                    onMarkAsRead: () async {
                      await ref
                          .read(notificacionServiceProvider)
                          .markAsRead(notif.id);
                      ref.invalidate(notificacionesProvider);
                      if (context.mounted) {
                        general_snackbar(context, l10n.read, 1);
                      }
                    },
                    onArchive: () async {
                      await ref
                          .read(notificacionServiceProvider)
                          .archive(notif.id);
                      ref.invalidate(notificacionesProvider);
                      if (context.mounted) {
                        general_snackbar(context, l10n.archived, 1);
                      }
                    },
                    onDelete: () async {
                      await ref
                          .read(notificacionServiceProvider)
                          .delete(notif.id);
                      ref.invalidate(notificacionesProvider);
                      if (context.mounted) {
                        general_snackbar(context, l10n.delete, 1);
                      }
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(
              child: Text(
                l10n.errorNotificationsLoading,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
              ),
            ),
          ),
        ),
      ],
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
        onNotifications: () {
          general_snackbar(context, l10n.notificationsPressed, 1);
        },
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

class _NotificationTimelineCard extends StatelessWidget {
  final Notificacion notif;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations l10n;
  final VoidCallback onMarkAsRead;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const _NotificationTimelineCard({
    required this.notif,
    required this.colorScheme,
    required this.textTheme,
    required this.l10n,
    required this.onMarkAsRead,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tipoIcono = notif.tipoIcono;
    final tipoLegible = notif.tipoLegible;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notif.esSinLeer ? 2 : 0,
      color: notif.esSinLeer
          ? colorScheme.primaryContainer.withValues(alpha: 0.3)
          : colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(tipoIcono, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tipoLegible,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        notif.estado,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                // Estado badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    border: Border.all(color: colorScheme.primary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    notif.estado,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Contenido
            Text(notif.contenido, style: textTheme.bodyMedium),
            const SizedBox(height: 8),
            // Timestamp
            Text(
              'ID: ${notif.id} · ${notif.createdAt.toString().split('.')[0]}',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 12),
            // Acciones
            Row(
              children: [
                if (notif.esSinLeer)
                  TextButton.icon(
                    icon: const Icon(Icons.mark_email_read),
                    label: Text(l10n.read),
                    onPressed: onMarkAsRead,
                  ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.archive_outlined),
                  label: Text(l10n.archived),
                  onPressed: onArchive,
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.delete),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
