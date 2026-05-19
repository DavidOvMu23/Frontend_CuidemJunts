import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/notificacion.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/notificaciones_service.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/dio_client.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';

// ----- Provider del banner flotante de notificaciones -----
// Este archivo gestiona las notificaciones que aparecen brevemente en pantalla
// como un banner emergente (overlay) cuando llega una notificación nueva.
// Revisa el servidor cada 5 segundos y muestra cada notificación durante 5 segundos.

// Clase que agrupa una notificación con la hora a la que se empezó a mostrar.
// Se usa para saber cuándo fue visible y poder calcular cuándo ocultarla.
class DisplayNotification {
  // La notificación con todos sus datos (mensaje, tipo, etc.)
  final Notificacion notificacion;
  // Momento exacto en que se empezó a mostrar la notificación en pantalla
  final DateTime showTime;

  DisplayNotification({required this.notificacion, required this.showTime});
}

// Provider que mantiene la lista de notificaciones actualmente visibles en pantalla.
// Funciona como un "reloj" que comprueba notificaciones nuevas cada 5 segundos
// y las muestra como banners flotantes durante 5 segundos antes de quitarlas.
final notificationOverlayProvider = Provider<List<DisplayNotification>>((ref) {
  // Leemos el estado de autenticación para saber de qué usuario son las notificaciones
  final authState = ref.watch(authProvider);
  final dio = ref.watch(dioClientProvider);

  // Si no hay usuario logueado, no hay notificaciones que mostrar
  if (authState.id == null || authState.id == 0) {
    return [];
  }

  // Lista de notificaciones actualmente visibles en el banner
  final notifications = <DisplayNotification>[];
  // Creamos el servicio de notificaciones para consultar el servidor
  final service = NotificacionService(dio: dio);
  // Referencia al temporizador para poder cancelarlo cuando el provider se destruya
  Timer? timer;

  // Configuramos un temporizador que se repite cada 5 segundos
  // para consultar si hay notificaciones nuevas sin leer
  timer = Timer.periodic(const Duration(seconds: 5), (t) async {
    try {
      // Preguntamos al servidor las notificaciones sin leer de este teleoperador
      final nuevas = await service.getSinLeer(
        teleoperadorId: authState.id!,
        take: 100,
      );

      // Recorremos cada notificación nueva que llegó del servidor
      for (final notif in nuevas) {
        // Comprobamos si esta notificación ya la estamos mostrando
        // para no mostrar la misma dos veces
        final existe = notifications.any((x) => x.notificacion.id == notif.id);
        if (!existe) {
          // Añadimos la notificación a la lista de visibles con la hora actual
          notifications.add(
            DisplayNotification(notificacion: notif, showTime: DateTime.now()),
          );

          // Programamos que esta notificación desaparezca después de 5 segundos
          Future.delayed(const Duration(seconds: 5), () {
            notifications.removeWhere((n) => n.notificacion.id == notif.id);
          });
        }
      }
    } catch (e) {
      // Si falla la petición al servidor, lo mostramos en consola para depurar
      // pero no mostramos error al usuario para no interrumpir su trabajo
      debugPrint('Overlay polling error: $e');
    }
  });

  // Cuando el provider se destruye (usuario cierra sesión o sale de la app),
  // cancelamos el temporizador para no seguir haciendo peticiones al servidor
  // y limpiamos la lista de notificaciones visibles
  ref.onDispose(() {
    timer?.cancel();
    notifications.clear();
  });

  // Devolvemos la lista actual de notificaciones visibles
  return notifications;
});
