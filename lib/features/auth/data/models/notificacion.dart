import 'package:flutter/material.dart';

// -------- NOTIFICACION MODEL --------

class Notificacion {
  final int id;
  final String contenido;
  final String estado;
  final String tipo;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Notificacion({
    required this.id,
    required this.contenido,
    required this.estado,
    required this.tipo,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id_not'] as int,
      contenido: json['contenido'] as String,
      estado: json['estado'] as String,
      tipo: json['tipo'] as String? ?? '',
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  // Getters de ayuda para identificar el estado
  bool get esLeida => estado == 'leida';
  bool get esSinLeer => estado == 'sin_leer';
  bool get esArchivada => estado == 'archivada';
  bool get esCancelada => estado == 'cancelada';

  // Getter para texto legible del tipo
  String get tipoLegible {
    const tipoMap = {
      'usuario_nuevo': 'Usuario Nuevo',
      'llamada_pending': 'Llamada Pendiente',
      'contacto_asignado': 'Contacto Asignado',
      'supervisor_asignado': 'Supervisor Asignado',
      'mensaje': 'Mensaje',
      'alerta': 'Alerta',
    };
    return tipoMap[tipo] ?? '';
  }

  // Getter para icono del tipo
  IconData get tipoIcono {
    const tipoIconMap = {
      'usuario_nuevo': Icons.person_add_alt_1_outlined,
      'llamada_pending': Icons.call_outlined,
      'contacto_asignado': Icons.push_pin_outlined,
      'supervisor_asignado': Icons.badge_outlined,
      'mensaje': Icons.chat_bubble_outline,
      'alerta': Icons.warning_amber_outlined,
    };
    return tipoIconMap[tipo] ?? Icons.notifications_none_outlined;
  }

  // Getter para color del estado (puedes usarlo en UI)
  String get estadoColor {
    if (esSinLeer) return 'primary';
    if (esLeida) return 'onSurface';
    if (esArchivada) return 'outlineVariant';
    return 'secondary';
  }
}
