import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/catalog/widgets/widgets_textfields_demo.dart';

// -------- WIDGET PRINCIPAL --------
// Esta clase muestra ejemplos de distintos tipos de campos de texto (TextFields)
// y un menú desplegable (DropdownButtonFormField).
class TextFieldsDemo extends StatelessWidget {
  const TextFieldsDemo({super.key});

  // -------- CONSTRUCCIÓN DE LA INTERFAZ --------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // -------- BARRA SUPERIOR (APPBAR) --------
      // Muestra el título en la parte superior
      appBar: AppBar(title: const Text('Demo: Text Fields')),

      // -------- CUERPO PRINCIPAL --------
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        // -------- SURFACE PRINCIPAL --------
        // Fondo visual con bordes redondeados que contiene los campos de texto
        child: Material(
          borderRadius: BorderRadius.circular(16),

          child: Padding(
            padding: const EdgeInsets.all(16.0),

            // -------- COLUMNA DE CAMPOS --------
            // Coloca los campos uno debajo del otro
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize:
                  MainAxisSize.min, // Se ajusta al tamaño del contenido

              children: [
                // -------- TEXTFIELD: NOMBRE --------
                // Campo de texto simple con ícono de persona
                widget_textfield_demo("Nombre", false, icono: Icons.person),
                const SizedBox(height: 12),

                // -------- TEXTFIELD: CONTRASEÑA --------
                // Campo de texto que oculta los caracteres introducidos
                widget_textfield_demo("Contraseña", true, icono: Icons.person),
                const SizedBox(height: 12),

                // -------- TEXTFIELD: BÚSQUEDA --------
                // Campo con ícono de búsqueda y bordes redondeados tipo “pill”
                widget_textfield_demo(
                  "Buscar",
                  false,
                  icono: Icons.search,
                  borderRadius: 50,
                ),
                const SizedBox(height: 12),

                // -------- TEXTFIELD: MULTILÍNEA --------
                // Campo para escribir varias líneas de texto, como un mensaje
                widget_textfield_demo("Escribe aquí", false, maxLines: 4),
                const SizedBox(height: 12),

                // -------- DROPDOWN (MENÚ DESPLEGABLE) --------
                // Permite seleccionar una opción de una lista
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'Selecciona una opción',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),

                  // -------- OPCIONES DEL DESPLEGABLE --------
                  items: const [
                    DropdownMenuItem(value: 'opcion1', child: Text('Opción 1')),
                    DropdownMenuItem(value: 'opcion2', child: Text('Opción 2')),
                    DropdownMenuItem(value: 'opcion3', child: Text('Opción 3')),
                  ],

                  // Evento que se ejecuta cuando el usuario elige una opción
                  onChanged: (value) {
                    // Aquí podrías guardar o usar el valor seleccionado
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
