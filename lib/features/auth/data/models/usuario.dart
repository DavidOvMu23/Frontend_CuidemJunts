// -------- CONTACTO EMERGENCIA MODEL --------

// Este modelo representa a una persona de contacto en caso de emergencia
// (por ejemplo, un familiar o cuidador de confianza del paciente).
// Cuando el servidor nos manda información en formato JSON, este modelo
// sabe cómo convertirla en un objeto que la app puede usar.
class ContactoEmergencia {
  // Número identificador único de este contacto en la base de datos del servidor
  final int id;

  // Nombre de pila del contacto de emergencia (ej: "María")
  final String nombre;

  // Apellidos del contacto de emergencia (ej: "García López")
  final String apellidos;

  // Número de teléfono al que llamar en una emergencia
  final String telefono;

  // Dirección postal del contacto (puede ser útil para visitas o envíos)
  final String direccion;

  // DNI del usuario (paciente) al que está vinculado este contacto.
  // Es opcional porque puede que el contacto aún no tenga un paciente asignado.
  final String? dniUsuarioRef;

  // Lista de DNIs de todos los usuarios/pacientes que tienen a este contacto.
  // Permite que un mismo contacto esté asociado a varios pacientes.
  final List<String> usuariosDnis;

  // Nombre completo del paciente vinculado a este contacto.
  // Se calcula a partir del objeto usuario del servidor; es opcional.
  final String? pacienteNombre;

  // Constructor: crea un ContactoEmergencia con los datos obligatorios y opcionales.
  // Los campos con "?" o con valor por defecto son opcionales al crear el objeto.
  ContactoEmergencia({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.direccion,
    required this.telefono,
    this.dniUsuarioRef,
    this.usuariosDnis = const [],
    this.pacienteNombre,
  });

  // Constructor especial que convierte un JSON del servidor en un objeto ContactoEmergencia.
  // El servidor puede enviar los datos con distintos nombres de campo (ej: 'id_cont' o 'id'),
  // por eso buscamos varias claves alternativas con el operador ??.
  factory ContactoEmergencia.fromJson(Map<String, dynamic> json) {
    return ContactoEmergencia(
      // El servidor llama al id 'id_cont'; si no existe, buscamos 'id'; si tampoco, usamos 0
      id: (json['id_cont'] as num?)?.toInt() ?? 0,
      nombre: json['nombre'] as String? ?? '',
      apellidos: json['apellidos'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      direccion: json['direccion'] as String? ?? '',
      // El DNI del usuario puede venir de tres formas distintas según el endpoint del servidor
      dniUsuarioRef:
          json['dni_usuario_ref'] as String? ??
          json['dniUsuarioRef'] as String? ??
          (json['usuarioReferenciado'] is Map<String, dynamic>
              ? (json['usuarioReferenciado']['dni'] as String?)
              : null),
      // Lista de DNIs de pacientes vinculados; filtramos solo los que son texto válido
      usuariosDnis: (json['usuariosDnis'] as List<dynamic>?)
          ?.whereType<String>()
          .toList(growable: false) ??
        const [],
      // El nombre del paciente puede venir directo o hay que construirlo uniendo nombre + apellidos
      pacienteNombre:
          json['pacienteNombre'] as String? ??
          (json['usuarioReferenciado'] is Map<String, dynamic>
              ? '${json['usuarioReferenciado']['nombre'] ?? ''} ${json['usuarioReferenciado']['apellidos'] ?? ''}'
                    .trim()
                    .replaceAll(RegExp(r'^\s+|\s+$'), '')
              : null),
    );
  }
}

// -------- USUARIO MODEL --------

// Este modelo representa a un usuario/paciente del sistema CuidemJunts.
// Guarda toda la información personal, médica y de contacto de la persona atendida.
// Cuando el servidor responde con datos JSON, este modelo sabe cómo interpretarlos.
class Usuario {
  // DNI del paciente — es el identificador principal (único para cada persona)
  final String dni;

  // Nombre de pila del paciente (ej: "Joan")
  final String nombre;

  // Apellidos del paciente (ej: "Puig Martí")
  final String apellidos;

  // Fecha de nacimiento del paciente — se usa para calcular la edad o mostrarla
  final DateTime f_nac;

  // Teléfono de contacto directo del paciente
  final String telefono;

  // Dirección postal del paciente (donde vive)
  final String direccion;

  // Estado de la cuenta del paciente en el sistema (ej: "activo", "inactivo")
  final String estadoCuenta;

  // Nivel de dependencia del paciente (ej: "leve", "moderado", "severo")
  // Indica cuánta ayuda necesita para sus actividades diarias
  final String nivelDependencia;

  // Información adicional general sobre el paciente (notas, observaciones)
  final String informacion;

  // Información médica sobre dolencias o enfermedades del paciente.
  // Es opcional porque no todos los pacientes tienen esta información registrada.
  final String? datosMedicosDolencias;

  // Medicación que toma el paciente.
  // Es opcional porque no todos los pacientes toman medicación.
  final String? medicacion;

