// -------- GRUPO MODEL --------

// Este modelo representa un grupo de trabajo dentro de CuidemJunts.
// Los grupos organizan a los teleoperadores para distribuir la atención a los pacientes.
// Por ejemplo, puede haber un "Grupo Mañana" y un "Grupo Tarde".
// Cuando el servidor nos manda datos en formato JSON, este modelo
// sabe cómo convertirlos en un objeto que la app puede usar.
class Grupo {
  // Número identificador único del grupo en la base de datos del servidor
  final int id;

  // Nombre del grupo (ej: "Grupo Mañana", "Equipo A")
  final String nombre;

  // Descripción del grupo: explica para qué sirve o qué turno cubre
  final String descripcion;

  // Indica si el grupo está activo (true) o desactivado (false).
  // Un grupo inactivo no aparece disponible para asignar trabajadores.
  final bool activo;

  // Número de teleoperadores que pertenecen a este grupo.
  // Se usa para mostrar cuántos trabajadores tiene cada grupo sin tener que cargar la lista completa.
  final int teleoperadoresCount;

  // Constructor: crea un Grupo con sus datos.
  // teleoperadoresCount empieza en 0 si no se especifica.
  const Grupo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.activo,
    this.teleoperadoresCount = 0,
  });

  // copyWith: crea una copia del grupo cambiando solo los campos que se indiquen.
  // Se usa para actualizar datos sin reescribir todos los campos.
  // Ejemplo: grupo.copyWith(activo: false) desactiva el grupo.
  Grupo copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    bool? activo,
    int? teleoperadoresCount,
  }) {
    return Grupo(
      // Si se pasa un nuevo valor lo usa; si no, mantiene el valor actual
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
      teleoperadoresCount: teleoperadoresCount ?? this.teleoperadoresCount,
    );
  }

  // fromJson: convierte el JSON que llega del servidor en un objeto Grupo.
  // El servidor puede llamar al ID 'id_grup' o simplemente 'id',
  // por eso comprobamos ambas posibilidades.
  factory Grupo.fromJson(Map<String, dynamic> json) {
    // Buscamos el ID del grupo probando los dos nombres posibles
    final rawId = json['id_grup'] ?? json['id'];
    // Nos aseguramos de que el ID sea siempre un número entero
    final idParsed = rawId is int ? rawId : int.tryParse('$rawId') ?? 0;

    // El contador de teleoperadores puede venir como int, decimal o texto
    final rawCount = json['teleoperadoresCount'];
    // Convertimos a entero sin importar el formato en que llegue
    final count = rawCount is int
        ? rawCount
        : rawCount is num
            ? rawCount.toInt()
            : int.tryParse('${rawCount ?? 0}') ?? 0;

    return Grupo(
      id: idParsed,
      // Si el nombre o descripción no vienen, usamos texto vacío como valor seguro
      nombre: (json['nombre'] ?? '') as String,
      descripcion: (json['descripcion'] ?? '') as String,
      // Si no viene el campo 'activo', asumimos que el grupo está activo por defecto
      activo: (json['activo'] as bool?) ?? true,
      teleoperadoresCount: count,
    );
  }
}
