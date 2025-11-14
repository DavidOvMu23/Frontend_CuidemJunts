class Grupo {
  final int id;
  final String nombre;
  final String descripcion;
  final bool activo;

  const Grupo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.activo,
  });

  factory Grupo.fromJson(Map<String, dynamic> json) {
    final rawId = json['id_grup'] ?? json['id'];
    final idParsed = rawId is int ? rawId : int.tryParse('$rawId') ?? 0;
    return Grupo(
      id: idParsed,
      nombre: (json['nombre'] ?? '') as String,
      descripcion: (json['descripcion'] ?? '') as String,
      activo: (json['activo'] as bool?) ?? true,
    );
  }
}
