import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

// -------- CONTACTO EMERGENCIA SERVICE --------

// Este servicio se encarga de manejar las llamadas a la API relacionadas con los contactos de emergencia.
class ContactoEmergenciaService {
  final String baseUrl;
  final http.Client _client;

  // Constructor que recibe la URL base y un cliente HTTP.
  ContactoEmergenciaService({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  // getAll maneja la llamada a la API para obtener todos los contactos de emergencia.
  Future<List<ContactoEmergencia>> getAll() async {
    final resp = await _client.get(Uri.parse('$baseUrl/contacto_emergencia'));
    if (resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
    final List<dynamic> raw = jsonDecode(resp.body) as List<dynamic>;
    return raw
        .map((e) => ContactoEmergencia.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // create maneja la llamada a la API para crear un nuevo contacto de emergencia.
  Future<ContactoEmergencia> create(Map<String, dynamic> payload) async {
    final resp = await _client.post(
      Uri.parse('$baseUrl/contacto_emergencia'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
    final Map<String, dynamic> data =
        jsonDecode(resp.body) as Map<String, dynamic>;
    return ContactoEmergencia.fromJson(data);
  }

  // update maneja la llamada a la API para actualizar un contacto de emergencia.
  Future<ContactoEmergencia> update(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final resp = await _client.patch(
      Uri.parse('$baseUrl/contacto_emergencia/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }

    final Map<String, dynamic> data =
        jsonDecode(resp.body) as Map<String, dynamic>;
    return ContactoEmergencia.fromJson(data);
  }

  // delete maneja la llamada a la API para eliminar un contacto de emergencia.
  Future<void> delete(int id) async {
    final resp = await _client.delete(
      Uri.parse('$baseUrl/contacto_emergencia/$id'),
    );

    if (resp.statusCode != 204 && resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }
}
