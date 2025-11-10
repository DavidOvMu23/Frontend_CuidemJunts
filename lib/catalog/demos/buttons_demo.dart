import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/catalog/widgets/widgets_buttons_demo.dart';

// -------- WIDGET PRINCIPAL --------
// Esta clase muestra ejemplos de diferentes tipos de botones en Flutter.
class ButtonsDemo extends StatelessWidget {
  const ButtonsDemo({super.key});

  // -------- CONSTRUCCIÓN DE LA INTERFAZ --------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // -------- BARRA SUPERIOR (APPBAR) --------
      // Muestra el título de la pantalla en la parte superior
      appBar: AppBar(title: const Text('Demo: Buttons')),

      // -------- CUERPO PRINCIPAL --------
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        //contenedor en el que meter los botones
        child: Material(
          borderRadius: BorderRadius.circular(16), // Bordes redondeados

          child: Padding(
            padding: const EdgeInsets.all(16.0),

            // -------- CONTENEDOR DE BOTONES --------
            // Wrap organiza los botones en filas y columnas automáticamente.
            // Si no caben en una fila, pasa a la siguiente.
            child: Wrap(
              spacing: 12, // Espacio horizontal entre botones
              runSpacing: 12, // Espacio vertical entre filas

              children: [
                // -------- FILLED BUTTON --------
                // Botón con fondo sólido (color principal)
                widget_filledbutton_demo('Filled Button', onPressed: () {}),

                // -------- FILLED TONAL BUTTON --------
                // Botón con fondo más suave, menos llamativo que el FilledButton
                widget_filledtonalbutton_demo('Filled Tonal', onPressed: () {}),

                // -------- TEXT BUTTON --------
                // Botón de solo texto, sin fondo ni borde
                widget_textbutton_demo("Text Button", onPressed: () {}),

                // -------- ICON BUTTON --------
                // Botón circular que muestra solo un ícono
                widget_iconbutton_demo(Icons.favorite, onPressed: () {}),

                // -------- FLOATING ACTION BUTTON --------
                // Botón flotante redondo, normalmente usado para acciones principales
                widget_floatingbutton_demo(Icons.add, onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
