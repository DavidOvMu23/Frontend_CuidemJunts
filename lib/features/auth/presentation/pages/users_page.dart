import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/supervisor/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

// -------- PANTALLA DE USUARIOS --------
// Pantalla donde los teleoperadores y supervisores buscan y gestionan usuarios.
class UsersPage extends StatefulWidget {
  // Callback que cambia el tema de la app.
  // Si es true, activa modo oscuro; si es false, modo claro.
  // Se utiliza para que el cambio de tema afecte a toda la app.
  final void Function(bool) onToggleTheme;

  // Callback que cambia el idioma de la app.
  // Se utiliza para que el cambio de idioma afecte a toda la app.
  final void Function(Locale) onChangeLocale;

  const UsersPage({
    super.key,
    required this.onToggleTheme,
    required this.onChangeLocale,
  });

  @override
  State<UsersPage> createState() => _UsersPageState();
}

// Filtros de usuarios (estable, independiente del idioma)
enum UserFilter { all, active, inactive, g1, g2, g3 }

class _UsersPageState extends State<UsersPage> {
  // Si se necesita ordenación en el futuro, se puede modelar igual con otro enum.

  late UserFilter filtroSeleccionado;

  @override
  void initState() {
    super.initState();
    filtroSeleccionado = UserFilter.all;
  }

  @override
  Widget build(BuildContext context) {
    // -------- TEMAS, COLORES Y TEXTOS --------
    // Obtenemos tipografías y paleta del tema actual para mantener
    // estilos consistentes en toda la app.
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Textos traducidos (según el idioma seleccionado en la app).
    final l10n = AppLocalizations.of(context)!;

    // -------- ESTRUCTURA DE LA PANTALLA --------
    return Scaffold(
      // -------- BARRA SUPERIOR --------
      // AppBar: barra superior con título centrado e iconos de acción a la derecha.
      appBar: appMainAppBar(
        onNotifications: () {
          // TODO: Acción al pulsar el icono de notificaciones.
        },
      ),

      // -------- MENÚ LATERAL (DRAWER) --------
      // Drawer: menú que se abre desde el lateral con opciones de navegación.
      drawer: appDrawer(
        context: context,
        selected: DrawerItem.users,
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
        onTapCalls: () {},
        onTapUsers: () {},
        onTapTelemarketers: () {},
        onTapPreferences: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PreferencesPage(
                onToggleTheme: widget.onToggleTheme,
                onChangeLocale: widget.onChangeLocale,
              ),
            ),
          );
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

      // -------- CONTENIDO PRINCIPAL --------
      body: SingleChildScrollView(
        // SingleChildScrollView permite que toda la columna sea scrolleable
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),

        // ConstrainedBox sirve para que la columna ocupe todo el ancho disponible
        child: ConstrainedBox(
          // Hacemos que la columna ocupe todo el ancho disponible.

          // Esto es necesario para que los elementos dentro de la columna
          // (como las "tarjetas" de Material) ocupen todo el ancho posible.
          constraints: const BoxConstraints(minWidth: double.infinity),

          // Columna principal con todo el contenido de la página.
          child: Column(
            // Alineamos todo a la izquierda.
            crossAxisAlignment: CrossAxisAlignment.start,

            // Elementos de la columna
            children: [
              // Título principal
              Text(
                l10n.users,
                style: textTheme.titleMedium?.copyWith(fontSize: 27),
              ),
              Text(l10n.manageUsers, style: textTheme.bodyMedium),
              const SizedBox(height: 20),

              Material(
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.searchUsers,
                        textAlign: TextAlign.left,
                        style: textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),

                      general_busqueda_textfield(
                        l10n.searchUser,
                        icono: Icons.search,
                      ),
                      const SizedBox(height: 20),
                      // Filtro de búsqueda
                      Row(
                        children: [
                          Icon(
                            filtroSeleccionado != UserFilter.all
                                ? Icons.filter_alt
                                : Icons.filter_alt_off,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<UserFilter>(
                              value: filtroSeleccionado,
                              icon: const Icon(Icons.arrow_drop_down),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: [
                                DropdownMenuItem<UserFilter>(
                                  value: UserFilter.all,
                                  child: Text(l10n.searchAllUsers),
                                ),
                                DropdownMenuItem<UserFilter>(
                                  value: UserFilter.active,
                                  child: Text(l10n.searchActiveUsers),
                                ),
                                DropdownMenuItem<UserFilter>(
                                  value: UserFilter.inactive,
                                  child: Text(l10n.searchInactiveUsers),
                                ),
                                DropdownMenuItem<UserFilter>(
                                  value: UserFilter.g1,
                                  child: Text(l10n.searchModerateDependency),
                                ),
                                DropdownMenuItem<UserFilter>(
                                  value: UserFilter.g2,
                                  child: Text(l10n.searchSevereDependency),
                                ),
                                DropdownMenuItem<UserFilter>(
                                  value: UserFilter.g3,
                                  child: Text(l10n.searchHighDependency),
                                ),
                              ],
                              onChanged: (UserFilter? newValue) {
                                setState(() {
                                  filtroSeleccionado =
                                      newValue ?? UserFilter.all;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Divider(color: colorScheme.primary.withOpacity(0.3)),
                      const SizedBox(height: 20),

                      // Lista de usuarios filtrados
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
