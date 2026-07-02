// Librería principal de Flutter para construir la interfaz visual.
import 'package:flutter/material.dart';
// Constantes globales (puntos de ruptura de pantalla).
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';

// Riverpod: permite leer y escribir datos del estado global.
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Widgets reutilizables: appbar, drawer, botones…
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
// Enum DrawerItem: identifica cada sección del menú lateral.
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
// Sistema de traducciones de la app.
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
// Pantallas a las que se puede navegar desde el menú lateral.
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/calls_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/emergency_contacts_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/grupos_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/notifications_page.dart';
// Provider que gestiona el tema de la app (claro / oscuro).
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/theme_provider.dart';
// Provider que gestiona el idioma activo de la app.
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/locale_provider.dart';
// Provider con el estado del usuario autenticado.
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
// Provider con el contador de notificaciones sin leer.
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';

// -------- PANTALLA DE PREFERENCIAS --------
// Permite al usuario cambiar el idioma de la app y alternar entre tema claro y oscuro.
// Los cambios se aplican en tiempo real sin necesidad de reiniciar la app.
class PreferencesPage extends ConsumerStatefulWidget {
  // Si embedded es true, se muestra dentro del shell (sin AppBar ni Drawer propios).
  final bool embedded;

  const PreferencesPage({
    super.key,
    this.embedded = false,
  });

  @override
  ConsumerState<PreferencesPage> createState() => _PreferencesPageState();
}

// -------- ENUM: IDIOMAS DISPONIBLES --------
// Definimos los tres idiomas de la app como valores de un enum.
// Usamos un enum (en vez de strings) para que el compilador detecte errores
// si olvidamos manejar algún idioma en los switch.
enum AppLanguage { es, ca, en }

class _PreferencesPageState extends ConsumerState<PreferencesPage> {

  // -------- CONVERSIÓN: Locale → AppLanguage --------
  // Dado el Locale activo (el que Flutter usa para los textos), devolvemos
  // cuál de los tres idiomas del enum corresponde.
  // Por defecto (si el código no se reconoce) devolvemos español.
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

  // -------- CONVERSIÓN: AppLanguage → Locale --------
  // Dado un valor del enum, devolvemos el Locale que Flutter necesita
  // para cambiar el idioma de toda la app.
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

  // -------- CONSTRUCCIÓN DE LA PANTALLA --------
  @override
  Widget build(BuildContext context) {
    // Textos en el idioma activo del usuario.
    final l10n = AppLocalizations.of(context)!;
    // Estilos del tema activo (colores, fuentes…).
    final theme = Theme.of(context);
    // Estado del usuario autenticado.
    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
    final userRole = authState.rol;
    // Contador de notificaciones sin leer (para el badge de la campana).
    final notificacionesSinLeerAsync = ref.watch(notificacionesSinLeerProvider);

    // Si no hay usuario logueado, mostramos un aviso.
    if (userName == null) {
      return Scaffold(
        body: Center(child: Text(l10n.noAuthenticatedUser)),
      );
    }

    // -------- DETECCIÓN DE TAMAÑO DE PANTALLA --------
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppBreakpoints.desktop;
    final horizontalPadding = isDesktop ? 20.0 : 12.0;

    // -------- CUERPO DE LA PANTALLA --------
    // Contiene las opciones de idioma, tema y el botón del catálogo.
    final bodyContent = Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),

      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // -------- TARJETA DE OPCIONES --------
            // Material con bordes redondeados que agrupa los controles de preferencias.
            Material(
              borderRadius: BorderRadius.circular(30),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -------- SELECTOR DE IDIOMA --------
                    // ListTile con un DropdownButton a la derecha.
                    // El Dropdown muestra el idioma activo y permite cambiarlo.
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Etiqueta "Preferencia de idioma" a la izquierda.
                          Text(
                            l10n.lenguagePreferences,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          // Dropdown con los tres idiomas disponibles.
                          DropdownButton<AppLanguage>(
                            // Mostramos como seleccionado el idioma que coincide
                            // con el Locale que Flutter tiene activo actualmente.
                            value: _languageFromLocale(
                              Localizations.localeOf(context),
                            ),
                            borderRadius: BorderRadius.circular(12),
                            // Al elegir un idioma, lo convertimos a Locale y
                            // actualizamos el provider para que toda la app cambie.
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

                    // -------- INTERRUPTOR DE TEMA (CLARO / OSCURO) --------
                    // SwitchListTile muestra una fila con texto + icono + interruptor.
                    // Al activarlo, se cambia al modo oscuro; al desactivarlo, al modo claro.
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Etiqueta "Tema" a la izquierda.
                          Text(
                            l10n.theme,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Icono que cambia entre luna (oscuro) y sol (claro)
                          // según el brillo del tema activo.
                          Icon(
                            Theme.of(context).brightness == Brightness.dark
                                ? Icons.dark_mode_rounded   // Luna: modo oscuro activo.
                                : Icons.light_mode_rounded, // Sol: modo claro activo.
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                      // El interruptor está encendido si el tema actual es oscuro.
                      value: Theme.of(context).brightness == Brightness.dark,
                      // Al cambiar el interruptor, actualizamos el provider del tema.
                      // true = oscuro, false = claro.
                      onChanged: (value) =>
                          ref.read(themeProvider.notifier).setTheme(value),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // -------- MODO EMBEBIDO: solo el contenido, sin AppBar ni Drawer --------
    if (widget.embedded) {
      return bodyContent;
    }

    // -------- MODO INDEPENDIENTE: con su propio AppBar y Drawer --------
    return Scaffold(
      // -------- BARRA SUPERIOR CON CAMPANA DE NOTIFICACIONES --------
      appBar: appMainAppBar(
        numeroNotificaciones: notificacionesSinLeerAsync.when(
          data: (count) => count,
          loading: () => 0,
          error: (_, __) => 0,
        ),
        // Al pulsar la campana, navegamos a la pantalla de notificaciones.
        onNotifications: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsPage()),
          );
        },
        context: context,
      ),

      // -------- MENÚ LATERAL --------
      // Marcamos "Preferencias" como sección activa en el drawer.
      drawer: appDrawer(
        userName: userName,
        userRole: userRole,
        context: context,
        selected: DrawerItem.preferences,
        // Navegación a otras secciones desde el menú lateral.
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
        onTapGroups: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GruposPage()),
          );
        },
        onTapNotifications: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsPage()),
          );
        },
        // Cerrar sesión: limpia el estado global y navega al login.
        onLogoutConfirmed: () async {
          await ref.read(authProvider.notifier).logout();
          if (!context.mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
      ),

      // -------- CUERPO DE LA PANTALLA --------
      body: bodyContent,
    );
  }
}
