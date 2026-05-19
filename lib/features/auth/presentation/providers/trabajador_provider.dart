import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/dio_client.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/trabajador_service.dart';

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
