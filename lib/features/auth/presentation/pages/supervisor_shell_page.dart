import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/calls_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/emergency_contacts_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/notifications_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';

class SupervisorShellPage extends ConsumerStatefulWidget {
  final DrawerItem initialSection;

  const SupervisorShellPage({
    super.key,
    this.initialSection = DrawerItem.home,
  });

  @override
  ConsumerState<SupervisorShellPage> createState() => _SupervisorShellPageState();
}

class _SupervisorShellPageState extends ConsumerState<SupervisorShellPage> {
  late DrawerItem _selectedSection;
  bool _compactSidebar = false;

  @override
  void initState() {
    super.initState();
    _selectedSection = widget.initialSection;
  }

  void _selectSection(DrawerItem item, {bool closeDrawer = false}) {
    if (closeDrawer && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    if (_selectedSection == item) return;

    setState(() {
      _selectedSection = item;
    });
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

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
      case DrawerItem.notifications:
        return l10n.notifications;
      case DrawerItem.preferences:
        return l10n.preferences;
    }
  }

  String _sectionSubtitle(AppLocalizations l10n) {
    switch (_selectedSection) {
      case DrawerItem.home:
        return l10n.supervison;
      case DrawerItem.calls:
        return l10n.superviseCalls;
      case DrawerItem.users:
        return l10n.manageUsers;
      case DrawerItem.emergencyContacts:
        return l10n.manageEmergencyContacts;
      case DrawerItem.telemarketers:
        return l10n.manageWorkers;
      case DrawerItem.notifications:
        return l10n.notificationsPressed;
      case DrawerItem.preferences:
        return l10n.appPreferences;
    }
  }

