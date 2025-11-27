import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/catalog/catalog_page.dart';
import 'package:frontend_cuidemjunts/catalog/widgets/widgets_communications_demo.dart';
import 'package:frontend_cuidemjunts/catalog/widgets/widgets_navigations_demo.dart';

// -------- DEMO: NAVEGACIÓN --------
// Muestra diferentes tipos de navegación

//Este enum define los elementos del drawer
enum DemoDrawerItem { home, calls, users, telemarketers, preferences }

// Esto es para que la pantalla sea un StatefulWidget es decir, que pueda tener estado
class NavigationsDemo extends StatefulWidget {
  const NavigationsDemo({super.key});

  @override
  State<NavigationsDemo> createState() => _NavigationsDemoState();
}

class _NavigationsDemoState extends State<NavigationsDemo> {
  // Variable en la que establecemos el elemento seleccionado del drawer
  DemoDrawerItem _selected = DemoDrawerItem.calls;

  @override
  Widget build(BuildContext context) {
    // Obtener los temas de texto y color actuales para usarlos en el diseño
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      // AppBar con el título del demo
      appBar: AppBar(
        title: Text(l10n.cuidemJunts),
        centerTitle: true,
        actions: [
          widget_badge_demo(
            10,
            Icons.notifications,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.notificationsPressed)),
              );
            },
          ),
        ],
      ),

      // Drawer (Menú lateral)
      drawer: Drawer(
        child: Column(
          children: [
            // Expanded para que el drawer ocupe todo el espacio disponible
            Expanded(
              // ListView para que el drawer sea scrollable, hay varias formas de hacer un contenido scrollable como SingleChildScrollView
              // pero yo estoy probando varias formas
              child: ListView(
                children: [
                  // Cabecera con logo
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
                                l10n.cuidemJunts,
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

                  // Divisor
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(color: colorScheme.primary.withOpacity(0.3)),
                  ),
                  const SizedBox(height: 10),

                  // Título de sección
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ).copyWith(top: 8),
                    child: Text(
                      "Supervisión",
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Opciones
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        //llamamos al widget personalizado widget_listtile_demo
                        widget_listtile_demo(
                          context: context,
                          icon: Icons.home,
                          texto: 'Inicio',
                          // comprobamos si es el elemento seleccionado, si lo es lo mostrará destacado
                          selected: _selected == DemoDrawerItem.home,
                        ),
                        widget_listtile_demo(
                          context: context,
                          icon: Icons.phone,
                          texto: 'Llamadas',
                          // comprobamos si es el elemento seleccionado, si lo es lo mostrará destacado
                          selected: _selected == DemoDrawerItem.calls,
                        ),
                        widget_listtile_demo(
                          context: context,
                          icon: Icons.people,
                          texto: 'Usuarios',
                          // comprobamos si es el elemento seleccionado, si lo es lo mostrará destacado
                          selected: _selected == DemoDrawerItem.users,
                        ),
                        widget_listtile_demo(
                          context: context,
                          icon: Icons.support_agent,
                          texto: 'Teleoperadores',
                          // comprobamos si es el elemento seleccionado, si lo es lo mostrará destacado
                          selected: _selected == DemoDrawerItem.telemarketers,
                        ),
                        widget_listtile_demo(
                          context: context,
                          icon: Icons.settings,
                          texto: 'Preferencias',
                          // comprobamos si es el elemento seleccionado, si lo es lo mostrará destacado
                          selected: _selected == DemoDrawerItem.preferences,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Perfil y Cerrar sesión
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
                      'Supervisor Name',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text("Supervisor", style: textTheme.bodyMedium),
                  ),
                  const SizedBox(height: 8),
                  widget_listtile_logout_demo(
                    context: context,
                    icon: Icons.logout,
                    texto: 'Cerrar sesión',
                    onTap: () async {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const CatalogPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
