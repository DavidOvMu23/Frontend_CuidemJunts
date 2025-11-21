import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/grupo.dart';

class GrupoService {
  final String baseUrl;
  final http.Client _client;

  GrupoService({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  Future<Grupo> getById(int id) async {
    final resp = await _client.get(Uri.parse('$baseUrl/grupo/$id'));
    if (resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
    final Map<String, dynamic> data =
        jsonDecode(resp.body) as Map<String, dynamic>;
    return Grupo.fromJson(data);
  }
}
