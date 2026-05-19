import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/dio_client.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/usuario_service.dart';

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
