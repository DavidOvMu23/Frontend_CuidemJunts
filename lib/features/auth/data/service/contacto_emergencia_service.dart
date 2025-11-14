import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class ContactoEmergenciaService {
  final String baseUrl;
  final http.Client _client;

  ContactoEmergenciaService({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  Future<List<ContactoEmergencia>> getByUsuarioDni(String dni) async {
    final resp = await _client.get(
      Uri.parse(
        '$baseUrl/contacto_emergencia/usuario/${Uri.encodeComponent(dni)}',
      ),
    );
    if (resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
    final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(ContactoEmergencia.fromJson)
        .toList();
  }
}
