import 'package:flutter/material.dart';

class TextFieldsDemo extends StatelessWidget {
  const TextFieldsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo: Text Fields')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        // ListView permite hacer scroll si hay muchos campos
        child: ListView(
          children: const [
            // Campo de texto normal
            TextField(
              decoration: InputDecoration(
                labelText: 'Campo normal',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Campo de texto con icono
            TextField(
              decoration: InputDecoration(
                labelText: 'Con icono',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Campo de texto tipo contraseña
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Campo de texto deshabilitado
            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Deshabilitado',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
