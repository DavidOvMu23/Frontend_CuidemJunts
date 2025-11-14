import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/supervisor/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/llamadas_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';

// -------- PÁGINA DE PREFERENCIAS --------
// Configuración de idioma y tema sin salir de la app.
class PreferencesPage extends StatefulWidget {
  const PreferencesPage({
    super.key,
    required this.onToggleTheme,
    required this.onChangeLocale,
  });

  // Callback que cambia el tema de la app.
  // Si es true, activa modo oscuro; si es false, modo claro.
  // Se utiliza para que el cambio de tema afecte a toda la app.
  final void Function(bool) onToggleTheme;

  // Callback que cambia el idioma de la app.
  // Se utiliza para que el cambio de idioma afecte a toda la app.
  final void Function(Locale) onChangeLocale;

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

// Idiomas disponibles (valor estable, independiente de las traducciones)
enum AppLanguage { es, ca, en }

class _PreferencesPageState extends State<PreferencesPage> {
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

    return Scaffold(
      // -------- APPBAR CON EL BOTÓN DE NOTIS --------
      appBar: appMainAppBar(onNotifications: () {}),

      // -------- MENÚ LATERAL --------
      drawer: appDrawer(
        context: context,
        selected: DrawerItem.preferences,
        onTapHome: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeSupervisorPage(
                onToggleTheme: widget.onToggleTheme,
                onChangeLocale: widget.onChangeLocale,
              ),
            ),
          );
        },
        onTapCalls: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LlamadasPage(
                onToggleTheme: widget.onToggleTheme,
                onChangeLocale: widget.onChangeLocale,
              ),
            ),
          );
        },
        onTapUsers: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UsersPage(
                onToggleTheme: widget.onToggleTheme,
                onChangeLocale: widget.onChangeLocale,
              ),
            ),
          );
        },
        onTapTelemarketers: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkersPage(
                onToggleTheme: widget.onToggleTheme,
                onChangeLocale: widget.onChangeLocale,
              ),
            ),
          );
        },
        onTapNotifications: () {
          //TODO: Navegar a la página de notificaciones
        },
        onLogoutConfirmed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(
                onToggleTheme: widget.onToggleTheme,
                onChangeLocale: widget.onChangeLocale,
              ),
            ),
          );
        },
      ),

      // -------- CUERPO  --------
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),

        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.preferences,
                style: textTheme.titleMedium?.copyWith(fontSize: 27),
              ),

              const SizedBox(height: 10),
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
                                widget.onChangeLocale(
                                  _localeFromLanguage(newValue),
                                );
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
                        onChanged: (value) => widget.onToggleTheme(value),
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
