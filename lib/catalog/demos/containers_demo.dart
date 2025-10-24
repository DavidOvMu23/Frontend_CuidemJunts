import 'package:flutter/material.dart';

// -------- WIDGET PRINCIPAL --------
// Esta clase muestra diferentes tipos de contenedores visuales en Flutter:
// Surface (Material), Card, AlertDialog y ListTile.
class ContainersDemo extends StatelessWidget {
  const ContainersDemo({super.key});

  // -------- CONSTRUCCIÓN DE LA INTERFAZ --------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // -------- BARRA SUPERIOR (APPBAR) --------
      // Muestra el título en la parte superior de la pantalla
      appBar: AppBar(title: const Text('Demo: Containers')),

      // -------- CUERPO PRINCIPAL --------
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        // -------- PANEL PRINCIPAL (SURFACE) --------
        // Este Material sirve como el "fondo" principal de la pantalla
        child: Material(
          borderRadius: BorderRadius.circular(16), // Bordes redondeados

          child: Padding(
            padding: const EdgeInsets.all(16.0),

            // -------- COLUMNA DE CONTENIDO --------
            // Coloca los elementos uno debajo del otro
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize:
                  MainAxisSize.min, // Se ajusta al tamaño del contenido

              children: [
                // -------- TEXTO PRINCIPAL --------
                const Text(
                  'Soy una Surface (panel principal).',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // -------- CARD --------
                // Una Card es un contenedor visual más oscuro que el fondo,
                // útil para agrupar información o destacar contenido.
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Bordes redondeados
                  ),
                  elevation: 0, // Sin sombra
                  child: const SizedBox(
                    width: double.infinity, // Ocupa todo el ancho disponible
                    height: 100, // Altura fija solo para el ejemplo
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

                // -------- BOTÓN: ABRIR DIÁLOGO --------
                // Botón que al pulsarlo muestra un AlertDialog (ventana emergente)
                FilledButton(
                  child: const Text('Abrir AlertDialog'),

                  // Al pulsar el botón se muestra el diálogo
                  onPressed: () {
                    showDialog(
                      context: context,

                      // -------- ALERT DIALOG --------
                      builder: (context) => AlertDialog(
                        title: const Text('Título del diálogo'),
                        content: const Text(
                          'Descripción o mensaje del diálogo.',
                        ),

                        // -------- BOTONES DEL DIÁLOGO --------
                        actions: [
                          // Botón de cancelar
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          // Botón de aceptar
                          FilledButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Aceptar'),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // -------- LISTA SIMPLE (LISTTILE) --------
                // Ejemplo de elementos tipo lista con separadores.
                const ListTile(
                  title: Text('ListTile1'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                const Divider(), // Línea divisoria entre los elementos
                const ListTile(
                  title: Text('ListTile2'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
