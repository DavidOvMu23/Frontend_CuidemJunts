import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/dio_client.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/trabajador_service.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/trabajador.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/grupo_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/llamadas_provider.dart'
    show kListPollInterval;

// ----- Provider de TrabajadorService -----
// Este archivo gestiona el acceso al servicio de trabajadores.
// Los trabajadores son los teleoperadores que hacen las llamadas
// a las personas dependientes registradas en el sistema.

// Este provider crea UNA SOLA INSTANCIA de TrabajadorService para toda la app.
// Así cualquier widget puede pedir o modificar datos de trabajadores sin tener que
// crear el servicio por su cuenta ni preocuparse de duplicar conexiones al servidor.
final trabajadorServiceProvider = Provider<TrabajadorService>((ref) {
  // Obtenemos el cliente HTTP compartido de la app
  final dio = ref.watch(dioClientProvider);
  // Creamos el servicio de trabajadores pasándole el cliente HTTP
  return TrabajadorService(dio: dio);
});

// StreamProvider con la lista completa de trabajadores en tiempo real.
// Hace polling cada kListPollInterval para que las pantallas que muestran
// trabajadores se refresquen automáticamente al cambiar los datos en el servidor.
final trabajadoresProvider = StreamProvider<List<Trabajador>>((ref) {
  final service = ref.watch(trabajadorServiceProvider);
  final controller = StreamController<List<Trabajador>>();

  Future<void> fetch() async {
    try {
      final fresh = await service.getAll();
      if (!controller.isClosed) controller.add(fresh);
    } catch (_) {
      // Silenciamos errores transitorios de red para no romper el stream.
    }
  }

  fetch();
  final timer = Timer.periodic(kListPollInterval, (_) => fetch());

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});

// Provider derivado que devuelve los trabajadores con el nombre del grupo
// rellenado a partir de la lista global de grupos. Esto evita tener que hacer
// llamadas extra a /grupo/:id por cada teleoperador, y se actualiza solo
// cuando cambian las listas de trabajadores o grupos.
final trabajadoresConGrupoProvider =
    Provider<AsyncValue<List<Trabajador>>>((ref) {
  final trabajadoresAsync = ref.watch(trabajadoresProvider);
  final gruposAsync = ref.watch(gruposProvider);

  return trabajadoresAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
    data: (trabajadores) => gruposAsync.when(
      // Si los grupos aún están cargando, mostramos los trabajadores sin
      // enriquecer en lugar de bloquear toda la pantalla con un spinner.
      loading: () => AsyncValue.data(trabajadores),
      error: (_, __) => AsyncValue.data(trabajadores),
      data: (grupos) {
        final nombrePorId = {for (final g in grupos) g.id: g.nombre};
        final enriched = trabajadores.map((t) {
          // Solo enriquecemos teleoperadores con grupo asignado.
          final esTeleop = t.rol.toLowerCase() == AppRoles.teleoperador;
          if (!esTeleop || t.grupoId == null) return t;
          final nombre = nombrePorId[t.grupoId];
          if (nombre == null) return t;
          return t.copyWith(grupoNombre: nombre);
        }).toList();
        return AsyncValue.data(enriched);
      },
    ),
  );
});
