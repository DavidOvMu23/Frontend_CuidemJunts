import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notificacion.dart';

// NotificacionService es la clase que maneja las llamadas a la API relacionadas con las notificaciones.
class NotificacionService {
  final String baseUrl;
  final http.Client _client;

  // Constructor que recibe la URL base y un cliente HTTP.
  NotificacionService({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  // getAll maneja la llamada a la API para obtener todas las notificaciones.
  Future<List<Notificacion>> getAll() async {
    // Se hace una petición GET a la API con el ID del grupo.
    final resp = await _client.get(Uri.parse('$baseUrl/notificacion'));

    // Si la respuesta no es exitosa, se lanza una excepción.
    if (resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }

    // Si la respuesta es exitosa, se devuelve el cuerpo de la respuesta.
    final List<dynamic> raw = jsonDecode(resp.body) as List<dynamic>;
    return raw
        .map((e) => Notificacion.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
