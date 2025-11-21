import 'dart:convert';
import 'package:http/http.dart' as http;

// Este archivo crea la clase AuthService responsable de manejar las llamadas a la API relacionadas con la autenticación.
class AuthService {
  final String baseUrl;

  AuthService({required this.baseUrl});

  // Este método maneja la llamada a la API para iniciar sesión.
  Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    final url = Uri.parse('$baseUrl/trabajador/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'contrasena': contrasena}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Error al iniciar sesión (${response.statusCode}): ${response.body}',
      );
    }
  }
}
