// -------- CONTACTO EMERGENCIA MODEL --------

// Este modelo representa un contacto de emergencia. y lo que hace es que al recibir un json, sepa como convertir cada elemento del json a un objeto ContactoEmergencia.
class ContactoEmergencia {
  final int id;
  final String nombre;
  final String apellidos;
  final String telefono;
  final String direccion;
  final String? dniUsuarioRef;
  final List<String> usuariosDnis;
  final String? pacienteNombre;

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

  // Constructor que recibe un json y lo convierte en un objeto ContactoEmergencia.
  factory ContactoEmergencia.fromJson(Map<String, dynamic> json) {
    return ContactoEmergencia(
      id: (json['id_cont'] as num?)?.toInt() ?? 0,
      nombre: json['nombre'] as String? ?? '',
      apellidos: json['apellidos'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      direccion: json['direccion'] as String? ?? '',
      dniUsuarioRef:
          json['dni_usuario_ref'] as String? ??
          json['dniUsuarioRef'] as String? ??
          (json['usuarioReferenciado'] is Map<String, dynamic>
              ? (json['usuarioReferenciado']['dni'] as String?)
              : null),
      usuariosDnis: (json['usuariosDnis'] as List<dynamic>?)
          ?.whereType<String>()
          .toList(growable: false) ??
        const [],
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

// Este modelo representa un usuario. y lo que hace es que al recibir un json, sepa como convertir cada elemento del json a un objeto Usuario.
class Usuario {
  final String dni;
  final String nombre;
  final String apellidos;
  final DateTime f_nac;
  final String telefono;
  final String direccion;
  final String estadoCuenta;
  final String nivelDependencia;
  final String informacion;
  final String? datosMedicosDolencias;
  final String? medicacion;
  final List<ContactoEmergencia> contactosEmergencia;

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

  // copyWith crea una copia del objeto Usuario con los valores proporcionados.
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

  // fromJson crea un objeto Usuario a partir de un json.
  factory Usuario.fromJson(Map<String, dynamic> json) {
    final fechaRaw =
        json['f_nac'] ??
        json['fecha'] ??
        json['fechaNacimiento'] ??
        json['fecha_nacimiento'];
    final parsedFecha = _parseFecha(fechaRaw);
    final contactosRaw = json['contactosEmergencia'] as List<dynamic>?;
    return Usuario(
      dni: json['dni'] as String,
      nombre: json['nombre'] as String,
      apellidos: json['apellidos'] as String,
      f_nac: parsedFecha,
      telefono: json['telefono'] as String,
        direccion: (json['direccion'] ?? json['address'] ?? '') as String,
      estadoCuenta: json['estado_cuenta'] as String,
      nivelDependencia: json['nivel_dependencia'] as String? ?? '',
      informacion: json['informacion'] as String? ?? '',
      datosMedicosDolencias: json['datos_medicos_dolencias'] as String?,
      medicacion: json['medicacion'] as String?,
          contactosEmergencia:
          contactosRaw
              ?.whereType<Map<String, dynamic>>()
              .map(ContactoEmergencia.fromJson)
              .toList(growable: false) ??
          const [],
    );
  }

  // _parseFecha convierte una fecha en un objeto DateTime.
  static DateTime _parseFecha(dynamic rawFecha) {
    if (rawFecha == null) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    if (rawFecha is int) {
      return DateTime.fromMillisecondsSinceEpoch(rawFecha);
    }

    if (rawFecha is double) {
      return DateTime.fromMillisecondsSinceEpoch(rawFecha.toInt());
    }

    final fechaComoCadena = rawFecha.toString().trim();
    if (fechaComoCadena.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DateTime.tryParse(fechaComoCadena) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }
}
