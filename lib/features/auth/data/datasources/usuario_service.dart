import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class UsuarioService {
  final String baseUrl;
  final http.Client _client;

  UsuarioService({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  Future<List<Usuario>> getAll() async {
    final resp = await _client.get(Uri.parse('$baseUrl/usuario'));
    if (resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
    final List<dynamic> raw = jsonDecode(resp.body) as List<dynamic>;
    return raw.map((e) => Usuario.fromJson(e as Map<String, dynamic>)).toList();
  }

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

  Future<Usuario> update(String dni, Map<String, dynamic> payload) async {
    final resp = await _client.put(
      Uri.parse('$baseUrl/usuario/$dni'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
    final Map<String, dynamic> data =
        jsonDecode(resp.body) as Map<String, dynamic>;
    return Usuario.fromJson(data);
  }
}
