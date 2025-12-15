import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_cuidemjunts/features/auth/data/models/login_response.dart';

// AuthService es la clase que maneja las llamadas a la API relacionadas con la autenticación.
class AuthService {
  final String baseUrl;

  AuthService({required this.baseUrl});

  // Login con JWT usando correo y contraseña
  Future<LoginResponse> login(String correo, String contrasena) async {
    final url = Uri.parse('$baseUrl/auth/login');

    // Se hace una petición POST a la API con correo y contraseña.
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'contrasena': contrasena}),
    );

    // Si la respuesta es exitosa, se devuelve el objeto LoginResponse.
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return LoginResponse.fromJson(jsonData);
    } else {
      throw Exception(
        'Error al iniciar sesión (${response.statusCode}): ${response.body}',
      );
    }
  }
}
