// -------- LLAMADAS MODEL --------

// Este modelo representa una llamada (o comunicación) registrada en el sistema.
// Cada vez que un teleoperador llama a un paciente, se crea un registro con
// todos los detalles: cuándo fue, cuánto duró, qué se habló, etc.
// Cuando el servidor nos manda datos JSON, este modelo sabe cómo interpretarlos.
class Llamadas {
  // Número identificador único de esta llamada en la base de datos del servidor
  final int id;

  // Fecha en la que se realizó la llamada (día, mes y año)
  final DateTime fecha;

  // Hora a la que se realizó la llamada (ej: "10:30:00")
  final String hora;

  // Duración total de la llamada (ej: "00:05:32")
  final String duracion;

  // Resumen breve de lo que se habló durante la llamada
  final String resumen;

  // Observaciones adicionales del teleoperador tras la llamada
  // (incidencias, estado del paciente, etc.)
  final String observaciones;

  // Estado actual de la llamada en el flujo del sistema
  // (ej: "pendiente", "completada", "cancelada")
  final String estado;

  // ID del grupo al que pertenece esta llamada — sirve para filtrar por equipo
  final int grupoId;

  // Nombre del grupo (ej: "Grupo Mañana") — se guarda para mostrarlo sin buscar el grupo
  final String? grupoNombre;

  // ID interno del usuario/paciente que recibió la llamada.
  // Es opcional porque puede no estar asignado todavía.
  final int? usuarioId;

  // Nombre del paciente que recibió la llamada — para mostrarlo en la interfaz
  final String? usuarioNombre;

  // Apellidos del paciente — para mostrarlo completo junto con el nombre
  final String? usuarioApellidos;

  // ID del teleoperador que realizó la llamada
  final int? teleoperadorId;

  // Nombre del teleoperador que realizó la llamada
  final String? teleoperadorNombre;

  // Apellidos del teleoperador — para mostrar el nombre completo
  final String? teleoperadorApellidos;

  // Constructor: crea una Llamada con todos sus datos.
  // Los campos con "?" son opcionales porque no siempre están disponibles.
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
    this.teleoperadorId,
    this.teleoperadorNombre,
    this.teleoperadorApellidos,
  });

  // copyWith: crea una copia de la llamada cambiando solo los campos indicados.
  // Se usa para actualizar la llamada sin reescribir todos sus datos.
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
    int? teleoperadorId,
    String? teleoperadorNombre,
    String? teleoperadorApellidos,
  }) {
    return Llamadas(
      // Si se pasa un nuevo valor lo usa; si no, mantiene el valor actual
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
      teleoperadorId: teleoperadorId ?? this.teleoperadorId,
      teleoperadorNombre: teleoperadorNombre ?? this.teleoperadorNombre,
      teleoperadorApellidos: teleoperadorApellidos ?? this.teleoperadorApellidos,
    );
  }

  // fromJson: convierte el JSON que llega del servidor en un objeto Llamadas.
  // El servidor puede anidar datos del grupo, usuario y teleoperador dentro de sub-objetos,
  // o enviarlos directamente como campos planos. Manejamos ambos casos.
  factory Llamadas.fromJson(Map<String, dynamic> json) {
    // El servidor llama al ID de la llamada 'id_com'; si no existe, buscamos 'id'
    final rawId = json['id_com'] ?? json['id'];

    // Convertimos el texto de fecha a un objeto DateTime para poder trabajar con él
    final fechaRaw = json['fecha']?.toString();
    final parsedFecha = fechaRaw != null ? DateTime.tryParse(fechaRaw) : null;

    return Llamadas(
      // Nos aseguramos de que el ID sea siempre un número entero
      id: rawId is int ? rawId : int.tryParse('$rawId') ?? 0,
      // Si la fecha no se puede parsear, usamos el inicio del tiempo como valor neutro
      fecha: parsedFecha ?? DateTime.fromMillisecondsSinceEpoch(0),
      hora: (json['hora'] ?? '') as String,
      duracion: (json['duracion'] ?? '') as String,
      resumen: (json['resumen'] ?? '') as String,
      observaciones: (json['observaciones'] ?? '') as String,
      estado: (json['estado'] ?? '') as String,

      // El grupo puede venir como objeto anidado {id_grup, nombre} o como campos planos
      grupoId: (json['grupo'] is Map)
          ? (json['grupo']['id_grup'] is int
                ? json['grupo']['id_grup'] as int
                : int.tryParse('${json['grupo']['id_grup']}') ?? 0)
          : (json['grupoId'] ?? 0) as int,
      grupoNombre: (json['grupo'] is Map)
          ? (json['grupo']['nombre'] as String?)
          : (json['grupoNombre'] as String?),

      // El usuario también puede venir anidado o como campos planos
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

      // El teleoperador también puede venir anidado o como campos planos
      teleoperadorId: (json['teleoperador'] is Map)
          ? (json['teleoperador']['id_trab'] is int
                ? json['teleoperador']['id_trab'] as int
                : int.tryParse('${json['teleoperador']['id_trab']}'))
          : (json['teleoperadorId'] as int?),
      teleoperadorNombre: (json['teleoperador'] is Map)
          ? (json['teleoperador']['nombre'] as String?)
          : (json['teleoperadorNombre'] as String?),
      teleoperadorApellidos: (json['teleoperador'] is Map)
          ? (json['teleoperador']['apellidos'] as String?)
          : (json['teleoperadorApellidos'] as String?),
    );
  }
}
