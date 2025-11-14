class Trabajador {
  final int id;
  final String nombre;
  final String apellidos;
  final String correo;
  final String rol;

  const Trabajador({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.correo,
    required this.rol,
  });

  factory Trabajador.fromJson(Map<String, dynamic> json) => Trabajador(
    id: json['id'] as int,
    nombre: json['nombre'] as String,
    apellidos: json['apellidos'] as String,
    correo: json['correo'] as String,
    rol: json['rol'] as String,
  );
}
