import 'package:flutter/material.dart';

class TextFieldsDemo extends StatelessWidget {
  const TextFieldsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior de la aplicación con un título
      appBar: AppBar(title: const Text('Demo: Text Fields')),

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
            //Cuadrado de texto normal
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre', //Nombre
                //Pintaun borde rectangular alrededor del widget
                border: OutlineInputBorder(
                  //redondeado de las esquinas
                  borderRadius: BorderRadius.circular(12),
                ),
                //Pinta un icono en el cuadrado de texto
                prefixIcon: const Icon(Icons.person),
              ),
            ),

            //Cuadrado de texto normal (con texto oculto)
            TextField(
              obscureText: true, //hace que el texto escrito no sea visible
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),

            //Cuadrado de texto de búsqueda
            TextField(
              decoration: InputDecoration(
                labelText: 'Buscar',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),

            // Campo de texto multilínea
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: 4, //tamaño de líneas visibles
              decoration: InputDecoration(
                labelText: 'Mensaje',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                //hace que el texto quede alíneado y que no se centre
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
