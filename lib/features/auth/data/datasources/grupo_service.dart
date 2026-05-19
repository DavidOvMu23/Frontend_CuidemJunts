import 'package:dio/dio.dart';
import '../models/grupo.dart';

// -------- GRUPO SERVICE --------
// Este servicio gestiona todas las operaciones relacionadas con los grupos de trabajo:
// buscar un grupo concreto, obtener la lista completa, crear uno nuevo,
// actualizar sus datos o eliminarlo.
// Cada método hace una petición HTTP al servidor y devuelve el resultado.
class GrupoService {
  // _dio es el cliente HTTP que usamos para hablar con el servidor.
  // La barra baja al principio indica que es privado (solo se usa dentro de esta clase).
  final Dio _dio;

  // Constructor: recibe el cliente Dio ya configurado (con la URL base y el token JWT)
  GrupoService({required Dio dio}) : _dio = dio;

  // getById: pide al servidor los datos de UN grupo concreto, identificado por su ID.
  // Se usa cuando necesitamos ver el detalle de un grupo específico.
  Future<Grupo> getById(int id) async {
    try {
      // GET /grupo/:id — pide el grupo con ese ID al servidor
      final resp = await _dio.get('/grupo/$id');
      // Convertimos la respuesta JSON en un objeto Grupo
      return Grupo.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Error loading grupo: ${e.response?.data ?? e.message}');
    }
  }

  // findAll: pide al servidor la lista completa de todos los grupos.
  // Devuelve una lista de objetos Grupo listos para mostrar en la app.
  Future<List<Grupo>> findAll() async {
    try {
      // GET /grupo — pide todos los grupos al servidor
      final resp = await _dio.get('/grupo');
      // La respuesta es una lista JSON; la guardamos en 'data'
      final data = resp.data as List<dynamic>;
      // Convertimos cada elemento JSON en un objeto Grupo
      return data.map((json) => Grupo.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Error loading grupos: ${e.response?.data ?? e.message}');
    }
  }

  // create: envía los datos de un nuevo grupo al servidor para crearlo.
  // 'data' es un mapa con los campos del nuevo grupo (nombre, descripción, etc.)
  // Devuelve el grupo recién creado con el ID que le asignó el servidor.
  Future<Grupo> create(Map<String, dynamic> data) async {
    try {
      // POST /grupo — crea un nuevo grupo en el servidor con los datos proporcionados
      final resp = await _dio.post('/grupo', data: data);
      return Grupo.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Error creating grupo: ${e.response?.data ?? e.message}');
    }
  }

  // update: envía los datos modificados de un grupo al servidor para actualizarlo.
  // 'id' identifica el grupo a actualizar; 'data' contiene solo los campos que cambian.
  // Devuelve el grupo con los datos ya actualizados.
  Future<Grupo> update(int id, Map<String, dynamic> data) async {
    try {
      // PATCH /grupo/:id — actualiza parcialmente el grupo con ese ID
      final resp = await _dio.patch('/grupo/$id', data: data);
      return Grupo.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Error updating grupo: ${e.response?.data ?? e.message}');
    }
  }

  // delete: elimina permanentemente un grupo del sistema usando su ID numérico.
  // No devuelve nada porque una eliminación exitosa no tiene datos de respuesta.
  Future<void> delete(int id) async {
    try {
      // DELETE /grupo/:id — elimina el grupo con ese ID del servidor
      await _dio.delete('/grupo/$id');
    } on DioException catch (e) {
      throw Exception('Error deleting grupo: ${e.response?.data ?? e.message}');
    }
  }
}
