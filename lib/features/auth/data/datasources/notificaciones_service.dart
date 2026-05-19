import 'package:dio/dio.dart';
import '../models/notificacion.dart';

// -------- NOTIFICACION SERVICE --------
// Este servicio gestiona todas las operaciones relacionadas con las notificaciones:
// obtener la lista (con filtros opcionales), marcar como leídas, archivar,
// buscar por texto y eliminar.
// El servidor guarda y envía las notificaciones paginadas (en grupos de N elementos)
// para no cargar demasiados datos a la vez.
class NotificacionService {
  // _dio es el cliente HTTP que usamos para hablar con el servidor.
  // La barra baja al principio indica que es privado (solo se usa dentro de esta clase).
  final Dio _dio;

  // Constructor: recibe el cliente Dio ya configurado (con la URL base y el token JWT)
  NotificacionService({required Dio dio}) : _dio = dio;

  // getAll: pide al servidor la lista de notificaciones con filtros opcionales.
  // Todos los parámetros son opcionales: si no se pasan, el servidor devuelve todo.
  // - teleoperadorId: filtra solo las notificaciones de ese teleoperador
  // - estado: filtra por estado ('sin_leer', 'leida', 'archivada', 'cancelada')
  // - tipo: filtra por tipo ('call', 'system', 'supervision')
  // - search: busca notificaciones que contengan ese texto
  // - skip: cuántas notificaciones saltar (para paginación, ej: saltar las primeras 20)
  // - take: cuántas notificaciones traer en esta página (por defecto 20)
  Future<List<Notificacion>> getAll({
    int? teleoperadorId,
    String? estado,
    String? tipo,
    String? search,
    int skip = 0,
    int take = 20,
  }) async {
    try {
      // Construimos el mapa de parámetros de consulta.
      // Solo añadimos los filtros que tienen valor para no enviar parámetros vacíos.
      final queryParams = {
        if (teleoperadorId != null) 'teleoperadorId': teleoperadorId,
        if (estado != null) 'estado': estado,
        if (tipo != null) 'tipo': tipo,
        if (search != null) 'search': search,
        // skip y take siempre se envían para controlar la paginación
        'skip': skip,
        'take': take,
      };

      // GET /notificacion?... — pide las notificaciones con los filtros aplicados
      final resp = await _dio.get(
        '/notificacion',
        queryParameters: queryParams,
      );

      // El servidor devuelve un objeto con dos campos: { data: [...], total: N }
      // 'data' contiene la lista de notificaciones; 'total' es el número total (para paginación)
      final List<dynamic> raw = resp.data['data'] as List<dynamic>;
      // Convertimos cada elemento JSON en un objeto Notificacion
      return raw
          .map((e) => Notificacion.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Relanzamos el error tal cual para que quien llame a este método lo gestione
      rethrow;
    }
  }

  // getSinLeer: atajo para obtener solo las notificaciones no leídas de un teleoperador.
  // Es un helper que llama a getAll con el filtro de estado='sin_leer' ya puesto.
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

  // markAsRead: marca una notificación concreta como "leída".
  // Se llama cuando el usuario toca la notificación para verla.
  // Devuelve la notificación actualizada con el nuevo estado.
  Future<Notificacion> markAsRead(int id) async {
    try {
      // PATCH /notificacion/:id/mark-read — actualiza el estado a 'leida' en el servidor
      final resp = await _dio.patch('/notificacion/$id/mark-read');
      return Notificacion.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // archive: mueve una notificación al estado "archivada".
  // Se usa cuando el usuario quiere guardar la notificación pero quitarla de la vista principal.
  // Devuelve la notificación actualizada con el nuevo estado.
  Future<Notificacion> archive(int id) async {
    try {
      // PATCH /notificacion/:id/archive — actualiza el estado a 'archivada' en el servidor
      final resp = await _dio.patch('/notificacion/$id/archive');
      return Notificacion.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // markAllAsRead: marca todas las notificaciones no leídas de un teleoperador como leídas.
  // Se usa con el botón "marcar todo como leído".
  // Devuelve el número de notificaciones que fueron actualizadas.
  Future<int> markAllAsRead(int teleoperadorId) async {
    try {
      // PATCH /notificacion/user/:teleoperadorId/mark-all-read — marca todas como leídas
      final resp = await _dio.patch(
        '/notificacion/user/$teleoperadorId/mark-all-read',
      );
      // 'affected' es el número de notificaciones que se actualizaron en el servidor
      return resp.data['affected'] as int;
    } catch (e) {
      rethrow;
    }
  }

  // delete: elimina permanentemente una notificación por su ID.
  // No devuelve nada porque una eliminación exitosa no tiene datos de respuesta.
  Future<void> delete(int id) async {
    try {
      // DELETE /notificacion/:id — elimina la notificación con ese ID del servidor
      await _dio.delete('/notificacion/$id');
    } catch (e) {
      rethrow;
    }
  }

  // removeArchived: elimina todas las notificaciones archivadas de un teleoperador de una vez.
  // Se usa para limpiar el historial de notificaciones antiguas.
  // Devuelve el número de notificaciones eliminadas.
  Future<int> removeArchived(int teleoperadorId) async {
    try {
      // DELETE /notificacion/user/:teleoperadorId/archived — borra todas las archivadas
      final resp = await _dio.delete(
        '/notificacion/user/$teleoperadorId/archived',
      );
      // 'affected' es el número de notificaciones que fueron eliminadas
      return resp.data['affected'] as int;
    } catch (e) {
      rethrow;
    }
  }

  // search: busca notificaciones que contengan el texto indicado en 'query'.
  // Es un atajo que llama a getAll con el parámetro de búsqueda ya configurado.
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
