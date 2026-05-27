import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/dio_client.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/grupo_service.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/grupo.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/llamadas_provider.dart'
    show kListPollInterval;

// ----- Provider de GrupoService -----
// Este archivo gestiona el acceso al servicio de grupos.
// Los grupos son conjuntos de teleoperadores que trabajan bajo un mismo supervisor.

// Este provider crea UNA SOLA INSTANCIA de GrupoService para toda la app.
// Así cualquier widget puede pedir datos de grupos sin tener que
// crear el servicio por su cuenta ni preocuparse de duplicar conexiones.
// Recibe el cliente HTTP (dio) para poder hacer peticiones al servidor.
final grupoServiceProvider = Provider<GrupoService>((ref) {
  // Obtenemos el cliente HTTP compartido de la app
  final dio = ref.watch(dioClientProvider);
  // Creamos el servicio de grupos pasándole el cliente HTTP
  return GrupoService(dio: dio);
});

// StreamProvider con la lista completa de grupos en tiempo real.
// Hace polling cada kListPollInterval para que las pantallas que muestran
// grupos se refresquen automáticamente al cambiar los datos en el servidor.
final gruposProvider = StreamProvider<List<Grupo>>((ref) {
  final service = ref.watch(grupoServiceProvider);
  // Sin sesión no polleamos para no bloquear el pool de conexiones del
  // navegador con peticiones 401 que el login tendría que esperar.
  final isAuthenticated = ref.watch(authProvider).isAuthenticated;
  final controller = StreamController<List<Grupo>>();

  if (!isAuthenticated) {
    controller.add(const []);
    controller.close();
    return controller.stream;
  }

  Future<void> fetch() async {
    try {
      final fresh = await service.findAll();
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
