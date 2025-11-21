import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/notificaciones_service.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/notificacion.dart';

// 1. Provider del servicio
final notificacionServiceProvider = Provider<NotificacionService>((ref) {
  return NotificacionService(baseUrl: 'http://cuidemjunts.zapto.org:3000');
});

// 2. Provider para obtener todas las notificaciones
final notificacionesProvider = FutureProvider<List<Notificacion>>((ref) async {
  final service = ref.watch(notificacionServiceProvider);
  return service.getAll();
});

// 3. Provider para contar notificaciones NO LEÍDAS
final notificacionesSinLeerProvider = Provider<AsyncValue<int>>((ref) {
  final notificacionesAsync = ref.watch(notificacionesProvider);
  return notificacionesAsync.whenData(
    (notificaciones) =>
        notificaciones.where((n) => n.estado == 'sin_leer').length,
  );
});
