import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notification_overlay_provider.dart';

// Widget que muestra las notificaciones emergentes en la esquina superior derecha.
// Las notificaciones aparecen apiladas y se gestionan a través del provider.
class NotificationOverlayWidget extends ConsumerWidget {
  const NotificationOverlayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el provider de notificaciones — cuando haya nuevas, se reconstruye el widget
    final notifications = ref.watch(notificationOverlayProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Si no hay notificaciones activas, no mostramos nada (widget de tamaño cero)
    if (notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Las notificaciones se colocan en la esquina superior derecha de la pantalla
        Positioned(
          top: 20,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            // Para cada notificación activa, pintamos una tarjeta
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

// Tarjeta visual de una notificación individual — muestra el icono del tipo,
// el título y el contenido del mensaje.
class _NotificationCard extends StatelessWidget {
  // El objeto notificación con los datos a mostrar
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
        // Limitamos el ancho para que no ocupe toda la pantalla
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline, width: 1),
          // Sombra suave para que destaque sobre el contenido de fondo
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
                  // Cuadrado con el icono del tipo de notificación
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      notificacion.tipoIcono,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Título legible del tipo de notificación (p. ej. "Nueva llamada")
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
              // Texto del contenido de la notificación, con un máximo de 3 líneas
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
