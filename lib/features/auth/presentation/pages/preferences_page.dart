import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_page.dart';

// Página de preferencias de la app
class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key, required this.onToggleTheme});
  // Callback para cambiar el tema
  final void Function(bool) onToggleTheme;

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

// Estado de la página de preferencias
class _PreferencesPageState extends State<PreferencesPage> {
  // Valor seleccionado del idioma
  String selectedLanguage = 'Español';

  // Lista de idiomas disponibles
  final List<String> languages = ['Español', 'Valencià', 'English'];

  @override
  Widget build(BuildContext context) {
    // Tema actual
    final theme = Theme.of(context);

    // Construye la interfaz de usuario
    return Scaffold(
      // AppBar con título y notificaciones
      appBar: AppBar(
        title: const Text('Preferencias de la app'),
        centerTitle: true,

        //Notificaciones
        actions: [
          Badge(
            label: const Text('10'),
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // TODO: Mostrar notificaciones de base de datos
              },
            ),
          ),
        ],
      ),

      // Menú lateral para navegar al Home
      drawer: Drawer(
        child: Material(
          //Lista de opciones del menú
          child: ListView(
            children: [
              const DrawerHeader(
                child: Text(
                  'Cuidem Junts',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              //Opcion para ir al Home
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Menú Principal'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HomePage(onToggleTheme: widget.onToggleTheme),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // Cuerpo de la página con las preferencias
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        //Sized box para ocupar todo el ancho
        child: SizedBox(
          width: double.infinity, // Ocupa todo el ancho disponible
          // Surface
          child: Material(
            borderRadius: BorderRadius.circular(16),

            // Contenido de las preferencias
            child: Padding(
              padding: const EdgeInsets.all(16.0),

              // Column con las opciones
              child: Column(
                //alineado de las opciones
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,

                // Opciones de preferencias
                children: [
                  //linea de configuracion de idioma
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Idioma de preferencia',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      // Dropdown para seleccionar idioma
                      DropdownButton<String>(
                        value: selectedLanguage,
                        borderRadius: BorderRadius.circular(12),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedLanguage = newValue!;
                          });
                        },
                        items: languages.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Linea de configuracion de tema
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tema',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      // Switch para cambiar tema
                      Switch(
                        value: Theme.of(context).brightness == Brightness.dark,
                        onChanged: (value) => widget.onToggleTheme(value),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
