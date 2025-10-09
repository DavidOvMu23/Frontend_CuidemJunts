import 'package:flutter/material.dart';

class ContainersDemo extends StatelessWidget {
  const ContainersDemo({super.key});

  // Método que muestra un AlertDialog, se declara fuera del build para
  // evitar tener que redeclararlo cada vez que se reconstruya el widget
  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: const Text('¿Deseas continuar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo: Containers')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // ListView para poder hacer scroll
        child: ListView(
          children: [
            // Card
            const Text(
              'Card',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Título de la tarjeta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Esto es una tarjeta simple con texto.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Divider
            const Text(
              'Divider',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text('Texto arriba del Divider'),
            const Divider(),
            const Text('Texto debajo del Divider'),
            const SizedBox(height: 24),

            // ListTile
            const Text(
              'ListTile',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            // Lista de alumnos
            const Column(
              children: [
                Card(
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text('David'),
                    subtitle: Text('Estudiante de DAM'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Daniel'),
                    subtitle: Text('Estudiante de DAM'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // AlertDialog
            const Text(
              'AlertDialog',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Center(
              child: FilledButton(
                onPressed: () => _showAlertDialog(context),
                child: const Text('Mostrar AlertDialog'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
