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

// Provider que descarga del servidor TODAS las notificaciones del usuario logueado.
// Es un FutureProvider porque la petición al servidor tarda un momento.
// Solo carga las notificaciones del teleoperador que ha iniciado sesión.
final notificacionesProvider = FutureProvider<List<Notificacion>>((ref) async {
  final service = ref.watch(notificacionServiceProvider);
  // Obtenemos el ID del usuario logueado para filtrar sus notificaciones
  final userId = ref.watch(authProvider).id;
  // Pedimos al servidor las notificaciones de este teleoperador concreto
  return service.getAll(teleoperadorId: userId);
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
