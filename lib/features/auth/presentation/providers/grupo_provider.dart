import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/dio_client.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/grupo_service.dart';

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
