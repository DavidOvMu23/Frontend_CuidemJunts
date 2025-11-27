import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/grupo.dart';

// GrupoService es la clase que maneja las llamadas a la API relacionadas con los grupos.
class GrupoService {
  final String baseUrl;
  final http.Client _client;

  // Constructor que recibe la URL base y un cliente HTTP.
  GrupoService({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  // getById maneja la llamada a la API para obtener un grupo por su ID.
  Future<Grupo> getById(int id) async {
    // Se hace una petición GET a la API con el ID del grupo.
    final resp = await _client.get(Uri.parse('$baseUrl/grupo/$id'));

    // Si la respuesta no es exitosa, se lanza una excepción.
    if (resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }

    // Si la respuesta es exitosa, se devuelve el cuerpo de la respuesta.
    final Map<String, dynamic> data =
        jsonDecode(resp.body) as Map<String, dynamic>;
    return Grupo.fromJson(data);
  }
}
