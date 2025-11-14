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

  factory Trabajador.fromJson(Map<String, dynamic> json) {
    final rawId = json['id_trab'] ?? json['id'];
    return Trabajador(
      id: rawId is int ? rawId : int.tryParse('$rawId') ?? 0,
      nombre: (json['nombre'] ?? '') as String,
      apellidos: (json['apellidos'] ?? '') as String,
      correo: (json['correo'] ?? '') as String,
      rol: (json['rol'] ?? '') as String,
    );
  }

  Function trabajadoID() {
    return id;
  }
}