  // Lista de contactos de emergencia asociados a este paciente
  final List<ContactoEmergencia> contactosEmergencia;

  // Constructor: crea un Usuario con sus datos.
  // Los campos con valor por defecto ('') o con "?" son opcionales.
  const Usuario({
    required this.dni,
    required this.nombre,
    required this.apellidos,
    required this.f_nac,
    required this.telefono,
    this.direccion = '',
    required this.estadoCuenta,
    required this.nivelDependencia,
    this.informacion = '',
    this.datosMedicosDolencias,
    this.medicacion,
    this.contactosEmergencia = const [],
  });

  // copyWith: crea una copia de este usuario cambiando solo los campos que se indiquen.
  // Se usa cuando queremos actualizar un usuario sin tener que repetir todos sus datos.
  // Por ejemplo: usuario.copyWith(telefono: '600123456') cambia solo el teléfono.
  Usuario copyWith({
    String? dni,
    String? nombre,
    String? apellidos,
    DateTime? f_nac,
    String? telefono,
    String? direccion,
    String? estadoCuenta,
    String? nivelDependencia,
    String? informacion,
    String? datosMedicosDolencias,
    String? medicacion,
    List<ContactoEmergencia>? contactosEmergencia,
  }) {
    return Usuario(
      // Si se pasa un nuevo valor lo usa; si no, mantiene el valor actual
      dni: dni ?? this.dni,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      f_nac: f_nac ?? this.f_nac,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      estadoCuenta: estadoCuenta ?? this.estadoCuenta,
      nivelDependencia: nivelDependencia ?? this.nivelDependencia,
      informacion: informacion ?? this.informacion,
      datosMedicosDolencias:
          datosMedicosDolencias ?? this.datosMedicosDolencias,
      medicacion: medicacion ?? this.medicacion,
      contactosEmergencia: contactosEmergencia ?? this.contactosEmergencia,
    );
  }

  // fromJson: convierte el JSON que llega del servidor en un objeto Usuario.
  // El servidor puede usar distintos nombres para la fecha de nacimiento,
  // por eso probamos varias claves (f_nac, fecha, fechaNacimiento, fecha_nacimiento).
  factory Usuario.fromJson(Map<String, dynamic> json) {
    // Buscamos la fecha de nacimiento probando los distintos nombres que puede usar el servidor
    final fechaRaw =
        json['f_nac'] ??
        json['fecha'] ??
        json['fechaNacimiento'] ??
        json['fecha_nacimiento'];
    // Convertimos ese valor (sea texto, número o nulo) en un objeto DateTime
    final parsedFecha = _parseFecha(fechaRaw);
    // Extraemos la lista de contactos de emergencia del JSON (puede ser null)
    final contactosRaw = json['contactosEmergencia'] as List<dynamic>?;
    return Usuario(
      dni: json['dni'] as String,
      nombre: json['nombre'] as String,
      apellidos: json['apellidos'] as String,
      f_nac: parsedFecha,
      telefono: json['telefono'] as String,
      // La dirección puede venir como 'direccion' o 'address' según el endpoint
      direccion: (json['direccion'] ?? json['address'] ?? '') as String,
      estadoCuenta: json['estado_cuenta'] as String,
      nivelDependencia: json['nivel_dependencia'] as String? ?? '',
      informacion: json['informacion'] as String? ?? '',
      datosMedicosDolencias: json['datos_medicos_dolencias'] as String?,
      medicacion: json['medicacion'] as String?,
      // Convertimos cada elemento de la lista de contactos en un objeto ContactoEmergencia
      contactosEmergencia:
          contactosRaw
              ?.whereType<Map<String, dynamic>>()
              .map(ContactoEmergencia.fromJson)
              .toList(growable: false) ??
          const [],
    );
  }

  // _parseFecha: convierte cualquier formato de fecha en un DateTime.
  // Es necesario porque el servidor puede enviar la fecha como texto "2000-01-15",
  // como número de milisegundos, o incluso como nulo si no está registrada.
  static DateTime _parseFecha(dynamic rawFecha) {
    // Si no hay fecha, devolvemos el inicio del tiempo (1 de enero de 1970) como valor neutro
    if (rawFecha == null) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    // Si la fecha viene como número entero, es una marca de tiempo en milisegundos
    if (rawFecha is int) {
      return DateTime.fromMillisecondsSinceEpoch(rawFecha);
    }

    // Si la fecha viene como número decimal, la convertimos a entero primero
    if (rawFecha is double) {
      return DateTime.fromMillisecondsSinceEpoch(rawFecha.toInt());
    }

    // Si viene como texto, intentamos interpretarlo directamente (ej: "2000-01-15T00:00:00")
    final fechaComoCadena = rawFecha.toString().trim();
    if (fechaComoCadena.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    // tryParse convierte el texto en DateTime; si falla, devuelve null y usamos el valor neutro
    return DateTime.tryParse(fechaComoCadena) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }
}
