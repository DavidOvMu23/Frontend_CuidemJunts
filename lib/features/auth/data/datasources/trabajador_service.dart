import 'package:dio/dio.dart';
import '../models/trabajador.dart';

// -------- TRABAJADOR SERVICE --------

// Este servicio se encarga de manejar las llamadas a la API relacionadas con los trabajadores.
class TrabajadorService {
  final Dio _dio;

  // Constructor que recibe el cliente Dio.
  TrabajadorService({required Dio dio}) : _dio = dio;

  // getAll maneja la llamada a la API para obtener todos los trabajadores.
  Future<List<Trabajador>> getAll() async {
    final resp = await _dio.get('/trabajador');
    final List<dynamic> raw = resp.data as List<dynamic>;
    return raw
        .map((e) => Trabajador.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // create maneja la llamada a la API para crear un nuevo trabajador.
  Future<Trabajador> create(Map<String, dynamic> payload) async {
    final resp = await _dio.post('/trabajador', data: payload);
    return Trabajador.fromJson(resp.data as Map<String, dynamic>);
  }
}
