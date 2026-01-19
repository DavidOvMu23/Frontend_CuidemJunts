import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';

// -------- DRAWER SUPERVISOR --------

// -------- ENUM DE SECCIONES DEL DRAWER --------
enum DrawerItem {
  home,
  calls,
  users,
  emergencyContacts,
  telemarketers,
  notifications,
  preferences,
}

// -------- WIDGET: DRAWER DEL SUPERVISOR --------
Drawer appDrawer({
  required BuildContext context,
  required DrawerItem selected,
  String? userName, // Nombre del usuario logueado
  String? userRole,
  VoidCallback? onTapHome,
  VoidCallback? onTapCalls,
  VoidCallback? onTapUsers,
  VoidCallback? onTapEmergencyContacts,
  VoidCallback? onTapTelemarketers,
  VoidCallback? onTapNotifications,
  VoidCallback? onTapPreferences,
  required VoidCallback? onLogoutConfirmed,
}) {
  final l10n = AppLocalizations.of(context)!;
  final textTheme = Theme.of(context).textTheme;
  final colorScheme = Theme.of(context).colorScheme;

  return Drawer(
    child: Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              // -------- CABECERA--------
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/Logo_CuidemJunts.png',
                      height: 74,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'CuidemJunts',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lluita contra la soletat\nen persones majors',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // -------- DIVISOR --------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Divider(color: colorScheme.primary.withOpacity(0.3)),
              ),
              const SizedBox(height: 10),
              // -------- SECCIÓN: TÍTULO --------
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ).copyWith(top: 8),
                child: Text(
                  l10n.supervison,
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // -------- OPCIONES --------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    general_listtile(
                      context: context,
                      icon: Icons.home,
                      texto: l10n.mainPage,
                      selected: selected == DrawerItem.home,
                      onTap: onTapHome,
                    ),
                    general_listtile(
                      context: context,
                      icon: Icons.phone,
                      texto: l10n.calls,
                      selected: selected == DrawerItem.calls,
                      onTap: onTapCalls,
                    ),
                    general_listtile(
                      context: context,
                      icon: Icons.people,
                      texto: l10n.users,
                      selected: selected == DrawerItem.users,
                      onTap: onTapUsers,
                    ),
                    general_listtile(
                      context: context,
                      icon: Icons.contact_emergency,
                      texto: l10n.emergencyContacts,
                      selected: selected == DrawerItem.emergencyContacts,
                      onTap: onTapEmergencyContacts,
                    ),
                    general_listtile(
                      context: context,
                      icon: Icons.support_agent,
                      texto: l10n.workers,
                      selected: selected == DrawerItem.telemarketers,
                      onTap: onTapTelemarketers,
                    ),
                    general_listtile(
                      context: context,
                      icon: Icons.notifications,
                      texto: l10n.notifications,
                      selected: selected == DrawerItem.notifications,
                      onTap: onTapNotifications,
                    ),
                    general_listtile(
                      context: context,
                      icon: Icons.settings,
                      texto: l10n.preferences,
                      selected: selected == DrawerItem.preferences,
                      onTap: onTapPreferences,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // -------- PIE DEL DRAWER: PERFIL + LOGOUT --------
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: colorScheme.surface,
                  foregroundColor: colorScheme.primary,
                  child: const Icon(Icons.person, size: 32),
                ),
                title: Text(
                  userName ??
                      'Usuario', // Muestra el nombre del usuario que ha iniciado sesión
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  userRole ?? 'Sin rol',
                  style: textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 8),
              general_listtile_logout(
                context: context,
                icon: Icons.logout,
                texto: l10n.logOut,
                onTap: () {
                  showConfirmDialog(
                    context,
                    title: l10n.logOut,
                    content: l10n.confirmLogOut,
                    confirmText: l10n.accept,
                    cancelText: l10n.cancel,
                    onConfirm: onLogoutConfirmed ?? () {},
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
