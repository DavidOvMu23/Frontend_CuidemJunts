import 'package:flutter/material.dart';

class ContainersDemo extends StatelessWidget {
  const ContainersDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior de la aplicación con un título
      appBar: AppBar(title: const Text('Demo: Containers')),
      body: Padding(
        // Padding: añade espacio alrededor de todo el contenido del body
        // En este caso, separa los botones de los bordes de la pantalla
        padding: const EdgeInsets.all(16.0),

        // Wrap: organiza los elementos uno al lado del otro
        // y los salta de línea automáticamente si no caben
        child: Wrap(
          spacing: 12, //Espacio horizontal entre los elementos
          runSpacing: 12, //Espacio vertical entre filas de elementos
          children: [
            //botón para mostrar el AlertDialog
            FilledButton(
              child: const Text('Abrir AlertDialog'), //texto del; botón
              onPressed: () {
                // Mostrar un diálogo al presionar el botón
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Título del diálogo'),
                      content: const Text('Descripción o mensaje del diálogo.'),
                      //creamos una serie de opciones a mostrar en el alert dialog, ej:
                      actions: [
                        // Botón para cancelar
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        // Botón para aceptar
                        FilledButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Aceptar'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            //card
            const Card(
              child: SizedBox(
                //tamaño caja
                width: 300,
                height: 100,
                child: Center(child: Text('Soy una card')),
              ),
            ),

            //ListTitle
            const ListTile(
              title: Text('ListTile1'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            const Divider(),
            const ListTile(
              title: Text('ListTile2'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ),
    );
  }
}
