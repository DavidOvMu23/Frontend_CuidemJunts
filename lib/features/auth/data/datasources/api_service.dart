import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:frontend_cuidemjunts/features/auth/data/models/login_response.dart';

// -------- TIPOS DE ERROR DE LOGIN --------
// Enumeramos todos los errores posibles al intentar iniciar sesión.
// Así la interfaz puede mostrar un mensaje de error concreto en cada caso.
enum LoginErrorType {
  unauthorized,  // 401 — el correo o la contraseña son incorrectos
  forbidden,     // 403 — las credenciales son correctas pero la cuenta no tiene permiso de acceso
  serverError,   // 5xx — algo ha fallado en el servidor (error interno)
  noConnection,  // SocketException — no se puede contactar con el servidor (sin internet o servidor caído)
  timeout,       // TimeoutException — el servidor tardó demasiado en responder
  unknown,       // cualquier otro caso inesperado
}

// LoginException: es el tipo de error personalizado que lanzamos cuando el login falla.
// Incluye el tipo de error para que quien lo reciba sepa exactamente qué pasó.
class LoginException implements Exception {
  final LoginErrorType type;
  const LoginException(this.type);
}

// -------- AUTH SERVICE --------
// Este servicio gestiona la autenticación del usuario.
// Por ahora solo tiene el método de login, que envía las credenciales al servidor
// y devuelve el token y los datos del trabajador si son correctas.
class AuthService {
  // URL base del servidor (ej: "http://localhost:3000")
  // Se inyecta al crear el servicio para poder cambiarla fácilmente (desarrollo/producción)
  final String baseUrl;

  AuthService({required this.baseUrl});

  // login: envía el correo y la contraseña al servidor y devuelve la sesión si son correctos.
  // Si algo falla, lanza un LoginException con el tipo de error correspondiente.
  Future<LoginResponse> login(String correo, String contrasena) async {
    // Construimos la URL completa del endpoint de login
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      // Enviamos una petición POST al servidor con las credenciales en formato JSON.
      // Esperamos máximo 10 segundos; si tarda más, lanzamos un error de timeout.
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'correo': correo, 'contrasena': contrasena}),
          )
          .timeout(const Duration(seconds: 10));

      // Si el servidor responde con 200 o 201, el login fue exitoso
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Convertimos el texto JSON de la respuesta en un mapa de datos
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        // Convertimos el mapa en un objeto LoginResponse que la app puede usar
        return LoginResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        // 401 = no autorizado: las credenciales son incorrectas
        throw const LoginException(LoginErrorType.unauthorized);
      } else if (response.statusCode == 403) {
        // 403 = prohibido: la cuenta existe pero no tiene acceso (ej: rol incorrecto)
        throw const LoginException(LoginErrorType.forbidden);
      } else if (response.statusCode >= 500) {
        // 5xx = error del servidor: algo ha fallado en el backend
        throw const LoginException(LoginErrorType.serverError);
      } else {
        // Cualquier otro código de error inesperado
        throw const LoginException(LoginErrorType.unknown);
      }
    } on LoginException {
      // Si ya es un LoginException, lo dejamos pasar sin modificar
      rethrow;
    } on SocketException {
      // No se pudo conectar al servidor (sin internet o servidor apagado)
      throw const LoginException(LoginErrorType.noConnection);
    } on TimeoutException {
      // El servidor tardó más de 10 segundos en responder
      throw const LoginException(LoginErrorType.timeout);
    } catch (_) {
      // Cualquier otro error desconocido lo tratamos como falta de conexión
      throw const LoginException(LoginErrorType.noConnection);
    }
  }

  // Verifica si un token JWT sigue siendo válido pidiendo el perfil al servidor.
  // Devuelve los datos del payload (id, correo, nombre, rol, nia, grupoId si
  // aplica) cuando el token es válido, o `null` si el servidor lo rechaza o
  // no se puede contactar.
  // Devuelve el perfil si el token es válido (200), null si el servidor lo
  // rechaza explícitamente (401/403), o lanza una excepción si hay un error
  // de red (sin conexión, timeout, etc.). El llamador usa esta distinción:
  // - null  → token caducado/revocado → hacer logout
  // - throw → red no disponible → mantener la sesión en caché
  Future<Map<String, dynamic>?> getProfile(String token) async {
    final url = Uri.parse('$baseUrl/auth/profile');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    // 401/403 → token caducado o revocado.
    return null;
  }
}
