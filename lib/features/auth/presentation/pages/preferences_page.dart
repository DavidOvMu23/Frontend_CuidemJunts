import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/general_widgets.dart';

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
          general_badge_demo(10, Icons.notifications, onPressed: () {}),
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
              general_listile_demo(
                icon: Icons.home,
                texto: "Menú Principal",
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
                  ListTile(
                    // Elimina el padding por defecto para ajustar mejor el diseño
                    contentPadding: EdgeInsets.zero,

                    // Título con icono que cambia según el tema
                    title: Row(
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
                              selectedLanguage =
                                  newValue!; //guardamos el nuevo idioma seleccionado
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
                  ),
                  //linea de configuracion de idioma
                  const SizedBox(height: 16),

                  //SwitchListTile para cambiar el tema
                  //la diferencia entre switchlisttile y switch es que
                  //switchlisttile hace que todo el tile sea clickeable
                  //y el switch solo el propio boton
                  SwitchListTile(
                    // Elimina el padding por defecto para ajustar mejor el diseño
                    contentPadding: EdgeInsets.zero,

                    // Título con icono que cambia según el tema
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Tema',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Icono que cambia según el tema
                        Icon(
                          // Muestra un icono diferente según el tema actual
                          Theme.of(context).brightness == Brightness.dark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                    // Valor del switch según el tema actual
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (value) => widget.onToggleTheme(value),
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
