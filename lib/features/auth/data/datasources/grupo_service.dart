import 'package:dio/dio.dart';
import '../models/grupo.dart';

// GrupoService es la clase que maneja las llamadas a la API relacionadas con los grupos.
class GrupoService {
  final Dio _dio;

  // Constructor que recibe el cliente Dio.
  GrupoService({required Dio dio}) : _dio = dio;

  // getById maneja la llamada a la API para obtener un grupo por su ID.
  Future<Grupo> getById(int id) async {
    final resp = await _dio.get('/grupo/$id');
    return Grupo.fromJson(resp.data as Map<String, dynamic>);
  }

  // findAll obtiene todos los grupos activos
  Future<List<Grupo>> findAll() async {
    final resp = await _dio.get('/grupo');
    final data = resp.data as List<dynamic>;
    return data.map((json) => Grupo.fromJson(json as Map<String, dynamic>)).toList();
  }
}
