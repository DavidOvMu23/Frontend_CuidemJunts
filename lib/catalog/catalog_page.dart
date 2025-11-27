import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/theme_provider.dart';
import 'package:frontend_cuidemjunts/catalog/demos/buttons_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/textfields_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/communications_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/containers_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/selections_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/typography_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/appbar_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/navigations_demo.dart';

// -------- WIDGET PRINCIPAL DE LA PÁGINA --------
// CatalogPage es un StatefulWidget porque su apariencia puede cambiar (modo claro/oscuro)
// y hace falta guardar ese estado.
// -------- WIDGET PRINCIPAL DE LA PÁGINA --------
// CatalogPage ahora usa Riverpod para sincronizar el tema con el resto de la app.
class CatalogPage extends ConsumerWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Leemos el estado actual del tema (true = oscuro, false = claro)
    // Usamos Theme.of(context) para saber si se está mostrando oscuro o claro,
    // independientemente de si es por sistema o manual.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // -------- BARRA SUPERIOR (APPBAR) --------
      appBar: AppBar(
        title: const Text('Catálogo de Demos'),
        // Botón que permite cambiar entre modo claro y oscuro globalmente
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),

      // -------- CUERPO PRINCIPAL --------
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        // -------- PANEL PRINCIPAL (SURFACE) --------
        child: Material(
          borderRadius: BorderRadius.circular(16),
          child: ListView(
            shrinkWrap: true,
            children: [
              // -------- DEMO: APPBAR--------
              ListTile(
                title: const Text('Appbar'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AppbarDemo()),
                  );
                },
              ),
              const Divider(height: 1),

              // -------- DEMO: BUTTONS --------
              ListTile(
                title: const Text('Buttons'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ButtonsDemo(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),

              // -------- DEMO: NAVIGATIONS --------
              ListTile(
                title: const Text('Navigations'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NavigationsDemo(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),

              // -------- DEMO: COMMUNICATIONS --------
              ListTile(
                title: const Text('Communications'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CommunicationsDemo(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),

              // -------- DEMO: CONTAINERS --------
              ListTile(
                title: const Text('Containers'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ContainersDemo(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),

              // -------- DEMO: SELECTIONS --------
              ListTile(
                title: const Text('Selections'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SelectionsDemo(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),

              // -------- DEMO: TEXT FIELDS --------
              ListTile(
                title: const Text('Text Fields'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TextFieldsDemo(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),

              // -------- DEMO: TYPOGRAPHY --------
              ListTile(
                title: const Text('Typography'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TypographyDemo(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
