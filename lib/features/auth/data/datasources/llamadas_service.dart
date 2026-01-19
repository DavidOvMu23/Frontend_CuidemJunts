import '../models/llamadas.dart';
import 'package:dio/dio.dart';

// LlamadasService es la clase que maneja las llamadas a la API relacionadas con las llamadas.
class LlamadasService {
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
