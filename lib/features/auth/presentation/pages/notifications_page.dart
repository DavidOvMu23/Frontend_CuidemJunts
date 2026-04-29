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
    final horizontalPadding = isDesktop ? 24.0 : 14.0;

    Widget content = notificacionesAsync.when(
      data: (notificaciones) {
        final filtered = notificaciones.where((n) {
          final estadoMatch =
              _selectedEstado == 'todos' || n.estado == _selectedEstado;
          final searchMatch =
              _searchQuery.isEmpty ||
              n.contenido.toLowerCase().contains(_searchQuery.toLowerCase());
          return estadoMatch && searchMatch;
        }).toList();

        final totalNotifications = notificaciones.length;
        final unreadNotifications =
            notificaciones.where((n) => n.esSinLeer).length;
        final archivedNotifications =
            notificaciones.where((n) => n.esArchivada).length;
        final readNotifications = notificaciones.where((n) => n.esLeida).length;

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                6,
              ),
              child: _NotificationsHero(
                title: l10n.notifications,
                colorScheme: colorScheme,
                textTheme: textTheme,
                selectedEstado: _selectedEstado,
                unreadNotifications: unreadNotifications,
                onSearchChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                onEstadoChanged: (value) {
                  setState(() => _selectedEstado = value);
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  2,
                  horizontalPadding,
                  16,
                ),
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(notificacionesProvider);
                    await ref.read(notificacionesProvider.future);
                  },
                  child: filtered.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.46,
                              child: _NotificationsEmptyState(
                                icon: notificaciones.isEmpty
                                    ? Icons.notifications_off_outlined
                                    : Icons.search_off_outlined,
                                title: notificaciones.isEmpty
                                    ? l10n.noNotifications
                                    : 'No se encontraron notificaciones',
                                subtitle: notificaciones.isEmpty
                                    ? 'Cuando lleguen avisos los verás aquí con el mismo estilo del resto de la app.'
                                    : 'Prueba con otro filtro o limpia la búsqueda para ver más resultados.',
                                colorScheme: colorScheme,
                                textTheme: textTheme,
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (ctx, index) {
                            final notif = filtered[index];
                            return _NotificationCard(
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
                        ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      ),
      error: (err, st) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _NotificationsEmptyState(
            icon: Icons.error_outline,
            title: l10n.errorNotificationsLoading,
            subtitle: 'Vuelve a intentarlo en unos segundos.',
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ),
      ),
    );

    if (widget.embedded) {
      return content;
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
      body: content,
    );
  }
}

class _NotificationsHero extends StatelessWidget {
  final String title;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final String selectedEstado;
  final int unreadNotifications;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onEstadoChanged;

  const _NotificationsHero({
    required this.title,
    required this.colorScheme,
    required this.textTheme,
    required this.selectedEstado,
    required this.unreadNotifications,
    required this.onSearchChanged,
    required this.onEstadoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications_none_outlined,
                  color: colorScheme.primary,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$unreadNotifications sin leer',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          general_busqueda_textfield(
            AppLocalizations.of(context)!.search,
            icono: Icons.search,
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: Text(AppLocalizations.of(context)!.all),
                  selected: selectedEstado == 'todos',
                  onSelected: (_) => onEstadoChanged('todos'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(AppLocalizations.of(context)!.unread),
                  selected: selectedEstado == 'sin_leer',
                  onSelected: (_) => onEstadoChanged('sin_leer'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(AppLocalizations.of(context)!.read),
                  selected: selectedEstado == 'leida',
                  onSelected: (_) => onEstadoChanged('leida'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Notificacion notif;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations l10n;
  final VoidCallback onMarkAsRead;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const _NotificationCard({
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
    final estadoColor = notif.esSinLeer
        ? colorScheme.primary
        : notif.esArchivada
            ? colorScheme.outline
            : colorScheme.secondary;

    return Card(
      elevation: notif.esSinLeer ? 2 : 0,
      margin: EdgeInsets.zero,
      color: colorScheme.background.withValues(alpha: 0.26),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.background.withValues(alpha: 0.26),
              colorScheme.surface.withValues(alpha: 0.12),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(
                      notif.tipoIcono,
                      size: 21,
                      color: notif.esSinLeer
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.82),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif.estado.toUpperCase(),
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.58),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notif.tipoLegible,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notif.contenido,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.75),
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _StatusPill(
                              text: notif.estado,
                              backgroundColor:
                                  estadoColor.withValues(alpha: 0.16),
                              textColor: estadoColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (notif.esSinLeer)
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(left: 10, top: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(notif.createdAt),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'ID ${notif.id}',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.45),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (notif.esSinLeer)
                    TextButton.icon(
                      icon: const Icon(Icons.mark_email_read_outlined),
                      label: Text(l10n.read),
                      onPressed: onMarkAsRead,
                    ),
                  TextButton.icon(
                    icon: const Icon(Icons.archive_outlined),
                    label: Text(l10n.archived),
                    onPressed: onArchive,
                  ),
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
      ),
    );
  }

  String _formatDate(DateTime date) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year} · ${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const _StatusPill({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _NotificationsEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _NotificationsEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.65),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.65),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
