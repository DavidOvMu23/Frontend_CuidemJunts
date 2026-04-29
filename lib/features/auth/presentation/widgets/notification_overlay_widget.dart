import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notification_overlay_provider.dart';

class NotificationOverlayWidget extends ConsumerWidget {
  const NotificationOverlayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationOverlayProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        Positioned(
          top: 20,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: notifications.map((overlay) {
              final notif = overlay.notificacion;
              return _NotificationCard(
                notificacion: notif,
                colorScheme: colorScheme,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final dynamic notificacion;
  final ColorScheme colorScheme;

  const _NotificationCard({
    required this.notificacion,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    notificacion.tipoIcono,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      notificacion.tipoLegible,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notificacion.contenido,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
