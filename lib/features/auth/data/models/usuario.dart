class Usuario {
  final String dni;
  final String nombre;
  final String apellidos;
  final String estadoCuenta;
  final String nivelDependencia;
  final String informacion;

  const Usuario({
    required this.dni,
    required this.nombre,
    required this.apellidos,
    required this.estadoCuenta,
    required this.nivelDependencia,
    required this.informacion,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      dni: (json['dni'] ?? '') as String,
      nombre: (json['nombre'] ?? '') as String,
      apellidos: (json['apellidos'] ?? '') as String,
      estadoCuenta: (json['estado_cuenta'] ?? '') as String,
      nivelDependencia: (json['nivel_dependencia'] ?? '') as String,
      informacion: (json['informacion'] ?? '') as String,
    );
  }
}
