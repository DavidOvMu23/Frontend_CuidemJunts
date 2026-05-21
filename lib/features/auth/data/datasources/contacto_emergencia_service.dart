import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/dio_client.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/llamadas_provider.dart'
    show kListPollInterval;
import '../models/usuario.dart';

// -------- CONTACTO EMERGENCIA SERVICE --------
// Este servicio gestiona todas las operaciones relacionadas con los contactos de emergencia:
// obtener la lista completa, crear uno nuevo, obtener los contactos de un paciente concreto,
// actualizar los datos de un contacto o eliminarlo.
class ContactoEmergenciaService {
  // _dio es el cliente HTTP que usamos para hablar con el servidor.
  // La barra baja al principio indica que es privado (solo se usa dentro de esta clase).
  final Dio _dio;

  // Constructor: recibe el cliente Dio ya configurado (con la URL base y el token JWT)
  ContactoEmergenciaService({required Dio dio}) : _dio = dio;

  // getAll: pide al servidor la lista completa de todos los contactos de emergencia.
  // Devuelve una lista de objetos ContactoEmergencia listos para mostrar en la app.
  Future<List<ContactoEmergencia>> getAll() async {
    try {
      // GET /contacto_emergencia — pide todos los contactos al servidor
      final resp = await _dio.get('/contacto_emergencia');
      // La respuesta es una lista JSON; la convertimos a tipos Dart
      final List<dynamic> raw = resp.data as List<dynamic>;
      // Convertimos cada elemento JSON en un objeto ContactoEmergencia
      return raw.map((e) => ContactoEmergencia.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Error loading contactos: ${e.response?.data ?? e.message}');
    }
  }

  // create: envía los datos de un nuevo contacto de emergencia al servidor para crearlo.
  // 'payload' es un mapa con los campos del nuevo contacto (nombre, teléfono, dni del paciente, etc.)
  // Devuelve el contacto recién creado con el ID que le asignó el servidor.
  Future<ContactoEmergencia> create(Map<String, dynamic> payload) async {
    try {
      // POST /contacto_emergencia — crea un nuevo contacto de emergencia en el servidor
      final resp = await _dio.post('/contacto_emergencia', data: payload);
      return ContactoEmergencia.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Error creating contacto: ${e.response?.data ?? e.message}');
    }
  }

  // getByUsuario: pide al servidor todos los contactos de emergencia de UN paciente concreto.
  // 'dni' es el documento de identidad del paciente cuyos contactos queremos ver.
  // Se usa en la pantalla de detalle del paciente para mostrar a quién llamar en caso de emergencia.
  Future<List<ContactoEmergencia>> getByUsuario(String dni) async {
    try {
      // GET /contacto_emergencia/usuario/:dni — pide solo los contactos del paciente con ese DNI
      final resp = await _dio.get('/contacto_emergencia/usuario/$dni');
      final List<dynamic> raw = resp.data as List<dynamic>;
      return raw.map((e) => ContactoEmergencia.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Error loading contactos de usuario: ${e.response?.data ?? e.message}');
    }
  }

  // update: envía los datos modificados de un contacto al servidor para actualizarlo.
  // 'id' identifica el contacto a actualizar; 'payload' contiene solo los campos que cambian.
  // Devuelve el contacto con los datos ya actualizados.
  Future<ContactoEmergencia> update(int id, Map<String, dynamic> payload) async {
    try {
      // PATCH /contacto_emergencia/:id — actualiza parcialmente el contacto con ese ID
      final resp = await _dio.patch('/contacto_emergencia/$id', data: payload);
      return ContactoEmergencia.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Error updating contacto: ${e.response?.data ?? e.message}');
    }
  }

  // delete: elimina permanentemente un contacto de emergencia usando su ID numérico.
  // No devuelve nada porque una eliminación exitosa no tiene datos de respuesta.
  Future<void> delete(int id) async {
    try {
      // DELETE /contacto_emergencia/:id — elimina el contacto con ese ID del servidor
      await _dio.delete('/contacto_emergencia/$id');
    } on DioException catch (e) {
      throw Exception('Error deleting contacto: ${e.response?.data ?? e.message}');
    }
  }
}

// -------- PROVIDER DEL SERVICIO --------
// Este provider crea y pone a disposición de toda la app una única instancia
// de ContactoEmergenciaService ya conectada al cliente HTTP configurado.
// Así cualquier pantalla puede pedir contactos de emergencia sin preocuparse
// de cómo se conecta al servidor.
final contactoEmergenciaServiceProvider = Provider<ContactoEmergenciaService>((ref) {
  // Obtenemos el cliente Dio ya configurado (con URL base, token JWT, etc.)
  final dio = ref.watch(dioClientProvider);
  // Creamos el servicio con ese cliente y lo devolvemos para que la app lo use
  return ContactoEmergenciaService(dio: dio);
});

// StreamProvider con la lista completa de contactos de emergencia en tiempo real.
// Hace polling cada kListPollInterval para que las pantallas que muestran
// contactos se refresquen automáticamente al cambiar los datos en el servidor.
final contactosEmergenciaProvider =
    StreamProvider<List<ContactoEmergencia>>((ref) {
  final service = ref.watch(contactoEmergenciaServiceProvider);
  final controller = StreamController<List<ContactoEmergencia>>();

  Future<void> fetch() async {
    try {
      final fresh = await service.getAll();
      if (!controller.isClosed) controller.add(fresh);
    } catch (_) {
      // Silenciamos errores transitorios de red para no romper el stream.
    }
  }

  fetch();
  final timer = Timer.periodic(kListPollInterval, (_) => fetch());

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});
