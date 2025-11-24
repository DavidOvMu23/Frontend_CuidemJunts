import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/catalog/widgets/widgets_selecions_demo.dart';

// -------- WIDGET PRINCIPAL --------
// Esta clase muestra ejemplos de distintos elementos seleccionables:
// Checkbox, Switch, Radio Buttons y Selectores de Fecha/Hora.
class SelectionsDemo extends StatefulWidget {
  const SelectionsDemo({super.key});

  @override
  State<SelectionsDemo> createState() => _SelectionsDemoState();
}

// -------- ESTADO DEL WIDGET --------
// Aquí se guardan las variables que cambian según las selecciones del usuario.
class _SelectionsDemoState extends State<SelectionsDemo> {
  // -------- VARIABLES DE ESTADO --------
  bool isChecked = false; // Inicializa el valor del checkbox
  bool isSwitched = false; // Inicializa el valor del switch
  String selectedOption = 'A'; // Opción seleccionada en los radio buttons

  // -------- CONSTRUCCIÓN DE LA INTERFAZ --------
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      // -------- BARRA SUPERIOR (APPBAR) --------
      appBar: AppBar(title: const Text('Demo: Selections')),

      // -------- CUERPO PRINCIPAL --------
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        // -------- SURFACE PRINCIPAL --------
        // Contenedor con bordes redondeados que sirve como fondo visual
        child: Material(
          borderRadius: BorderRadius.circular(16),

          child: Padding(
            padding: const EdgeInsets.all(16.0),

            // -------- COLUMNA DE ELEMENTOS --------
            // Contiene todos los componentes seleccionables uno debajo del otro
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize:
                  MainAxisSize.min, // Se ajusta al tamaño del contenido

              children: [
                // -------- CHECKBOX --------
                // Permite activar o desactivar una opción
                widgetCheckboxTextoDemo(isChecked, "Activar checkbox", (
                  bool? value,
                ) {
                  setState(() {
                    isChecked = value ?? false;
                  });
                }),
                const SizedBox(height: 12),

                // -------- SWITCH --------
                // Interruptor de encendido/apagado
                widgetSwitchTextoDemo(isSwitched, "Encender/Apagar", (
                  bool value,
                ) {
                  setState(() {
                    isSwitched = value;
                  });
                }),
                const SizedBox(height: 12),

                // -------- RADIO BUTTONS --------
                // Solo se puede seleccionar una opción del grupo
                // Opción A
                RadioListTile<String>(
                  title: const Text('Opción A'),
                  value: 'A',
                  groupValue: selectedOption,
                  onChanged: (value) {
                    setState(() => selectedOption = value!);
                  },
                ),

                // Opción B
                RadioListTile<String>(
                  title: const Text('Opción B'),
                  value: 'B',
                  groupValue: selectedOption,
                  onChanged: (value) {
                    setState(() => selectedOption = value!);
                  },
                ),

                const SizedBox(height: 20),

                // -------- SELECTOR DE FECHA --------
                // Botón que abre un calendario para elegir una fecha
                FilledButton(
                  onPressed: () async {
                    await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                  },
                  child: Text(l10n.selectDate),
                ),

                const SizedBox(height: 12),

                // -------- SELECTOR DE HORA --------
                // Botón que abre un reloj para elegir una hora
                FilledButton(
                  onPressed: () async {
                    await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                  },
                  child: Text(l10n.selectTime),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
