import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/dio_client.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/grupo_service.dart';

final grupoServiceProvider = Provider<GrupoService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return GrupoService(dio: dio);
});
