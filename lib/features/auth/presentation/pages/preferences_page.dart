import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/calls_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/emergency_contacts_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/notifications_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/theme_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/locale_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';
import 'package:frontend_cuidemjunts/catalog/catalog_page.dart';

// -------- PÁGINA DE PREFERENCIAS --------
// Configuración de idioma y tema sin salir de la app.
class PreferencesPage extends ConsumerStatefulWidget {
  final bool embedded;

  const PreferencesPage({
    super.key,
    this.embedded = false,
  });

  @override
  ConsumerState<PreferencesPage> createState() => _PreferencesPageState();
}

// Idiomas disponibles (valor estable, independiente de las traducciones)
enum AppLanguage { es, ca, en }

class _PreferencesPageState extends ConsumerState<PreferencesPage> {
  AppLanguage _languageFromLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'ca':
        return AppLanguage.ca;
      case 'en':
        return AppLanguage.en;
      case 'es':
      default:
        return AppLanguage.es;
    }
  }

  Locale _localeFromLanguage(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ca:
        return const Locale('ca');
      case AppLanguage.en:
        return const Locale('en');
      case AppLanguage.es:
        return const Locale('es');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
    final userRole = authState.rol;
    final notificacionesSinLeerAsync = ref.watch(notificacionesSinLeerProvider);

    // Si no hay usuario logueado, mostrar un mensaje
    if (userName == null) {
      return Scaffold(
        body: Center(child: Text(l10n.noAuthenticatedUser)),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final horizontalPadding = isDesktop ? 20.0 : 12.0;

    final bodyContent = Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),

      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Material(
              borderRadius: BorderRadius.circular(30),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -------- ZONA DE IDIOMA --------
                    // ListTile + Dropdown para cambiar el idioma de toda la app.
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.lenguagePreferences,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          DropdownButton<AppLanguage>(
                            value: _languageFromLocale(
                              Localizations.localeOf(context),
                            ),
                            borderRadius: BorderRadius.circular(12),
                            onChanged: (AppLanguage? newValue) {
                              if (newValue == null) return;
                              final locale = _localeFromLanguage(newValue);
                              ref
                                  .read(localeProvider.notifier)
                                  .setLocale(locale);
                            },
                            items: [
                              DropdownMenuItem<AppLanguage>(
                                value: AppLanguage.es,
                                child: Text(l10n.languageSpanish),
                              ),
                              DropdownMenuItem<AppLanguage>(
                                value: AppLanguage.ca,
                                child: Text(l10n.languageCatalan),
                              ),
                              DropdownMenuItem<AppLanguage>(
                                value: AppLanguage.en,
                                child: Text(l10n.languageEnglish),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // -------- ZONA DE TEMA --------
                    // SwitchListTile para activar/desactivar modo oscuro.
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            l10n.theme,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Theme.of(context).brightness == Brightness.dark
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                      value: Theme.of(context).brightness == Brightness.dark,
                      onChanged: (value) =>
                          ref.read(themeProvider.notifier).setTheme(value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: general_filledbutton(
                l10n.viewWidgetCatalog,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CatalogPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.embedded) {
      return bodyContent;
    }

    return Scaffold(
      // -------- APPBAR CON EL BOTÓN DE NOTIS --------
      appBar: appMainAppBar(
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

      // -------- MENÚ LATERAL --------
      drawer: appDrawer(
        userName: userName,
        userRole: userRole,
        context: context,
        selected: DrawerItem.preferences,
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
        onTapTelemarketers: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WorkersPage()),
          );
        },
        onTapNotifications: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsPage()),
          );
        },
        onLogoutConfirmed: () async {
          await ref.read(authProvider.notifier).logout();
          if (!context.mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
      ),

      // -------- CUERPO  --------
      body: bodyContent,
    );
  }
}
