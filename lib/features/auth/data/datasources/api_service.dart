import 'dart:convert';
import 'package:http/http.dart' as http;

// AuthService es la clase que maneja las llamadas a la API relacionadas con la autenticación.
class AuthService {
  final String baseUrl;

  AuthService({required this.baseUrl});

  // login maneja la llamada a la API para iniciar sesión.
  Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    final url = Uri.parse('$baseUrl/trabajador/login');

    // Se hace una petición POST a la API con el correo y la contraseña.
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'contrasena': contrasena}),
    );

    // Si la respuesta es exitosa, se devuelve el cuerpo de la respuesta.
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Error al iniciar sesión (${response.statusCode}): ${response.body}',
      );
    }
  }
}
