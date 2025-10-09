import 'package:flutter/material.dart';

class TextFieldsDemo extends StatefulWidget {
  const TextFieldsDemo({super.key});

  @override
  State<TextFieldsDemo> createState() => _TextFieldsDemoState();
}

class _TextFieldsDemoState extends State<TextFieldsDemo> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo: Campos de texto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // TextField básico
            const Text('Normal', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // TextField con icono
            const Text(
              'Con icono',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // TextField tipo password
            const Text(
              'Password',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // TextField con validación
            const Text(
              'Con validación',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Introduce al menos 3 caracteres',
                border: const OutlineInputBorder(),
                errorText: _errorText,
              ),
              onChanged: (value) {
                setState(() {
                  _errorText = value.length < 3
                      ? 'Debe tener al menos 3 caracteres'
                      : null;
                });
              },
            ),
            const SizedBox(height: 24),

            // TextField deshabilitado
            const Text(
              'Deshabilitado',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Campo deshabilitado',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
