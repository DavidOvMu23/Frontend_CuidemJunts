import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_theme.dart';
import 'package:frontend_cuidemjunts/catalog/demos/buttons_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/text_fields_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/communications_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/containers_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/navigations_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/selections_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/typography_demo.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  // Variable para controlar si el modo oscuro está activado
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cuidem Junts',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      //Builder: nos da un nuevo "context" válido para Navigator.push(). Esto de aquí
      //lo he preguntado al chat para que así sea mucho mas sencillo llamar a el catalog
      //desde el main solo llamando al método. (perdona Pepe)
      home: Builder(
        builder: (context) {
          return Scaffold(
            // Barra superior con el título del catálogo
            appBar: AppBar(
              title: const Text('Catálogo de Demos'),

              // Añadimos el icono para cambiar entre modo claro y oscuro
              actions: [
                IconButton(
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () => setState(() => isDark = !isDark),
                ),
              ],
            ),

            //Creamos una lista de opciones para navegar en las difentes demos
            body: ListView(
              children: [
                //creamos las opciones del menú
                ListTile(
                  //ponemos un título a mostrar en esta opción y un icono de decoración para
                  //indicar que se debe de clicar ahí para acceder a las demos de esa opción
                  title: const Text('Buttons'),
                  trailing: const Icon(Icons.arrow_forward_ios),

                  //accion que realizaremos al clicar
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ButtonsDemo(),
                      ),
                    );
                  },
                ),
                //widget de divisor para separar las opciones del menú
                const Divider(height: 1),

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
                const Divider(height: 1),
              ],
            ),
          );
        },
      ),
    );
  }
}
