import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/dio_client.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/llamadas_service.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/llamadas.dart';

// ----- Provider de LlamadasService -----
// Este archivo gestiona el estado de todas las llamadas del sistema:
// quién tiene llamadas hoy, cuáles están completadas, cuáles están pendientes, etc.

// Este provider crea UNA SOLA INSTANCIA de LlamadasService para toda la app.
// Sirve para que cualquier widget pueda acceder al servicio de llamadas
// sin tener que pasar el servicio manualmente de pantalla en pantalla.
final llamadasServiceProvider = Provider<LlamadasService>((ref) {
  // Obtenemos el cliente HTTP compartido de la app
  final dio = ref.watch(dioClientProvider);
  // Creamos el servicio de llamadas con el cliente HTTP
  return LlamadasService(dio: dio);
});

// Provider base que descarga TODAS las llamadas del servidor.
// Es un FutureProvider porque la operación es asíncrona (tarda un poco en cargar).
// Los demás providers de llamadas se construyen encima de este.
final llamadasProvider = FutureProvider<List<Llamadas>>((ref) async {
  final service = ref.watch(llamadasServiceProvider);
  // Pedimos al servidor todas las llamadas y esperamos la respuesta
  return service.getAll();
});

// Provider filtrado que devuelve solo las llamadas programadas para HOY.
// Se usa en el panel principal para mostrar cuántas llamadas hay en el día actual.
final callsTodayProvider = Provider<AsyncValue<List<Llamadas>>>((ref) {
  // Esperamos a que el provider base haya cargado los datos
  final llamadasAsync = ref.watch(llamadasProvider);
  return llamadasAsync.whenData((llamadas) {
    // Tomamos la fecha de hoy para comparar
    final now = DateTime.now();
    // Filtramos solo las llamadas cuyo día, mes y año coincidan con hoy
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

// Provider que cuenta cuántas llamadas de hoy ya han sido COMPLETADAS.
// Se muestra como estadística en el panel principal del supervisor.
final completedCallsTodayProvider = Provider<AsyncValue<int>>((ref) {
  final callsToday = ref.watch(callsTodayProvider);
  return callsToday.whenData(
    // Contamos solo las llamadas que tienen estado "completada"
    (calls) =>
        calls.where((c) => c.estado == CallStatus.completada).length, // ← completada
  );
});

// Provider que cuenta cuántas llamadas de hoy están todavía PENDIENTES.
// Ayuda al supervisor a saber cuánto trabajo queda por hacer en el día.
final scheduledCallsTodayProvider = Provider<AsyncValue<int>>((ref) {
  final callsToday = ref.watch(callsTodayProvider);
  return callsToday.whenData(
    // Contamos solo las llamadas que tienen estado "pendiente"
    (calls) =>
        calls.where((c) => c.estado == CallStatus.pendiente).length, // ← pendiente
  );
});

// Clase interna que guarda temporalmente qué llamada se quiere editar.
// Cuando el usuario toca "editar" en una llamada, guardamos aquí esa llamada
// para que el formulario de edición sepa qué datos tiene que mostrar.
class _PendingCallEditNotifier extends Notifier<Llamadas?> {
  // Estado inicial: ninguna llamada pendiente de editar
  @override
  Llamadas? build() => null;

  // Guarda la llamada que el usuario quiere editar (o null para limpiar)
  void set(Llamadas? call) => state = call;
}

// Provider que actúa de "puente" entre la lista de llamadas y el formulario de edición.
// Cuando se toca editar, se guarda la llamada aquí; el formulario la lee desde aquí.
final pendingCallEditProvider =
    NotifierProvider<_PendingCallEditNotifier, Llamadas?>(
        _PendingCallEditNotifier.new);
