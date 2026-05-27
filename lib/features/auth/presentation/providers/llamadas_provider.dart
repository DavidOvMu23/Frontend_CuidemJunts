import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/dio_client.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/llamadas_service.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/llamadas.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/grupo_provider.dart';

// Intervalo de polling al servidor para refrescar las listas en segundo plano.
// Compartido por todos los providers de lista para mantener una cadencia única.
const Duration kListPollInterval = Duration(seconds: 10);

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

// StreamProvider base que descarga TODAS las llamadas del servidor en tiempo real.
// Hace polling cada kListPollInterval para que cualquier widget que lo observe
// se reconstruya automáticamente cuando los datos del servidor cambian, sin
// necesidad de salir y volver a entrar en la pantalla.
final llamadasProvider = StreamProvider<List<Llamadas>>((ref) {
  final service = ref.watch(llamadasServiceProvider);
  // Sin sesión no hacemos polling: las peticiones devolverían 401 y, además,
  // bloquearían el pool de conexiones del navegador (compartido con el POST
  // de login), dejando el spinner de "Entrar" colgado tras un logout.
  final isAuthenticated = ref.watch(authProvider).isAuthenticated;
  final controller = StreamController<List<Llamadas>>();

  if (!isAuthenticated) {
    controller.add(const []);
    controller.close();
    return controller.stream;
  }

  Future<void> fetch() async {
    try {
      final fresh = await service.getAll();
      if (!controller.isClosed) controller.add(fresh);
    } catch (_) {
      // Errores transitorios de red: los silenciamos para no romper el stream.
    }
  }

  // Carga inicial inmediata + polling periódico.
  fetch();
  final timer = Timer.periodic(kListPollInterval, (_) => fetch());

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});

// Provider derivado que devuelve las llamadas con el nombre de su grupo
// rellenado a partir de la lista global de grupos. Se actualiza solo cuando
// cambian las llamadas o los grupos.
final llamadasConGrupoProvider = Provider<AsyncValue<List<Llamadas>>>((ref) {
  final llamadasAsync = ref.watch(llamadasProvider);
  final gruposAsync = ref.watch(gruposProvider);

  return llamadasAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
    data: (llamadas) => gruposAsync.when(
      // Si los grupos aún cargan, devolvemos las llamadas sin enriquecer en
      // lugar de bloquear la pantalla con un spinner.
      loading: () => AsyncValue.data(llamadas),
      error: (_, __) => AsyncValue.data(llamadas),
      data: (grupos) {
        final nombrePorId = {for (final g in grupos) g.id: g.nombre};
        final enriched = llamadas.map((l) {
          // Si la llamada ya trae el nombre del grupo, la dejamos tal cual.
          if (l.grupoNombre != null && l.grupoNombre!.isNotEmpty) return l;
          if (l.grupoId == 0) return l;
          final nombre = nombrePorId[l.grupoId];
          if (nombre == null) return l;
          return l.copyWith(grupoNombre: nombre);
        }).toList();
        return AsyncValue.data(enriched);
      },
    ),
  );
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
