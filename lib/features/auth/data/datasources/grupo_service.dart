import 'package:dio/dio.dart';
import '../models/grupo.dart';

class GrupoService {
  final Dio _dio;

  GrupoService({required Dio dio}) : _dio = dio;

  Future<Grupo> getById(int id) async {
    final resp = await _dio.get('/grupo/$id');
    return Grupo.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<List<Grupo>> findAll() async {
    final resp = await _dio.get('/grupo');
    final data = resp.data as List<dynamic>;
    return data.map((json) => Grupo.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Grupo> create(Map<String, dynamic> data) async {
    final resp = await _dio.post('/grupo', data: data);
    return Grupo.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<Grupo> update(int id, Map<String, dynamic> data) async {
    final resp = await _dio.patch('/grupo/$id', data: data);
    return Grupo.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/grupo/$id');
  }
}
