import 'package:dio/dio.dart';
import '../models/notificacion.dart';

class NotificacionService {
  final Dio _dio;

  NotificacionService({required Dio dio}) : _dio = dio;

  // Obtener todas las notificaciones con filtros opcionales
  Future<List<Notificacion>> getAll({
    int? teleoperadorId,
    String? estado,
    String? tipo,
    String? search,
    int skip = 0,
    int take = 20,
  }) async {
    try {
      final queryParams = {
        if (teleoperadorId != null) 'teleoperadorId': teleoperadorId,
        if (estado != null) 'estado': estado,
        if (tipo != null) 'tipo': tipo,
        if (search != null) 'search': search,
        'skip': skip,
        'take': take,
      };

      final resp = await _dio.get(
        '/notificacion',
        queryParameters: queryParams,
      );

      // El backend ahora retorna { data: [...], total: N }
      final List<dynamic> raw = resp.data['data'] as List<dynamic>;
      return raw
          .map((e) => Notificacion.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Helper para obtener solo sin leer
  Future<List<Notificacion>> getSinLeer({
    int? teleoperadorId,
    int skip = 0,
    int take = 20,
  }) async {
    return getAll(
      teleoperadorId: teleoperadorId,
      estado: 'sin_leer',
      skip: skip,
      take: take,
    );
  }

  // Marcar una notificación como leída
  Future<Notificacion> markAsRead(int id) async {
    try {
      final resp = await _dio.patch('/notificacion/$id/mark-read');
      return Notificacion.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Archivar una notificación
  Future<Notificacion> archive(int id) async {
    try {
      final resp = await _dio.patch('/notificacion/$id/archive');
      return Notificacion.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Marcar todas como leídas para un usuario
  Future<int> markAllAsRead(int teleoperadorId) async {
    try {
      final resp = await _dio.patch(
        '/notificacion/user/$teleoperadorId/mark-all-read',
      );
      return resp.data['affected'] as int;
    } catch (e) {
      rethrow;
    }
  }

  // Eliminar una notificación
  Future<void> delete(int id) async {
    try {
      await _dio.delete('/notificacion/$id');
    } catch (e) {
      rethrow;
    }
  }

  // Limpiar notificaciones archivadas
  Future<int> removeArchived(int teleoperadorId) async {
    try {
      final resp = await _dio.delete(
        '/notificacion/user/$teleoperadorId/archived',
      );
      return resp.data['affected'] as int;
    } catch (e) {
      rethrow;
    }
  }

  // Buscar notificaciones
  Future<List<Notificacion>> search({
    required String query,
    int? teleoperadorId,
    int skip = 0,
    int take = 20,
  }) async {
    return getAll(
      teleoperadorId: teleoperadorId,
      search: query,
      skip: skip,
      take: take,
    );
  }
}
