import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/notificacion.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/notifications_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notification_overlay_provider.dart';

// Widget que pinta los popups de notificación flotantes en la esquina superior
// derecha. Cada popup entra con animación, muestra título + contenido + tipo,
// se cierra solo a los 5s (lo gestiona el provider) y también se puede
// cerrar manualmente con la "X" o pulsando en él para ir a notificaciones.
class NotificationOverlayWidget extends ConsumerWidget {
  const NotificationOverlayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationOverlayProvider);

    if (notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    // Posicionamos los banners en la esquina superior derecha. Usamos
    // SafeArea para respetar la barra superior del navegador o el sistema.
    return Positioned(
      top: 16,
      right: 16,
      child: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            // Cada notificación tiene su propio key para que la animación de
            // entrada/salida se respete aunque se reordene la lista.
            children: [
              for (final overlay in notifications)
                _AnimatedNotificationCard(
                  key: ValueKey('notif-overlay-${overlay.notificacion.id}'),
                  notificacion: overlay.notificacion,
                  onDismiss: () => ref
                      .read(notificationOverlayProvider.notifier)
                      .dismiss(overlay.notificacion.id),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Tarjeta individual con animación de entrada (slide desde la derecha + fade).
// Cuando se desmonta, Flutter quita el widget instantáneamente; la salida
// suave la conseguimos no animando el desmontaje (el efecto de "deslizar al
// quitar" requeriría AnimatedSwitcher, lo dejamos así por simplicidad).
class _AnimatedNotificationCard extends StatefulWidget {
  final Notificacion notificacion;
  final VoidCallback onDismiss;

  const _AnimatedNotificationCard({
    super.key,
    required this.notificacion,
    required this.onDismiss,
  });

  @override
  State<_AnimatedNotificationCard> createState() =>
      _AnimatedNotificationCardState();
}

class _AnimatedNotificationCardState extends State<_AnimatedNotificationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    // Entra deslizándose desde la derecha (10% de su ancho).
    _slide = Tween<Offset>(
      begin: const Offset(0.25, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: _NotificationCard(
            notificacion: widget.notificacion,
            onDismiss: widget.onDismiss,
          ),
        ),
      ),
    );
  }
}

// Estructura visual del popup. Material + tap → abrir pantalla de notificaciones.
class _NotificationCard extends StatelessWidget {
  final Notificacion notificacion;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notificacion,
    required this.onDismiss,
  });

  // Devuelve el color base asociado a cada tipo de notificación. Se usa para
  // teñir el icono y la chip del tipo para distinguirlas de un vistazo.
  Color _colorPorTipo(ColorScheme colorScheme) {
    switch (notificacion.tipo) {
      case 'call':
        return Colors.green.shade400;
      case 'supervision':
        return colorScheme.primary;
      case 'system':
        return Colors.orange.shade400;
      default:
        return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final tipoColor = _colorPorTipo(colorScheme);
    final titulo = (notificacion.titulo ?? '').trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // Cerramos el popup y abrimos la pantalla de notificaciones para
          // que el usuario pueda verla con más detalle.
          onDismiss();
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (_) => const NotificationsPage()),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono coloreado según el tipo.
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: tipoColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(notificacion.tipoIcono,
                    size: 22, color: tipoColor),
              ),
              const SizedBox(width: 12),
              // Cuerpo: chip de tipo + título + contenido.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Chip pequeña con el tipo legible (Llamada / Sistema /
                    // Supervisión) — sirve para identificar el origen.
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: tipoColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        notificacion.tipoLegible(l10n).toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: tipoColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (titulo.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      notificacion.contenido,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.75),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Botón de cerrar manual.
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  tooltip: l10n.close,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
