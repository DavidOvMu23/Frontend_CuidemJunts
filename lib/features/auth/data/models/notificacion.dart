// -------- NOTIFICACION MODEL --------

// Este modelo representa una notificacion. y lo que hace es que al recibir un json, sepa como convertir cada elemento del json a un objeto Notificacion.
class Notificacion {
  final int id;
  final String contenido;
  final String estado;

  // Constructor que recibe los parámetros necesarios para crear un objeto Notificacion.
  const Notificacion({
    required this.id,
    required this.contenido,
    required this.estado,
  });

  // Constructor que recibe un json y lo convierte en un objeto Notificacion.
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
