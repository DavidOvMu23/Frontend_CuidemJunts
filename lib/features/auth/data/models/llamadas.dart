class Llamadas {
  final int id;
  final DateTime fecha;
  final String hora;
  final String duracion;
  final String resumen;
  final String observaciones;
  final String estado;

  const Llamadas({
    required this.id,
    required this.fecha,
    required this.hora,
    required this.duracion,
    required this.resumen,
    required this.observaciones,
    required this.estado,
  });

  factory Llamadas.fromJson(Map<String, dynamic> json) {
    final rawId = json['id_com'] ?? json['id'];
    final fechaRaw = json['fecha']?.toString();
    final parsedFecha =
        fechaRaw != null ? DateTime.tryParse(fechaRaw) : null;
    return Llamadas(
      id: rawId is int ? rawId : int.tryParse('$rawId') ?? 0,
      fecha: parsedFecha ?? DateTime.fromMillisecondsSinceEpoch(0),
      hora: (json['hora'] ?? '') as String,
      duracion: (json['duracion'] ?? '') as String,
      resumen: (json['resumen'] ?? '') as String,
      observaciones: (json['observaciones'] ?? '') as String,
      estado: (json['estado'] ?? '') as String,
    );
  }
}
