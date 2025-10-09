import 'package:flutter/material.dart';

class CommunicationDemo extends StatelessWidget {
  const CommunicationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo: Communication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Badge',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),

            // Badge con un ícono
            Badge(
              label: const Text('3'),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications),
              ),
            ),

            const Text(
              'SnackBar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),

            // Botón para mostrar un SnackBar
            Center(
              child: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Este es un SnackBar')),
                  );
                },
                child: const Text('Mostrar SnackBar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
