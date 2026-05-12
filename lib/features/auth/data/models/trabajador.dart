// -------- TRABAJADOR MODEL --------

// Este modelo representa un trabajador. y lo que hace es que al recibir un json, sepa como convertir cada elemento del json a un objeto Trabajador.
class Trabajador {
  final int id;
  final String nombre;
  final String apellidos;
  final String correo;
  final String rol;
  final int? grupoId;
  final String? grupoNombre;
  final bool activo;
  final String? nia;
  final String? dni;
  final String? telefono;

  const Trabajador({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.correo,
    required this.rol,
    this.grupoId,
    this.grupoNombre,
    this.activo = true,
    this.nia,
    this.dni,
    this.telefono,
  });

  Trabajador copyWith({
    int? id,
    String? nombre,
    String? apellidos,
    String? correo,
    String? rol,
    int? grupoId,
    String? grupoNombre,
    bool? activo,
    String? nia,
    String? dni,
    String? telefono,
  }) {
    return Trabajador(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      correo: correo ?? this.correo,
      rol: rol ?? this.rol,
      grupoId: grupoId ?? this.grupoId,
      grupoNombre: grupoNombre ?? this.grupoNombre,
      activo: activo ?? this.activo,
      nia: nia ?? this.nia,
      dni: dni ?? this.dni,
      telefono: telefono ?? this.telefono,
    );
  }

  factory Trabajador.fromJson(Map<String, dynamic> json) {
    final rawId = json['id_trab'] ?? json['id'];
    final grupoNombre =
        json['grupoNombre'] as String? ??
        (json['grupo'] is Map<String, dynamic>
            ? (json['grupo']['nombre'] as String?)
            : null);
    final rawGrupoId = json['grupoId'] ?? json['grupo_id'];
    final grupoId = rawGrupoId is int
        ? rawGrupoId
        : rawGrupoId is num
        ? rawGrupoId.toInt()
        : rawGrupoId is String
        ? int.tryParse(rawGrupoId)
        : (json['grupo'] is Map<String, dynamic>
              ? (json['grupo']['id_grup'] as int?)
              : null);
    return Trabajador(
      id: rawId is int ? rawId : int.tryParse('$rawId') ?? 0,
      nombre: (json['nombre'] ?? '') as String,
      apellidos: (json['apellidos'] ?? '') as String,
      correo: (json['correo'] ?? '') as String,
      rol: (json['rol'] ?? '') as String,
      grupoId: grupoId,
      grupoNombre: grupoNombre,
      activo: (json['activo'] as bool?) ?? true,
      nia: json['nia'] as String?,
      dni: json['dni'] as String?,
      telefono: json['telefono'] as String?,
    );
  }
}
