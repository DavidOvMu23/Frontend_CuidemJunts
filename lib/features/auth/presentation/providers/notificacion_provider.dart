import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/notificaciones_service.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/notificacion.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/dio_client.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';

// ----- Provider de NotificacionesService -----
// Este archivo gestiona el estado de las notificaciones del teleoperador logueado.
// Las notificaciones avisan al teleoperador de eventos importantes (llamadas perdidas, etc.).

// Este provider crea UNA SOLA INSTANCIA de NotificacionService para toda la app.
// Sirve para que cualquier widget pueda acceder al servicio de notificaciones
// sin tener que crear el servicio por su cuenta ni pasar el cliente HTTP manualmente.
final notificacionServiceProvider = Provider<NotificacionService>((ref) {
  // Obtenemos el cliente HTTP compartido de la app
  final dio = ref.watch(dioClientProvider);
  // Creamos el servicio de notificaciones con ese cliente HTTP
  return NotificacionService(dio: dio);
});

// Intervalo de polling al servidor para refrescar las notificaciones en segundo plano.
const Duration _notificacionesPollInterval = Duration(seconds: 5);

// StreamProvider que mantiene la lista de notificaciones del usuario en tiempo real.
// Hace polling al servidor cada _notificacionesPollInterval y emite la lista
// actualizada, de modo que el badge y la página de notificaciones se reconstruyen
// automáticamente cuando llega algo nuevo (sin necesidad de salir y entrar).
final notificacionesProvider = StreamProvider<List<Notificacion>>((ref) {
  final service = ref.watch(notificacionServiceProvider);
  final userId = ref.watch(authProvider).id;

  final controller = StreamController<List<Notificacion>>();

  // Si no hay sesión, emitimos lista vacía y cerramos.
  if (userId == null || userId == 0) {
    controller.add(const []);
    controller.close();
    return controller.stream;
  }

  Future<void> fetch() async {
    try {
      final fresh = await service.getAll(teleoperadorId: userId, take: 100);
      if (!controller.isClosed) controller.add(fresh);
    } catch (_) {
      // Silenciamos errores transitorios de red para no romper el stream.
    }
  }

  // Carga inicial inmediata + polling periódico.
  fetch();
  final timer = Timer.periodic(_notificacionesPollInterval, (_) => fetch());

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});

// Provider que cuenta cuántas notificaciones NO han sido leídas aún.
// Se usa para mostrar el número rojo (badge) sobre el icono de notificaciones.
final notificacionesSinLeerProvider = Provider<AsyncValue<int>>((ref) {
  // Esperamos a que el provider base haya terminado de cargar las notificaciones
  final notificacionesAsync = ref.watch(notificacionesProvider);
  return notificacionesAsync.whenData(
    // Contamos las notificaciones cuyo estado es 'sin_leer'
    (notificaciones) =>
        notificaciones.where((n) => n.estado == 'sin_leer').length,
  );
});
