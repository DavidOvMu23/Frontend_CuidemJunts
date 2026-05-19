import 'package:dio/dio.dart';
import '../models/trabajador.dart';

// -------- TRABAJADOR SERVICE --------
// Este servicio gestiona todas las operaciones relacionadas con los trabajadores
// del sistema (teleoperadores, supervisores, etc.):
// obtener la lista, crear uno nuevo, actualizar sus datos o eliminarlo.
// Cada método hace una petición HTTP al servidor y devuelve el resultado.
class TrabajadorService {
  // _dio es el cliente HTTP que usamos para hablar con el servidor.
  // La barra baja al principio indica que es privado (solo se usa dentro de esta clase).
  final Dio _dio;

  // Constructor: recibe el cliente Dio ya configurado (con la URL base y el token JWT)
  TrabajadorService({required Dio dio}) : _dio = dio;

  // getAll: pide al servidor la lista completa de todos los trabajadores.
  // Devuelve una lista de objetos Trabajador listos para mostrar en la app.
  Future<List<Trabajador>> getAll() async {
    try {
      // GET /trabajador — pide todos los trabajadores al servidor
      final resp = await _dio.get('/trabajador');
      // La respuesta es una lista JSON; la convertimos a tipos Dart
      final List<dynamic> raw = resp.data as List<dynamic>;
      // Convertimos cada elemento JSON en un objeto Trabajador
      return raw.map((e) => Trabajador.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      // Si hay un error, lo informamos con el detalle del servidor
      throw Exception('Error loading trabajadores: ${e.response?.data ?? e.message}');
    }
  }

  // create: envía los datos de un nuevo trabajador al servidor para crearlo.
  // 'payload' es un mapa con los campos del nuevo trabajador (nombre, correo, rol, etc.)
  // Devuelve el trabajador recién creado con el ID que le asignó el servidor.
  Future<Trabajador> create(Map<String, dynamic> payload) async {
    try {
      // POST /trabajador — crea un nuevo trabajador en el servidor
      final resp = await _dio.post('/trabajador', data: payload);
      return Trabajador.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Error creating trabajador: ${e.response?.data ?? e.message}');
    }
  }

  // update: envía los datos modificados de un trabajador al servidor para actualizarlo.
  // 'id' identifica al trabajador; 'payload' contiene solo los campos que cambian.
  // Devuelve el trabajador con los datos ya actualizados.
  Future<Trabajador> update(int id, Map<String, dynamic> payload) async {
    try {
      // PATCH /trabajador/:id — actualiza parcialmente el trabajador con ese ID
      final resp = await _dio.patch('/trabajador/$id', data: payload);
      return Trabajador.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Error updating trabajador: ${e.response?.data ?? e.message}');
    }
  }

  // delete: elimina permanentemente un trabajador del sistema usando su ID numérico.
  // No devuelve nada porque una eliminación exitosa no tiene datos de respuesta.
  Future<void> delete(int id) async {
    try {
      // DELETE /trabajador/:id — elimina el trabajador con ese ID del servidor
      await _dio.delete('/trabajador/$id');
    } on DioException catch (e) {
      throw Exception('Error deleting trabajador: ${e.response?.data ?? e.message}');
    }
  }
}
