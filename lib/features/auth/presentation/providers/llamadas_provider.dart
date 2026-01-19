import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/dio_client.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/llamadas_service.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/llamadas.dart';

// ----- Provider de LlamadasService -----

// Este provider crea UNA SOLA INSTANCIA de LlamadasService para toda la app.
// Sirve para que cualquier widget pueda acceder al servicio de llamadas sin tener que pasar el servicio manualmente por todos los widgets.
final llamadasServiceProvider = Provider<LlamadasService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return LlamadasService(dio: dio);
});

// Provider base que trae TODAS las llamadas
final llamadasProvider = FutureProvider<List<Llamadas>>((ref) async {
  final service = ref.watch(llamadasServiceProvider);
  return service.getAll();
});

// Provider filtrado: Llamadas de HOY
final callsTodayProvider = Provider<AsyncValue<List<Llamadas>>>((ref) {
  final llamadasAsync = ref.watch(llamadasProvider);
  return llamadasAsync.whenData((llamadas) {
    final now = DateTime.now();
    return llamadas
        .where(
          (l) =>
              l.fecha.year == now.year &&
              l.fecha.month == now.month &&
              l.fecha.day == now.day,
        )
        .toList();
  });
});

// Provider filtrado: Llamadas COMPLETADAS hoy
final completedCallsTodayProvider = Provider<AsyncValue<int>>((ref) {
  final callsToday = ref.watch(callsTodayProvider);
  return callsToday.whenData(
    (calls) =>
        calls.where((c) => c.estado == 'completada').length, // ← completada
  );
});

// Provider filtrado: Llamadas PROGRAMADAS (pendientes) hoy
final scheduledCallsTodayProvider = Provider<AsyncValue<int>>((ref) {
  final callsToday = ref.watch(callsTodayProvider);
  return callsToday.whenData(
    (calls) =>
        calls.where((c) => c.estado == 'pendiente').length, // ← pendiente
  );
});

// Provider filtrado: Actividad RECIENTE (últimas 5)
final recentCallsProvider = Provider<AsyncValue<List<Llamadas>>>((ref) {
  final llamadasAsync = ref.watch(llamadasProvider);
  return llamadasAsync.whenData((llamadas) {
    final sorted = List<Llamadas>.from(llamadas)
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    return sorted.take(5).toList();
  });
});
