// -------- GRUPO MODEL --------

// Este modelo representa un grupo. y lo que hace es que al recibir un json, sepa como convertir cada elemento del json a un objeto Grupo.
class Grupo {
  final int id;
  final String nombre;
  final String descripcion;
  final bool activo;

  // Constructor que recibe los parámetros necesarios para crear un objeto Grupo.
  const Grupo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.activo,
  });

  // Constructor que recibe un json y lo convierte en un objeto Grupo.
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
