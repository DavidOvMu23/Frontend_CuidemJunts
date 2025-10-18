import 'package:flutter/material.dart';

class SelectionsDemo extends StatefulWidget {
  const SelectionsDemo({super.key});

  @override
  State<SelectionsDemo> createState() => _SelectionsDemoState();
}

class _SelectionsDemoState extends State<SelectionsDemo> {
  // Variables de estado de los elementos seleccionables
  bool isChecked = false; // Guarda si el checkbox está marcado
  bool isSwitched = false; // Guarda el valor del switch
  String selectedOption = 'A'; // Guarda la opción elegida (A o B)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior
      appBar: AppBar(title: const Text('Demo: Selections')),

      // Cuerpo principal
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        // Surface principal (fondo azul claro del tema)
        child: Material(
          borderRadius: BorderRadius.circular(16),

          child: Padding(
            padding: const EdgeInsets.all(16.0),

            // Columna con todos los elementos
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // se ajusta al contenido
              children: [
                // Checkbox
                Row(
                  // row para poner el checkbox y el texto en la misma línea
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (value) {
                        setState(() => isChecked = value ?? false);
                      },
                    ),
                    const Text('Activar opción'),
                  ],
                ),

                const SizedBox(height: 12),

                // switch
                Row(
                  // row para poner el switch y el texto en la misma línea
                  children: [
                    Switch(
                      value: isSwitched,
                      onChanged: (value) {
                        setState(() => isSwitched = value);
                      },
                    ),
                    const Text('Encender/Apagar'),
                  ],
                ),

                const SizedBox(height: 12),

                // radio buttons
                const Text('Selecciona una opción:'),
                const SizedBox(height: 8),

                //radiolisttiles para las opciones
                RadioListTile<String>(
                  title: const Text('Opción A'),
                  value: 'A',
                  groupValue: selectedOption,
                  onChanged: (value) {
                    setState(() => selectedOption = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Opción B'),
                  value: 'B',
                  groupValue: selectedOption,
                  onChanged: (value) {
                    setState(() => selectedOption = value!);
                  },
                ),
                const SizedBox(height: 20),

                // botón que abre el selector de fecha
                FilledButton(
                  onPressed: () async {
                    await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                  },
                  child: const Text('Seleccionar fecha'),
                ),

                const SizedBox(height: 12),

                // botón que abre el selector de hora
                FilledButton(
                  onPressed: () async {
                    await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                  },
                  child: const Text('Seleccionar hora'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
