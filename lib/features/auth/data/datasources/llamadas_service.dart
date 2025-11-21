import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/llamadas.dart';

class LlamadasService {
  final String baseUrl;
  final http.Client _client;

  LlamadasService({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  Future<List<Llamadas>> getAll() async {
    final resp = await _client.get(Uri.parse('$baseUrl/comunicacion'));
    if (resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
    final List<dynamic> raw = jsonDecode(resp.body) as List<dynamic>;
    return raw
        .map((e) => Llamadas.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
