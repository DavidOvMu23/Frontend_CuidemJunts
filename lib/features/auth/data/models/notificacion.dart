class Notificacion {
  final int id;
  final String contenido;
  final String estado;

  const Notificacion({
    required this.id,
    required this.contenido,
    required this.estado,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id_not'] as int,
      contenido: json['contenido'] as String,
      estado: json['estado'] as String,
    );
  }

  // Getters de ayuda para identificar el estado
  bool get esLeida => estado == 'leida';
  bool get esSinLeer => estado == 'sin_leer';
  bool get esArchivada => estado == 'archivada';
  bool get esCancelada => estado == 'cancelada';
}
