// -------- LOGIN RESPONSE MODEL --------
// Este modelo representa la respuesta que el servidor devuelve cuando un
// trabajador inicia sesión correctamente.
// El servidor responde con dos cosas: un token de seguridad y los datos del trabajador.

class LoginResponse {
  // Token JWT: es una clave de seguridad que la app guarda y envía en cada petición posterior
  // para que el servidor sepa que el usuario está identificado (como un pase de acceso temporal)
  final String token;

  // Datos básicos del trabajador que acaba de iniciar sesión
  // (nombre, rol, grupo al que pertenece, etc.)
  final TrabajadorLogin trabajador;

  // Constructor: ambos campos son obligatorios porque el servidor siempre los envía
  const LoginResponse({required this.token, required this.trabajador});

  // fromJson: convierte el JSON de respuesta del servidor en un objeto LoginResponse.
  // Si el servidor no manda el token o los datos del trabajador, usamos valores vacíos seguros.
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String? ?? '',
      trabajador: TrabajadorLogin.fromJson(
        // Si no viene el objeto 'trabajador', usamos un mapa vacío para evitar errores
        json['trabajador'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  // toJson: convierte este objeto de vuelta a formato JSON.
  // Se usa cuando necesitamos guardar la sesión en el almacenamiento local del dispositivo.
  Map<String, dynamic> toJson() {
    return {'token': token, 'trabajador': trabajador.toJson()};
  }
}

// -------- TRABAJADOR LOGIN MODEL --------
// Contiene los datos mínimos del trabajador que se devuelven al hacer login.
// Solo incluye lo necesario para identificar al usuario y configurar la sesión.
class TrabajadorLogin {
  // ID numérico del trabajador en la base de datos
  final int id;

  // Correo electrónico con el que el trabajador inició sesión
  final String correo;

  // Nombre de pila del trabajador (para mostrar en la pantalla de bienvenida)
  final String nombre;

  // Apellidos del trabajador
  final String apellidos;

  // Rol del trabajador en el sistema (ej: "teleoperador", "supervisor", "admin")
  // Determina qué pantallas y funciones puede usar
  final String rol;

  // DNI del trabajador — es opcional porque no todos los roles lo requieren al inicio de sesión
  final String? dni;

  // NIA (número de identificación interno) — opcional, igual que el DNI
  final String? nia;

  // ID del grupo al que pertenece el trabajador — opcional porque puede no estar asignado a ningún grupo
  final int? grupoId;

  // Constructor: id, correo, nombre, apellidos y rol son obligatorios; el resto es opcional
  const TrabajadorLogin({
    required this.id,
    required this.correo,
    required this.nombre,
    required this.apellidos,
    required this.rol,
    this.dni,
    this.nia,
    this.grupoId,
  });

  // fromJson: convierte el JSON del servidor en un objeto TrabajadorLogin.
  // Si algún campo obligatorio no llega, usamos valores vacíos para evitar que la app se rompa.
  factory TrabajadorLogin.fromJson(Map<String, dynamic> json) {
    return TrabajadorLogin(
      id: json['id'] as int? ?? 0,
      correo: json['correo'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      apellidos: json['apellidos'] as String? ?? '',
      rol: json['rol'] as String? ?? '',
      dni: json['dni'] as String?,
      nia: json['nia'] as String?,
      grupoId: json['grupoId'] as int?,
    );
  }

  // toJson: convierte el trabajador a JSON para guardarlo en el almacenamiento local.
  // Solo incluimos los campos opcionales (dni, nia, grupoId) si tienen valor,
  // para no guardar claves con valor nulo innecesariamente.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'correo': correo,
      'nombre': nombre,
      'apellidos': apellidos,
      'rol': rol,
      // Solo añadimos estos campos al JSON si tienen un valor real
      if (dni != null) 'dni': dni,
      if (nia != null) 'nia': nia,
      if (grupoId != null) 'grupoId': grupoId,
    };
  }
}
