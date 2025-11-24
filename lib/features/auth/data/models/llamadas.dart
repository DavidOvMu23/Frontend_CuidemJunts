class Llamadas {
  final int id;
  final DateTime fecha;
  final String hora;
  final String duracion;
  final String resumen;
  final String observaciones;
  final String estado;
  final int grupoId;
  final String? grupoNombre;
  final int? usuarioId;
  final String? usuarioNombre;
  final String? usuarioApellidos;

  const Llamadas({
    required this.id,
    required this.fecha,
    required this.hora,
    required this.duracion,
    required this.resumen,
    required this.observaciones,
    required this.estado,
    required this.grupoId,
    required this.grupoNombre,
    this.usuarioId,
    this.usuarioNombre,
    this.usuarioApellidos,
  });

  Llamadas copyWith({
    int? id,
    DateTime? fecha,
    String? hora,
    String? duracion,
    String? resumen,
    String? observaciones,
    String? estado,
    int? grupoId,
    String? grupoNombre,
    int? usuarioId,
    String? usuarioNombre,
    String? usuarioApellidos,
  }) {
    return Llamadas(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      duracion: duracion ?? this.duracion,
      resumen: resumen ?? this.resumen,
      observaciones: observaciones ?? this.observaciones,
      estado: estado ?? this.estado,
      grupoId: grupoId ?? this.grupoId,
      grupoNombre: grupoNombre ?? this.grupoNombre,
      usuarioId: usuarioId ?? this.usuarioId,
      usuarioNombre: usuarioNombre ?? this.usuarioNombre,
      usuarioApellidos: usuarioApellidos ?? this.usuarioApellidos,
    );
  }

  factory Llamadas.fromJson(Map<String, dynamic> json) {
    final rawId = json['id_com'] ?? json['id'];
    final fechaRaw = json['fecha']?.toString();
    final parsedFecha = fechaRaw != null ? DateTime.tryParse(fechaRaw) : null;

    return Llamadas(
      id: rawId is int ? rawId : int.tryParse('$rawId') ?? 0,
      fecha: parsedFecha ?? DateTime.fromMillisecondsSinceEpoch(0),
      hora: (json['hora'] ?? '') as String,
      duracion: (json['duracion'] ?? '') as String,
      resumen: (json['resumen'] ?? '') as String,
      observaciones: (json['observaciones'] ?? '') as String,
      estado: (json['estado'] ?? '') as String,
      // El backend puede devolver la relación 'grupo' como objeto o
      // solo enviar un grupoId/grupoNombre. Soportamos ambos formatos.
      grupoId: (json['grupo'] is Map)
          ? (json['grupo']['id_grup'] is int
                ? json['grupo']['id_grup'] as int
                : int.tryParse('${json['grupo']['id_grup']}') ?? 0)
          : (json['grupoId'] ?? 0) as int,
      grupoNombre: (json['grupo'] is Map)
          ? (json['grupo']['nombre'] as String?)
          : (json['grupoNombre'] as String?),
      // El backend puede devolver la relación 'usuario' como objeto o
      // solo enviar usuarioId/usuarioNombre. Soportamos ambos formatos.
      usuarioId: (json['usuario'] is Map)
          ? (json['usuario']['id_usu'] is int
                ? json['usuario']['id_usu'] as int
                : int.tryParse('${json['usuario']['id_usu']}') ?? 0)
          : (json['usuarioId'] as int?),
      usuarioNombre: (json['usuario'] is Map)
          ? (json['usuario']['nombre'] as String?)
          : (json['usuarioNombre'] as String?),
      usuarioApellidos: (json['usuario'] is Map)
          ? (json['usuario']['apellidos'] as String?)
          : (json['usuarioApellidos'] as String?),
    );
  }
}
