import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/general_widgets.dart';

class HomePage extends StatelessWidget {
  final void Function(bool) onToggleTheme;
  final void Function(Locale) onChangeLocale;

  const HomePage({
    super.key,
    required this.onToggleTheme,
    required this.onChangeLocale,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Construye la interfaz de usuario
    return Scaffold(
      // AppBar con título y notificaciones
      appBar: AppBar(
        title: const Text('Home Supervisor'),
        centerTitle: true,
        actions: [
          //Notificaciones
          general_badge_demo(10, Icons.notifications, onPressed: () {}),
        ],
      ),

      // Menú lateral para navegar a Preferencias
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(color: colorScheme.primary.withOpacity(0.3)),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ).copyWith(top: 8),
                    child: Text(
                      'Supervisión',
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        general_listile_demo(
                          context: context,
                          icon: Icons.home,
                          texto: 'Home',
                          selected: true,
                        ),
                        general_listile_demo(
                          context: context,
                          icon: Icons.phone,
                          texto: 'Llamadas',
                          onTap: () {},
                        ),
                        general_listile_demo(
                          context: context,
                          icon: Icons.people,
                          texto: 'Usuarios',
                          onTap: () {},
                        ),
                        general_listile_demo(
                          context: context,
                          icon: Icons.support_agent,
                          texto: ' Grupos y Teleoperadores',
                          onTap: () {},
                        ),
                        general_listile_demo(
                          context: context,
                          icon: Icons.settings,
                          texto: 'Preferencias',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PreferencesPage(
                                  onToggleTheme: onToggleTheme,
                                  onChangeLocale: onChangeLocale,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ).copyWith(top: 8),
                    child: Column(children: [Icon(Icons.person)]),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        ),
      ),
      body: const Center(child: Text('Página principal')),
    );
  }
}
