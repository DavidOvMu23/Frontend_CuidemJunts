import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/usuario.dart';

class UsuarioService {
  final String baseUrl;
  final http.Client _client;

  UsuarioService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<List<Usuario>> getAll() async {
    final response = await _client.get(Uri.parse('$baseUrl/usuario'));
    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
    final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((item) => Usuario.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
