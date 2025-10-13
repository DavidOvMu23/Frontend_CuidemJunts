import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';

class NavigationsDemo extends StatelessWidget {
  const NavigationsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Demo: Navigations')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
            
          ],
        ),
      ),
    );
  }
}
