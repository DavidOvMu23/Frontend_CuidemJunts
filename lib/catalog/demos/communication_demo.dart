import 'package:flutter/material.dart';

class CommunicationDemo extends StatelessWidget {
  const CommunicationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo: Comunicación')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BADGE SECTION
            const Text(
              'Badges',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 16,
              children: [
                // Badge simple
                Badge(
                  label: const Text('3'),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // SNACKBAR SECTION
            const Text(
              'SnackBars',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),

            Center(
              child: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Este es un SnackBar de ejemplo'),
                      action: SnackBarAction(label: 'Cerrar', onPressed: () {}),
                    ),
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
