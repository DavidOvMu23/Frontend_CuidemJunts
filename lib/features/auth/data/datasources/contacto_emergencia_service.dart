import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/dio_client.dart';
import '../models/usuario.dart';

// -------- CONTACTO EMERGENCIA SERVICE --------

// Este servicio se encarga de manejar las llamadas a la API relacionadas con los contactos de emergencia.
class ContactoEmergenciaService {
  final Dio _dio;

  ContactoEmergenciaService({required Dio dio}) : _dio = dio;

  // getAll maneja la llamada a la API para obtener todos los contactos de emergencia.
  Future<List<ContactoEmergencia>> getAll() async {
    final resp = await _dio.get('/contacto_emergencia');
    final List<dynamic> raw = resp.data as List<dynamic>;
    return raw
        .map((e) => ContactoEmergencia.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // create maneja la llamada a la API para crear un nuevo contacto de emergencia.
  Future<ContactoEmergencia> create(Map<String, dynamic> payload) async {
    final resp = await _dio.post('/contacto_emergencia', data: payload);
    final Map<String, dynamic> data = resp.data as Map<String, dynamic>;
    return ContactoEmergencia.fromJson(data);
  }

  // update maneja la llamada a la API para actualizar un contacto de emergencia.
  Future<ContactoEmergencia> update(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final resp = await _dio.patch('/contacto_emergencia/$id', data: payload);
    final Map<String, dynamic> data = resp.data as Map<String, dynamic>;
    return ContactoEmergencia.fromJson(data);
  }

  // delete maneja la llamada a la API para eliminar un contacto de emergencia.
  Future<void> delete(int id) async {
    await _dio.delete('/contacto_emergencia/$id');
  }
}

final contactoEmergenciaServiceProvider = Provider<ContactoEmergenciaService>((
  ref,
) {
  final dio = ref.watch(dioClientProvider);
  return ContactoEmergenciaService(dio: dio);
});
