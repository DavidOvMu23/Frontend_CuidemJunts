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
}
