import 'package:dio/dio.dart';
import '../models/llamadas.dart';

// -------- LLAMADAS SERVICE --------
// Este servicio gestiona todas las operaciones relacionadas con las llamadas/comunicaciones
// registradas en el sistema: obtener la lista, registrar una nueva llamada,
// actualizar los datos de una llamada existente o eliminarla.
// El endpoint del servidor para las llamadas se llama '/comunicacion'.
class LlamadasService {
  // _dio es el cliente HTTP que usamos para hablar con el servidor.
  // La barra baja al principio indica que es privado (solo se usa dentro de esta clase).
  final Dio _dio;

  // Constructor: recibe el cliente Dio ya configurado (con la URL base y el token JWT)
  LlamadasService({required Dio dio}) : _dio = dio;

  // getAll: pide al servidor el historial completo de todas las llamadas.
  // Devuelve una lista de objetos Llamadas listos para mostrar en la app.
  Future<List<Llamadas>> getAll() async {
    try {
      // GET /comunicacion — pide todas las llamadas al servidor
      final resp = await _dio.get('/comunicacion');
      // La respuesta es una lista JSON; la convertimos a tipos Dart
      final List<dynamic> raw = resp.data as List<dynamic>;
      // Convertimos cada elemento JSON en un objeto Llamadas
      return raw.map((e) => Llamadas.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Error loading llamadas: ${e.response?.data ?? e.message}');
    }
  }

  // create: registra una nueva llamada en el servidor.
  // 'payload' es un mapa con los datos de la llamada (fecha, hora, resumen, etc.)
  // Devuelve la llamada recién creada con el ID que le asignó el servidor.
  Future<Llamadas> create(Map<String, dynamic> payload) async {
    try {
      // POST /comunicacion — crea un nuevo registro de llamada en el servidor
      final resp = await _dio.post('/comunicacion', data: payload);
      return Llamadas.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Error creating llamada: ${e.response?.data ?? e.message}');
    }
  }

  // update: envía los datos modificados de una llamada al servidor para actualizarla.
  // 'id' identifica la llamada a actualizar; 'payload' contiene solo los campos que cambian.
  // Devuelve la llamada con los datos ya actualizados.
  Future<Llamadas> update(int id, Map<String, dynamic> payload) async {
    try {
      // PATCH /comunicacion/:id — actualiza parcialmente la llamada con ese ID
      final resp = await _dio.patch('/comunicacion/$id', data: payload);
      return Llamadas.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Error updating llamada: ${e.response?.data ?? e.message}');
    }
  }

  // delete: elimina permanentemente el registro de una llamada usando su ID numérico.
  // No devuelve nada porque una eliminación exitosa no tiene datos de respuesta.
  Future<void> delete(int id) async {
    try {
      // DELETE /comunicacion/:id — elimina la llamada con ese ID del servidor
      await _dio.delete('/comunicacion/$id');
    } on DioException catch (e) {
      throw Exception('Error deleting llamada: ${e.response?.data ?? e.message}');
    }
  }
}
