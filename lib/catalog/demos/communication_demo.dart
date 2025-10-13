import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';

class CommunicationsDemo extends StatelessWidget {
  const CommunicationsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Demo: Comunications')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Wrap(spacing: 12, runSpacing: 12, children: [
              
            ],
          ),
        ),
      ),
    );
  }
}
