import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/widgets/loading_skeleton.dart';

// Tarjeta de estadística que muestra un contador con icono
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isLoading;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Texto con título y contador
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.left,
                    style: textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  isLoading
                      ? const AppSkeletonBox(width: 92, height: 38)
                      : Text(value, style: textTheme.displayMedium),
                ],
              ),
            ),

            // Icono a la derecha
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Icon(icon, color: colorScheme.primary, size: 60),
            ),
          ],
        ),
      ),
    );
  }
}
