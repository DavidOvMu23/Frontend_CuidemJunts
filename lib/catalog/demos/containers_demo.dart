import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/catalog/widgets/widgets_buttons_demo.dart';
import 'package:frontend_cuidemjunts/catalog/widgets/widgets_containers_demo.dart';

// -------- DEMO: CONTENEDORES --------
// Muestra diferentes tipos de contenedores
class ContainersDemo extends StatelessWidget {
  const ContainersDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      // AppBar con el título del demo
      appBar: AppBar(title: const Text('Demo: Containers')),

      // Padding para dar espacio al contenido
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        // Material sirve como el "fondo" principal de la pantalla, lo hice así por que así simulo
        // un panel principal sombre en el que estará el contenido y así hacer mas chula la app
        child: Material(
          borderRadius: BorderRadius.circular(16), // Bordes redondeados

          child: Padding(
            padding: const EdgeInsets.all(16.0),

            // Columna de contenido
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize:
                  MainAxisSize.min, // Se ajusta al tamaño del contenido

              children: [
                // Texto principal
                const Text(
                  'Soy una Surface (panel principal).',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Card
                // Una Card es un contenedor visual más oscuro que el fondo,
                const Card(
                  elevation: 0, // Sin sombra, no me gusta
                  child: SizedBox(
                    width: double.infinity, // Ocupa todo el ancho disponible
                    height: 100, // Altura fija
                    child: Center(
                      child: Text(
                        'Soy una Card (más oscura que la Surface).',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

                // Espacio entre la Card y el siguiente elemento
                const SizedBox(height: 20),

                // Botón que al pulsarlo muestra un AlertDialog (ventana emergente)
                widget_filledbutton_demo(
                  "Abrir AlertDialog",
                  onPressed: () {
                    showDialog(
                      context: context,

                      // Alert Dialog
                      builder: (context) => AlertDialog(
                        title: Text(l10n.dialogTitle),
                        content: const Text(
                          'Descripción o mensaje del diálogo.',
                        ),

                        // Botones del diálogo
                        actions: [
                          // Botón de cancelar
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l10n.cancel),
                          ),
                          // Botón de aceptar
                          FilledButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l10n.accept),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Botón que al pulsarlo muestra un BottomSheet (ventana emergente desde abajo)
                widget_filledbutton_demo(
                  "Abrir BottomPicker",
                  onPressed: () {
                    // Bottom Sheet
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            'Soy un BottomPicker (ventana emergente desde abajo).',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Lista simple (ListTile)
                // Ejemplo de elementos tipo lista con separadores.
                widget_listile_demo(
                  texto: "ListTile1",
                  icon: Icons.arrow_forward_ios,
                  onTap: () {},
                ),
                const Divider(), // Línea divisoria entre los elementos
                widget_listile_demo(
                  texto: "ListTile2",
                  icon: Icons.arrow_forward_ios,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
