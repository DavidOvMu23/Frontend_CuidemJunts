import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

// -------- USUARIO SERVICE --------

// Este servicio se encarga de manejar las llamadas a la API relacionadas con los usuarios.
class UsuarioService {
  final String baseUrl;
  final http.Client _client;

  // Constructor que recibe la URL base y un cliente HTTP.
  UsuarioService({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  // getAll maneja la llamada a la API para obtener todas las notificaciones.
  Future<List<Usuario>> getAll() async {
    final resp = await _client.get(Uri.parse('$baseUrl/usuario'));
    if (resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
    final List<dynamic> raw = jsonDecode(resp.body) as List<dynamic>;
    return raw.map((e) => Usuario.fromJson(e as Map<String, dynamic>)).toList();
  }

  // create maneja la llamada a la API para crear un nuevo usuario.
  Future<Usuario> create(Map<String, dynamic> payload) async {
    final resp = await _client.post(
      Uri.parse('$baseUrl/usuario'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
    final Map<String, dynamic> data =
        jsonDecode(resp.body) as Map<String, dynamic>;
    return Usuario.fromJson(data);
  }

  // update maneja la llamada a la API para actualizar un usuario.
  Future<Usuario> update(String dni, Map<String, dynamic> payload) async {
    // Añadir el DNI al payload
    final payloadConDni = {'dni': dni, ...payload};

    final resp = await _client.patch(
      Uri.parse('$baseUrl/usuario/dni'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payloadConDni),
    );

    if (resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }

    final Map<String, dynamic> data =
        jsonDecode(resp.body) as Map<String, dynamic>;
    return Usuario.fromJson(data);
  }

  // delete maneja la llamada a la API para eliminar un usuario.
  Future<void> delete(String dni) async {
    final payloadConDni = {'dni': dni};

    final resp = await _client.delete(
      Uri.parse('$baseUrl/usuario/dni'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payloadConDni),
    );

    if (resp.statusCode != 204 && resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }
}
