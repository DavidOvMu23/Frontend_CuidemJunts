// -------- LOGIN RESPONSE MODEL --------
// Modelo que representa la respuesta del servidor al hacer login

class LoginResponse {
  final String token;
  final TrabajadorLogin trabajador;

  const LoginResponse({required this.token, required this.trabajador});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String? ?? '',
      trabajador: TrabajadorLogin.fromJson(
        json['trabajador'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'trabajador': trabajador.toJson()};
  }
}

class TrabajadorLogin {
  final int id;
  final String correo;
  final String nombre;
  final String apellidos;
  final String rol;
  final String? dni;
  final String? nia;

  const TrabajadorLogin({
    required this.id,
    required this.correo,
    required this.nombre,
    required this.apellidos,
    required this.rol,
    this.dni,
    this.nia,
  });

  factory TrabajadorLogin.fromJson(Map<String, dynamic> json) {
    return TrabajadorLogin(
      id: json['id'] as int? ?? 0,
      correo: json['correo'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      apellidos: json['apellidos'] as String? ?? '',
      rol: json['rol'] as String? ?? '',
      dni: json['dni'] as String?,
      nia: json['nia'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'correo': correo,
      'nombre': nombre,
      'apellidos': apellidos,
      'rol': rol,
      if (dni != null) 'dni': dni,
      if (nia != null) 'nia': nia,
    };
  }
}
