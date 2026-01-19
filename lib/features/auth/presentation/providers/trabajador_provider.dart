import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/dio_client.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/trabajador_service.dart';

final trabajadorServiceProvider = Provider<TrabajadorService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return TrabajadorService(dio: dio);
});
