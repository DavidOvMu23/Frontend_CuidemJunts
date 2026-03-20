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

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
    final userRole = authState.rol;

    final notificacionesAsync = ref.watch(notificacionesProvider);
    final notificacionesSinLeerAsync = ref.watch(notificacionesSinLeerProvider);

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.notifications,
              style: textTheme.titleMedium?.copyWith(fontSize: 27),
            ),
            Text(l10n.notificationsPressed, style: textTheme.bodyMedium),
            const SizedBox(height: 7),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Material(
                  borderRadius: BorderRadius.circular(30),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: notificacionesAsync.when(
                      data: (notificaciones) {
                        if (notificaciones.isEmpty) {
                          return Center(
                            child: Text(
                              l10n.noNotifications,
                              style: textTheme.bodyMedium,
                            ),
                          );
                        }

                        final sinLeer = notificaciones
                            .where((n) => n.esSinLeer)
                            .toList();
                        final leidas = notificaciones
                            .where((n) => n.esLeida)
                            .toList();
                        final otras = notificaciones
                            .where((n) => !n.esSinLeer && !n.esLeida)
                            .toList();

                        return ListView(
                          children: [
                            _NotificationSection(
                              title: l10n.unread,
                              notifications: sinLeer,
                              icon: Icons.mark_email_unread_outlined,
                              color: colorScheme.primary,
                              onTapNotification: (notif) {
                                _showNotificationDetail(context, l10n, notif);
                              },
                              onMarkAsRead: (notif) async {
                                await ref
                                    .read(notificacionServiceProvider)
                                    .markAsRead(notif.id);
                                ref.invalidate(notificacionesProvider);
                                general_snackbar(context, l10n.read, 1);
                              },
                            ),
                            _NotificationSection(
                              title: l10n.read,
                              notifications: leidas,
                              icon: Icons.drafts_outlined,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                              onTapNotification: (notif) {
                                _showNotificationDetail(context, l10n, notif);
                              },
                            ),
                            _NotificationSection(
                              title: l10n.all,
                              notifications: otras,
                              icon: Icons.notifications_none,
                              color: colorScheme.onSurface,
                              onTapNotification: (notif) {
                                _showNotificationDetail(context, l10n, notif);
                              },
                            ),
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) => Center(
                        child: Text(
                          l10n.errorNotificationsLoading,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDetail(
    BuildContext context,
    AppLocalizations l10n,
    Notificacion notif,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${l10n.notifications} #${notif.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notif.contenido,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Text(
              '${l10n.accountStatus}: ${notif.estado}',
              style: Theme.of(context).textTheme.bodySmall,
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
}

class _NotificationSection extends StatelessWidget {
  final String title;
  final List<Notificacion> notifications;
  final IconData icon;
  final Color color;
  final void Function(Notificacion) onTapNotification;
  final Future<void> Function(Notificacion)? onMarkAsRead;

  const _NotificationSection({
    required this.title,
    required this.notifications,
    required this.icon,
    required this.color,
    required this.onTapNotification,
    this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ...notifications.map(
            (notif) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0,
              child: ListTile(
                leading: Icon(icon, color: color),
                title: Text(notif.contenido),
                subtitle: Text('ID: ${notif.id} · ${notif.estado}'),
                onTap: () => onTapNotification(notif),
                trailing: notif.esSinLeer && onMarkAsRead != null
                    ? IconButton(
                        icon: const Icon(Icons.mark_email_read_outlined),
                        onPressed: () => onMarkAsRead!(notif),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
