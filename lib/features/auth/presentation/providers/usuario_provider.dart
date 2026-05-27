import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/dio_client.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/usuario_service.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/llamadas_provider.dart'
    show kListPollInterval;

// ----- Provider de UsuarioService -----
// Este archivo gestiona el acceso al servicio de usuarios.
// Los usuarios son las personas dependientes que reciben las llamadas
// de seguimiento por parte de los teleoperadores.

// Este provider crea UNA SOLA INSTANCIA de UsuarioService para toda la app.
// Así cualquier widget puede pedir o modificar datos de usuarios sin tener que
// crear el servicio por su cuenta ni duplicar conexiones al servidor.
final usuarioServiceProvider = Provider<UsuarioService>((ref) {
  // Obtenemos el cliente HTTP compartido de la app
  final dio = ref.watch(dioClientProvider);
  // Creamos el servicio de usuarios pasándole el cliente HTTP
  return UsuarioService(dio: dio);
});

// StreamProvider con la lista completa de usuarios en tiempo real.
// Hace polling cada kListPollInterval; cualquier pantalla que observe este
// provider se redibuja automáticamente cuando cambian los datos en el servidor.
final usuariosProvider = StreamProvider<List<Usuario>>((ref) {
  final service = ref.watch(usuarioServiceProvider);
  // Sin sesión no polleamos para no bloquear el pool de conexiones del
  // navegador con peticiones 401 que el login tendría que esperar.
  final isAuthenticated = ref.watch(authProvider).isAuthenticated;
  final controller = StreamController<List<Usuario>>();

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
