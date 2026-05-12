import 'package:flutter/material.dart';

class Notificacion {
  final int id;
  final String? titulo;
  final String contenido;
  final String estado;
  final String tipo;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Notificacion({
    required this.id,
    this.titulo,
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
      titulo: json['titulo'] as String?,
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

  bool get esLeida => estado == 'leida';
  bool get esSinLeer => estado == 'sin_leer';
  bool get esArchivada => estado == 'archivada';
  bool get esCancelada => estado == 'cancelada';

  String get tipoLegible {
    switch (tipo) {
      case 'call':
        return 'Llamada';
      case 'system':
        return 'Sistema';
      case 'supervision':
        return 'Supervisión';
      default:
        return tipo;
    }
  }

  IconData get tipoIcono {
    switch (tipo) {
      case 'call':
        return Icons.call_outlined;
      case 'system':
        return Icons.settings_outlined;
      case 'supervision':
        return Icons.supervisor_account_outlined;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  String get estadoColor {
    if (esSinLeer) return 'primary';
    if (esLeida) return 'onSurface';
    if (esArchivada) return 'outlineVariant';
    return 'secondary';
  }
}
