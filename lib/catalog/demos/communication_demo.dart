import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';

class CommunicationsDemo extends StatelessWidget {
  const CommunicationsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Demo: Communications')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Badge
            const Badge(label: Text('10'), child: Icon(Icons.notifications)),
            const SizedBox(height: 24),

            // Snackbar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor:
                    colorScheme.onPrimary, // texto e iconos visibles
                shape: const StadiumBorder(),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hola soy el snackbar!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Mostrar SnackBar'),
            ),
          ],
        ),
      ),
    );
  }
}
