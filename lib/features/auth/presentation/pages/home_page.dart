import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  final void Function(bool) onToggleTheme;

  const HomePage({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Construye la interfaz de usuario
    return Scaffold(
      // AppBar con título y notificaciones
      appBar: AppBar(
        title: Text(l10n.appPreferences),
        centerTitle: true,
        actions: [
          //Notificaciones
          general_badge_demo(10, Icons.notifications, onPressed: () {}),
        ],
      ),

      // Menú lateral para navegar a Preferencias
      drawer: Drawer(
        // Lista de opciones en el menú lateral
        child: ListView(
          children: [
            const DrawerHeader(
              // Encabezado del menú lateral
              child: Text(
                'Cuidem Junts',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            // opción de preferencias
            general_listile_demo(
              icon: Icons.settings,
              texto: l10n.preferences,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PreferencesPage(onToggleTheme: onToggleTheme),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(child: Text(l10n.mainPage)),
    );
  }
}
