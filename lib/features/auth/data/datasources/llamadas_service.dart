import '../models/llamadas.dart';
import 'package:dio/dio.dart';

// LlamadasService es la clase que maneja las llamadas a la API relacionadas con las llamadas.
class LlamadasService {
    // Crear una nueva llamada
    Future<Llamadas> create(Map<String, dynamic> payload) async {
        try {
        final resp = await _dio.post('/comunicacion', data: payload);
        return Llamadas.fromJson(resp.data as Map<String, dynamic>);
        } on DioError catch (e) {
          final respData = e.response?.data;
          throw Exception('Error creating comunicacion: ${respData ?? e.message}');
        }
    }

    // Editar una llamada existente
    Future<Llamadas> update(int id, Map<String, dynamic> payload) async {
        try {
        final resp = await _dio.patch('/comunicacion/$id', data: payload);
        return Llamadas.fromJson(resp.data as Map<String, dynamic>);
        } on DioError catch (e) {
          final respData = e.response?.data;
          throw Exception('Error updating comunicacion: ${respData ?? e.message}');
        }
    }

    // Eliminar una llamada
    Future<void> delete(int id) async {
      try {
        await _dio.delete('/comunicacion/$id');
      } on DioError catch (e) {
        final respData = e.response?.data;
        throw Exception('Error deleting comunicacion: ${respData ?? e.message}');
      }
    }
  final Dio _dio;

  // Constructor que recibe la URL base y un cliente HTTP.
  LlamadasService({required Dio dio}) : _dio = dio;

  // getAll maneja la llamada a la API para obtener todas las llamadas.
  Future<List<Llamadas>> getAll() async {
    final resp = await _dio.get('/comunicacion');
    print('RAW RESPONSE: ${resp.data}');
    final List<dynamic> raw = resp.data as List<dynamic>;
    return raw
        .map((e) => Llamadas.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
