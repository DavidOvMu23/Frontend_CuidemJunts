import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/notificaciones_service.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/notificacion.dart';
// ----- Provider de NotificacionesService -----

// Este provider crea UNA SOLA INSTANCIA de NotificacionesService para toda la app.
// Sirve para que cualquier widget pueda acceder al servicio de notificaciones sin tener que pasar el servicio manualmente por todos los widgets.
final notificacionServiceProvider = Provider<NotificacionService>((ref) {
  return NotificacionService(baseUrl: 'http://localhost:3000');
});

// Provider para obtener todas las notificaciones
final notificacionesProvider = FutureProvider<List<Notificacion>>((ref) async {
  final service = ref.watch(notificacionServiceProvider);
  return service.getAll();
});

// Provider para contar notificaciones NO LEÍDAS
final notificacionesSinLeerProvider = Provider<AsyncValue<int>>((ref) {
  final notificacionesAsync = ref.watch(notificacionesProvider);
  return notificacionesAsync.whenData(
    (notificaciones) =>
        notificaciones.where((n) => n.estado == 'sin_leer').length,
  );
});
