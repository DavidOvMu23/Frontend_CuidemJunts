import 'package:flutter/material.dart';

class TextFieldsDemo extends StatelessWidget {
  const TextFieldsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // La parte de arriba de la app (barra con el título)
      appBar: AppBar(title: const Text('Demo: Text Fields')),

      // El cuerpo principal de la pantalla
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        // Usamos material como surface(el fondo azul)
        child: Material(
          borderRadius: BorderRadius.circular(16), //Bordes redondeados

          child: Padding(
            padding: const EdgeInsets.all(16.0),

            //Column coloca los elementos uno debajo de otro
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // que se ajuste al contenido
              children: [
                // Textfield ejemplo nombre
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Nombre', // Texto de ayuda
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.person,
                    ), // Icono dentro del campo
                  ),
                ),
                const SizedBox(height: 12),

                // Textfield ejemplo contraseña
                TextField(
                  obscureText: true, // Oculta el texto (contraseña segura)
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none, // Sin línea blanca alrededor
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Textfield ejemplo búsqueda
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none, // Sin línea blanca alrededor
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Textfield multilínea
                TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 4, // Varias líneas
                  decoration: InputDecoration(
                    hintText: 'Mensaje',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none, // Sin línea blanca alrededor
                    ),
                  ),
                ),

                //Desplegable
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'Selecciona una opción',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'opcion1', child: Text('Opción 1')),
                    DropdownMenuItem(value: 'opcion2', child: Text('Opción 2')),
                    DropdownMenuItem(value: 'opcion3', child: Text('Opción 3')),
                  ],
                  onChanged: (value) {
                    // Manejar el cambio de selección
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
