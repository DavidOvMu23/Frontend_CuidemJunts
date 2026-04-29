import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/notificacion.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/notificaciones_service.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/dio_client.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';

class DisplayNotification {
  final Notificacion notificacion;
  final DateTime showTime;

  DisplayNotification({required this.notificacion, required this.showTime});
}

final notificationOverlayProvider = Provider<List<DisplayNotification>>((ref) {
  final authState = ref.watch(authProvider);
  final dio = ref.watch(dioClientProvider);

  if (authState.id == null || authState.id == 0) {
    return [];
  }

  final notifications = <DisplayNotification>[];
  final service = NotificacionService(dio: dio);
  Timer? timer;

  timer = Timer.periodic(const Duration(seconds: 5), (t) async {
    try {
      final nuevas = await service.getSinLeer(
        teleoperadorId: authState.id!,
        take: 100,
      );

      // Solo mostrar una vez cada notificación
      for (final notif in nuevas) {
        final existe = notifications.any((x) => x.notificacion.id == notif.id);
        if (!existe) {
          notifications.add(
            DisplayNotification(notificacion: notif, showTime: DateTime.now()),
          );

          // Auto-remover después de 5 segundos
          Future.delayed(const Duration(seconds: 5), () {
            notifications.removeWhere((n) => n.notificacion.id == notif.id);
          });
        }
      }
    } catch (e) {
      debugPrint('Overlay polling error: $e');
    }
  });

  ref.onDispose(() {
    timer?.cancel();
    notifications.clear();
  });

  return notifications;
});
