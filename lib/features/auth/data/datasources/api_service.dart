import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:frontend_cuidemjunts/features/auth/data/models/login_response.dart';

enum LoginErrorType {
  unauthorized,  // 401 — credenciales incorrectas
  forbidden,     // 403 — cuenta sin permisos
  serverError,   // 5xx — error interno del servidor
  noConnection,  // SocketException — servidor no accesible
  timeout,       // TimeoutException — sin respuesta a tiempo
  unknown,       // cualquier otro caso
}

class LoginException implements Exception {
  final LoginErrorType type;
  const LoginException(this.type);
}

class AuthService {
  final String baseUrl;

  AuthService({required this.baseUrl});

  Future<LoginResponse> login(String correo, String contrasena) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'correo': correo, 'contrasena': contrasena}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return LoginResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw const LoginException(LoginErrorType.unauthorized);
      } else if (response.statusCode == 403) {
        throw const LoginException(LoginErrorType.forbidden);
      } else if (response.statusCode >= 500) {
        throw const LoginException(LoginErrorType.serverError);
      } else {
        throw const LoginException(LoginErrorType.unknown);
      }
    } on LoginException {
      rethrow;
    } on SocketException {
      throw const LoginException(LoginErrorType.noConnection);
    } on TimeoutException {
      throw const LoginException(LoginErrorType.timeout);
    } catch (_) {
      throw const LoginException(LoginErrorType.noConnection);
    }
  }
}
