// -------- TRABAJADOR MODEL --------

// Este modelo representa a un trabajador del sistema CuidemJunts
// (puede ser un teleoperador, supervisor u otro rol).
// Cuando el servidor nos manda datos en formato JSON, este modelo
// sabe cómo convertirlos en un objeto que la app puede usar y mostrar.
class Trabajador {
  // Número identificador único del trabajador en la base de datos del servidor
  final int id;

  // Nombre de pila del trabajador (ej: "Carlos")
  final String nombre;

  // Apellidos del trabajador (ej: "Martínez Ruiz")
  final String apellidos;

  // Correo electrónico — se usa para identificarse en el sistema y recibir comunicaciones
  final String correo;

  // Rol del trabajador dentro del sistema (ej: "teleoperador", "supervisor", "admin")
  // Define qué puede hacer y qué pantallas puede ver
  final String rol;

  // ID del grupo al que pertenece el trabajador.
  // Es opcional porque un trabajador puede no estar asignado a ningún grupo todavía.
  final int? grupoId;

  // Nombre del grupo al que pertenece (ej: "Grupo Mañana").
  // Se guarda aquí para mostrarlo sin tener que buscar el grupo completo.
  final String? grupoNombre;

  // Indica si el trabajador está activo (true) o dado de baja (false).
  // Un trabajador inactivo no puede acceder al sistema.
  final bool activo;

  // NIA: Número de Identificación del trabajador en la organización (código interno).
  // Es opcional porque puede no estar registrado aún.
  final String? nia;

  // DNI del trabajador (documento nacional de identidad).
  // Es opcional porque no siempre se solicita al crear el trabajador.
  final String? dni;

  // Teléfono de contacto del trabajador.
  // Es opcional porque puede no estar registrado.
  final String? telefono;

  // Constructor: crea un Trabajador con sus datos.
  // Los campos marcados con "?" son opcionales.
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

  // copyWith: crea una copia del trabajador cambiando solo los campos que se indiquen.
  // Se usa para actualizar datos sin tener que reescribir todos los campos.
  // Ejemplo: trabajador.copyWith(activo: false) desactiva al trabajador.
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
      // Si se pasa un nuevo valor lo usa; si no, mantiene el valor actual
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

  // fromJson: convierte el JSON que llega del servidor en un objeto Trabajador.
  // El servidor puede usar distintos nombres para el mismo dato (ej: 'id_trab' o 'id'),
  // por eso comprobamos varias claves alternativas.
  factory Trabajador.fromJson(Map<String, dynamic> json) {
    // El servidor llama al id del trabajador 'id_trab'; si no está, buscamos 'id'
    final rawId = json['id_trab'] ?? json['id'];

    // El nombre del grupo puede venir directo como 'grupoNombre' o dentro de un objeto 'grupo'
    final grupoNombre =
        json['grupoNombre'] as String? ??
        (json['grupo'] is Map<String, dynamic>
            ? (json['grupo']['nombre'] as String?)
            : null);

    // El ID del grupo también puede venir de varias formas distintas
    final rawGrupoId = json['grupoId'] ?? json['grupo_id'];
    // Nos aseguramos de que el ID del grupo sea siempre un número entero,
    // sin importar si llega como int, decimal, texto u objeto anidado
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
      // Convertimos el ID a entero sea cual sea el formato en que llegue
      id: rawId is int ? rawId : int.tryParse('$rawId') ?? 0,
      nombre: (json['nombre'] ?? '') as String,
      apellidos: (json['apellidos'] ?? '') as String,
      correo: (json['correo'] ?? '') as String,
      rol: (json['rol'] ?? '') as String,
      grupoId: grupoId,
      grupoNombre: grupoNombre,
      // Si no viene el campo 'activo', asumimos que el trabajador está activo por defecto
      activo: (json['activo'] as bool?) ?? true,
      nia: json['nia'] as String?,
      dni: json['dni'] as String?,
      telefono: json['telefono'] as String?,
    );
  }
}
