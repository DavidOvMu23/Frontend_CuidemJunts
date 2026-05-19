import 'package:dio/dio.dart';
import '../models/usuario.dart';

// -------- USUARIO SERVICE --------
// Este servicio gestiona todas las operaciones relacionadas con los usuarios/pacientes
// del sistema: obtener la lista, crear uno nuevo, actualizar sus datos o eliminarlo.
// Cada método hace una petición HTTP al servidor y devuelve el resultado.
class UsuarioService {
  // _dio es el cliente HTTP que usamos para hablar con el servidor.
  // La barra baja al principio indica que es privado (solo se usa dentro de esta clase).
  final Dio _dio;

  // Constructor: recibe el cliente Dio ya configurado (con la URL base y el token JWT)
  UsuarioService({required Dio dio}) : _dio = dio;

  // getAll: pide al servidor la lista completa de todos los usuarios/pacientes.
  // Devuelve una lista de objetos Usuario listos para mostrar en la app.
  Future<List<Usuario>> getAll() async {
    try {
      // GET /usuario — pide todos los usuarios al servidor
      final resp = await _dio.get('/usuario');
      // La respuesta del servidor es una lista en formato JSON; la convertimos a tipos Dart
      final List<dynamic> raw = resp.data as List<dynamic>;
      // Convertimos cada elemento JSON en un objeto Usuario
      return raw.map((e) => Usuario.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      // Si hay un error de red o del servidor, lanzamos una excepción con el detalle del error
      throw Exception('Error loading usuarios: ${e.response?.data ?? e.message}');
    }
  }

  // create: envía los datos de un nuevo usuario al servidor para crearlo.
  // 'payload' es un mapa con los campos del nuevo usuario (nombre, dni, teléfono, etc.)
  // Devuelve el usuario recién creado con el ID que le asignó el servidor.
  Future<Usuario> create(Map<String, dynamic> payload) async {
    try {
      // POST /usuario — crea un nuevo usuario en el servidor con los datos del payload
      final resp = await _dio.post('/usuario', data: payload);
      // Convertimos la respuesta JSON en un objeto Usuario
      return Usuario.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Error creating usuario: ${e.response?.data ?? e.message}');
    }
  }

  // update: envía los datos modificados de un usuario al servidor para actualizarlo.
  // 'dni' identifica al usuario a actualizar; 'payload' contiene solo los campos que cambian.
  // Devuelve el usuario con los datos ya actualizados.
  Future<Usuario> update(String dni, Map<String, dynamic> payload) async {
    try {
      // PATCH /usuario/:dni — actualiza parcialmente el usuario identificado por su DNI
      final resp = await _dio.patch('/usuario/$dni', data: payload);
      return Usuario.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Error updating usuario: ${e.response?.data ?? e.message}');
    }
  }

  // delete: elimina permanentemente un usuario del sistema usando su DNI.
  // No devuelve nada porque una eliminación exitosa no tiene datos de respuesta.
  Future<void> delete(String dni) async {
    try {
      // DELETE /usuario/:dni — elimina el usuario con ese DNI del servidor
      await _dio.delete('/usuario/$dni');
    } on DioException catch (e) {
      throw Exception('Error deleting usuario: ${e.response?.data ?? e.message}');
    }
  }
}
