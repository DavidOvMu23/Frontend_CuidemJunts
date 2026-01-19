import 'package:dio/dio.dart';
import '../models/notificacion.dart';

// NotificacionService es la clase que maneja las llamadas a la API relacionadas con las notificaciones.
class NotificacionService {
  final Dio _dio;

  // Constructor que recibe el cliente Dio.
  NotificacionService({required Dio dio}) : _dio = dio;

  // getAll maneja la llamada a la API para obtener todas las notificaciones.
  Future<List<Notificacion>> getAll() async {
    final resp = await _dio.get('/notificacion');
    final List<dynamic> raw = resp.data as List<dynamic>;
    return raw
        .map((e) => Notificacion.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
