import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/llamadas_service.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/llamadas.dart';

// 1. Provider del servicio (ajusta la URL si es necesario)
final llamadasServiceProvider = Provider<LlamadasService>((ref) {
  return LlamadasService(baseUrl: 'http://cuidemjunts.zapto.org:3000');
});

// 2. Provider base que trae TODAS las llamadas
final llamadasProvider = FutureProvider<List<Llamadas>>((ref) async {
  final service = ref.watch(llamadasServiceProvider);
  return service.getAll();
});

// 3. Provider filtrado: Llamadas de HOY
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

// 4. Provider filtrado: Llamadas COMPLETADAS hoy
final completedCallsTodayProvider = Provider<AsyncValue<int>>((ref) {
  final callsToday = ref.watch(callsTodayProvider);
  return callsToday.whenData(
    (calls) =>
        calls.where((c) => c.estado == 'completada').length, // ← completada
  );
});

// 5. Provider filtrado: Llamadas PROGRAMADAS (pendientes) hoy
final scheduledCallsTodayProvider = Provider<AsyncValue<int>>((ref) {
  final callsToday = ref.watch(callsTodayProvider);
  return callsToday.whenData(
    (calls) =>
        calls.where((c) => c.estado == 'pendiente').length, // ← pendiente
  );
});

// 6. Provider filtrado: Actividad RECIENTE (últimas 5)
final recentCallsProvider = Provider<AsyncValue<List<Llamadas>>>((ref) {
  final llamadasAsync = ref.watch(llamadasProvider);
  return llamadasAsync.whenData((llamadas) {
    final sorted = List<Llamadas>.from(llamadas)
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    return sorted.take(5).toList();
  });
});
