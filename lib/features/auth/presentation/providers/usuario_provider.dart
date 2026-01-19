import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/dio_client.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/usuario_service.dart';

final usuarioServiceProvider = Provider<UsuarioService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return UsuarioService(dio: dio);
});