  List<_ShellNavigationEntry> _entries(AppLocalizations l10n) {
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
      _ShellNavigationEntry(
        item: DrawerItem.telemarketers,
        icon: Icons.support_agent_rounded,
        label: l10n.telemarketers,
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

  Widget _sectionWidget() {
    switch (_selectedSection) {
      case DrawerItem.home:
        return const HomeSupervisorPage(embedded: true);
      case DrawerItem.calls:
        return const LlamadasPage(embedded: true);
      case DrawerItem.users:
        return const UsersPage(embedded: true);
      case DrawerItem.emergencyContacts:
        return const EmergencyContactsPage(embedded: true);
      case DrawerItem.telemarketers:
        return const WorkersPage(embedded: true);
      case DrawerItem.notifications:
        return const NotificationsPage(embedded: true);
      case DrawerItem.preferences:
        return const PreferencesPage(embedded: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final unreadCountAsync = ref.watch(notificacionesSinLeerProvider);

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1080;
    final isTablet = width >= 720;

    final userName = authState.nombre;
    final userRole = authState.rol;

    if (userName == null) {
      return Scaffold(
        body: Center(child: Text(l10n.noAuthenticatedUser)),
      );
    }

    final unreadCount = unreadCountAsync.when(
      data: (count) => count,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Scaffold(
      drawerEnableOpenDragGesture: !isDesktop,
      drawer: isDesktop
          ? null
          : Drawer(
              width: isTablet ? 320 : width * 0.82,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
                  child: _ShellSidebar(
                    entries: _entries(l10n),
                    compact: false,
                    selectedSection: _selectedSection,
                    userName: userName,
                    userRole: userRole ?? '-',
                    onSectionTap: (item) =>
                        _selectSection(item, closeDrawer: true),
                    onLogoutTap: _logout,
                  ),
                ),
              ),
            ),
      body: Stack(
        children: [
          const _ShellBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 20 : 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop)
                    SizedBox(
                      width: _compactSidebar ? 90 : 278,
                      child: _ShellSidebar(
                        entries: _entries(l10n),
                        compact: _compactSidebar,
                        selectedSection: _selectedSection,
                        userName: userName,
                        userRole: userRole ?? '-',
                        onSectionTap: _selectSection,
                        onCompactToggle: () {
                          setState(() {
                            _compactSidebar = !_compactSidebar;
                          });
                        },
                        onLogoutTap: _logout,
                      ),
                    ),
                  if (isDesktop) const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      children: [
                        Builder(
                          builder: (context) {
                            return _ShellTopBar(
                              title: _sectionTitle(l10n),
                              subtitle: _sectionSubtitle(l10n),
                              showMenuButton: !isDesktop,
                              unreadCount: unreadCount,
                              userName: userName,
                              onMenuTap: () => Scaffold.of(context).openDrawer(),
                              onNotificationsTap: () =>
                                  _selectSection(DrawerItem.notifications),
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 280),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) {
                              final slide = Tween<Offset>(
                                begin: const Offset(0.06, 0),
                                end: Offset.zero,
                              ).animate(animation);
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: slide,
                                  child: child,
                                ),
                              );
                            },
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
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  isDesktop ? 30 : 24,
                                ),
                                child: _sectionWidget(),
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

class _ShellTopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showMenuButton;
  final int unreadCount;
  final String userName;
  final VoidCallback onMenuTap;
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
    final initials = userName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.substring(0, 1).toUpperCase())
        .join();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.surface.withOpacity(0.82),
            border: Border.all(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.20),
            ),
          ),
          child: Row(
            children: [
              if (showMenuButton)
                IconButton(
                  onPressed: onMenuTap,
                  icon: const Icon(Icons.menu_rounded),
                ),
              if (showMenuButton) const SizedBox(width: 8),
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

class _ShellSidebar extends StatelessWidget {
  final List<_ShellNavigationEntry> entries;
  final bool compact;
  final DrawerItem selectedSection;
  final String userName;
  final String userRole;
  final void Function(DrawerItem) onSectionTap;
  final VoidCallback? onCompactToggle;
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
          Padding(
            padding: EdgeInsets.fromLTRB(compact ? 4 : 10, 10, compact ? 4 : 10, 6),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/Logo_CuidemJunts.png',
                  height: compact ? 38 : 48,
                ),
                if (!compact) const SizedBox(width: 10),
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
          Divider(
            height: 1,
            color: colorScheme.secondary.withOpacity(0.30),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(4, 6, 4, 4),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _SidebarNavItem(
                  compact: compact,
                  label: entry.label,
                  icon: entry.icon,
                  selected: selectedSection == entry.item,
                  onTap: () => onSectionTap(entry.item),
                );
              },
            ),
          ),
          Divider(
            height: 1,
            color: colorScheme.primary.withOpacity(0.14),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(compact ? 4 : 8, 6, compact ? 4 : 8, 6),
            child: compact
                ? Column(
                    children: [
                      Tooltip(
                        message: '$userName ($userRole)',
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: colorScheme.primary,
                          child: const Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 8),
                      IconButton(
                        tooltip: l10n.logOut,
                        onPressed: onLogoutTap,
                        icon: const Icon(Icons.logout_rounded),
                      ),
                    ],
                  )
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
                            Text(
                              userName,
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              userRole,
                              style: textTheme.labelSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
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

class _SidebarNavItem extends StatefulWidget {
  final bool compact;
  final String label;
  final IconData icon;
  final bool selected;
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
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final colorScheme = Theme.of(context).colorScheme;

    final bgColor = widget.selected
      ? colorScheme.primary.withOpacity(0.22)
      : _hovered
        ? colorScheme.primary.withOpacity(0.12)
        : Colors.transparent;

    final fgColor = widget.selected
      ? colorScheme.onPrimary
      : colorScheme.onSurface.withOpacity(0.84);

    final item = AnimatedScale(
      duration: const Duration(milliseconds: 160),
      scale: _hovered ? 1.01 : 1,
      child: AnimatedContainer(
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
            border: Border.all(
            color: widget.selected
                ? colorScheme.primary.withOpacity(0.30)
                : Colors.transparent,
          ),
        ),
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
                        fontWeight:
                            widget.selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: Tooltip(
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

class _ShellNavigationEntry {
  final DrawerItem item;
  final IconData icon;
  final String label;

  const _ShellNavigationEntry({
    required this.item,
    required this.icon,
    required this.label,
  });
}