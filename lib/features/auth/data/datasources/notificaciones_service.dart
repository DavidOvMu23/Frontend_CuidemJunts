import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notificacion.dart';

class NotificacionService {
  final String baseUrl;
  final http.Client _client;

  NotificacionService({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  Future<List<Notificacion>> getAll() async {
    final resp = await _client.get(Uri.parse('$baseUrl/notificacion'));
    if (resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
    final List<dynamic> raw = jsonDecode(resp.body) as List<dynamic>;
    return raw
        .map((e) => Notificacion.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
