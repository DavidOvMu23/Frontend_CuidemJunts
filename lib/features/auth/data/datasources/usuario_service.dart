import 'package:dio/dio.dart';
import '../models/usuario.dart';

// -------- USUARIO SERVICE --------

// Este servicio se encarga de manejar las llamadas a la API relacionadas con los usuarios.
class UsuarioService {
  final Dio _dio;

  // Constructor que recibe el cliente Dio.
  UsuarioService({required Dio dio}) : _dio = dio;

  // getAll maneja la llamada a la API para obtener todos los usuarios.
  Future<List<Usuario>> getAll() async {
    final resp = await _dio.get('/usuario');
    final List<dynamic> raw = resp.data as List<dynamic>;
    return raw.map((e) => Usuario.fromJson(e as Map<String, dynamic>)).toList();
  }

  // create maneja la llamada a la API para crear un nuevo usuario.
  Future<Usuario> create(Map<String, dynamic> payload) async {
    final resp = await _dio.post('/usuario', data: payload);
    return Usuario.fromJson(resp.data as Map<String, dynamic>);
  }

  // update maneja la llamada a la API para actualizar un usuario.
  Future<Usuario> update(String dni, Map<String, dynamic> payload) async {
    final resp = await _dio.patch('/usuario/$dni', data: payload);
    return Usuario.fromJson(resp.data as Map<String, dynamic>);
  }

  // delete maneja la llamada a la API para eliminar un usuario.
  Future<void> delete(String dni) async {
    await _dio.delete('/usuario/$dni');
  }
}
