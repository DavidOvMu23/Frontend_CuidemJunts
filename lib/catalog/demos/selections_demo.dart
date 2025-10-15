import 'package:flutter/material.dart';

class SelectionsDemo extends StatefulWidget {
  const SelectionsDemo({super.key});

  @override
  State<SelectionsDemo> createState() => _SelectionsDemoState();
}

class _SelectionsDemoState extends State<SelectionsDemo> {
  // DECLARAR ESTADOS DE ELEMENTOS AL INICIO DEL PROGRAMA
  // Estado del Checkbox
  bool isChecked = false;
  // Estado del Switch
  bool isSwitched = false;
  // Estado del RadioButton
  String selectedOption = 'A';
  // Estado para el Chip seleccionado
  bool isChipSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior de la aplicación con un título
      appBar: AppBar(title: const Text('Demo: Selections')),

      body: Padding(
        // Padding: añade espacio alrededor del contenido
        padding: const EdgeInsets.all(16.0),

        // Column: organiza los widgets uno debajo del otro
        child: Column(
          // alinea contenido horizontalmente (inicio = izquierda), se lo he pedido al chat, por que si no se quedaba feo
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // checkbox
            Checkbox(
              value: isChecked, // valor actual del checkbox
              onChanged: (bool? value) {
                setState(() {
                  isChecked =
                      value ?? false; // actualiza el estado del checkbox
                });
              },
            ),

            // date picker
            FilledButton(
              child: const Text('Seleccionar fecha'),
              onPressed: () async {
                await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(), // fecha inicial (hoy)
                  firstDate: DateTime(2000), // límite inferior
                  lastDate: DateTime(2100), // límite superior
                );
              },
            ),
            const SizedBox(height: 16), // separar el widget
            // time picker
            FilledButton(
              child: const Text('Seleccionar hora'),
              onPressed: () async {
                // Mostrar el selector de hora sin guardar el resultado
                await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(), // hora actual por defecto
                );
              },
            ),
            const SizedBox(height: 16), // separar el widget
            // radio buttons
            RadioMenuButton<String>(
              value: 'A', // valor de esta opción
              groupValue: selectedOption, // valor actualmente seleccionado
              onChanged: (value) {
                setState(() {
                  selectedOption = value!; // actualiza la opción elegida
                });
              },
              child: const Text('Opción A'), // texto visible
            ),
            RadioMenuButton<String>(
              value: 'B', // valor de esta opción
              groupValue: selectedOption, // valor actualmente seleccionado
              onChanged: (value) {
                setState(() {
                  selectedOption = value!; // actualiza la opción elegida
                });
              },
              child: const Text('Opción B'), // texto visible
            ),
            const SizedBox(height: 16), // separar el widget
            // swicth
            Row(
              children: [
                Switch(
                  value: isSwitched, // valor actual del switch
                  onChanged: (value) {
                    setState(() {
                      isSwitched = value; // actualiza el estado del switch
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
