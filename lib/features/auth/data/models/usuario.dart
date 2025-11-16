class ContactoEmergencia {
  final int id;
  final String nombre;
  final String apellidos;
  final String telefono;
  final String relacion;
  final String? dniUsuarioRef;

  const ContactoEmergencia({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.telefono,
    required this.relacion,
    this.dniUsuarioRef,
  });

  factory ContactoEmergencia.fromJson(Map<String, dynamic> json) {
    return ContactoEmergencia(
      id: (json['id_cont'] as num?)?.toInt() ?? 0,
      nombre: json['nombre'] as String? ?? '',
      apellidos: json['apellidos'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      relacion: json['relacion'] as String? ?? '',
      dniUsuarioRef:
          json['dni_usuario_ref'] as String? ??
          json['dniUsuarioRef'] as String? ??
          (json['usuarioReferenciado'] is Map<String, dynamic>
              ? (json['usuarioReferenciado']['dni'] as String?)
              : null),
    );
  }
}

class Usuario {
  final String dni;
  final String nombre;
  final String apellidos;
  final DateTime f_nac;
  final String telefono;
  final String direccion;
  final String estadoCuenta;
  final String nivelDependencia;
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
    this.contactosEmergencia = const [],
  });

  Usuario copyWith({
    String? dni,
    String? nombre,
    String? apellidos,
    DateTime? f_nac,
    String? telefono,
    String? direccion,
    String? estadoCuenta,
    String? nivelDependencia,
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
      contactosEmergencia: contactosEmergencia ?? this.contactosEmergencia,
    );
  }

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
      contactosEmergencia:
          contactosRaw
              ?.whereType<Map<String, dynamic>>()
              .map(ContactoEmergencia.fromJson)
              .toList(growable: false) ??
          const [],
    );
  }

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
