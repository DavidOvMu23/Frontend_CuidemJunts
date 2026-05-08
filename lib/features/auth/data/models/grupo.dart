// -------- GRUPO MODEL --------

class Grupo {
  final int id;
  final String nombre;
  final String descripcion;
  final bool activo;
  final int teleoperadoresCount;

  const Grupo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.activo,
    this.teleoperadoresCount = 0,
  });

  Grupo copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    bool? activo,
    int? teleoperadoresCount,
  }) {
    return Grupo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
      teleoperadoresCount: teleoperadoresCount ?? this.teleoperadoresCount,
    );
  }

  factory Grupo.fromJson(Map<String, dynamic> json) {
    final rawId = json['id_grup'] ?? json['id'];
    final idParsed = rawId is int ? rawId : int.tryParse('$rawId') ?? 0;
    final rawCount = json['teleoperadoresCount'];
    final count = rawCount is int
        ? rawCount
        : rawCount is num
            ? rawCount.toInt()
            : int.tryParse('${rawCount ?? 0}') ?? 0;
    return Grupo(
      id: idParsed,
      nombre: (json['nombre'] ?? '') as String,
      descripcion: (json['descripcion'] ?? '') as String,
      activo: (json['activo'] as bool?) ?? true,
      teleoperadoresCount: count,
    );
  }
}
