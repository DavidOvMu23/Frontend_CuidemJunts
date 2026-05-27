import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

// -------- NOTIFICACION MODEL --------

// Este modelo representa una notificación del sistema CuidemJunts.
// Las notificaciones avisan a los teleoperadores de eventos importantes:
// llamadas perdidas, alertas del sistema, avisos de supervisión, etc.
// Cuando el servidor manda datos JSON, este modelo sabe cómo interpretarlos.
class Notificacion {
  // Número identificador único de la notificación en la base de datos
  final int id;

  // Título corto de la notificación (ej: "Llamada perdida").
  // Es opcional porque algunas notificaciones pueden no tener título.
  final String? titulo;

  // Texto principal de la notificación — explica qué ha pasado con más detalle
  final String contenido;

  // Estado de la notificación: indica si el usuario la ha visto o no.
  // Valores posibles: 'sin_leer', 'leida', 'archivada', 'cancelada'
  final String estado;

  // Tipo de notificación: clasifica de qué trata.
  // Valores posibles: 'call' (llamada), 'system' (sistema), 'supervision' (supervisión)
  final String tipo;

  // Datos extra en formato libre que el servidor puede adjuntar a la notificación.
  // Por ejemplo: el ID de la llamada relacionada, el nombre del paciente, etc.
  // Es opcional porque no todas las notificaciones tienen datos extra.
  final Map<String, dynamic>? metadata;

  // Fecha y hora exacta en que se creó la notificación en el servidor
  final DateTime createdAt;

  // Fecha y hora de la última vez que se modificó la notificación
  // (por ejemplo, cuando se marcó como leída)
  final DateTime updatedAt;

  // Constructor: crea una Notificacion con sus datos.
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

  // fromJson: convierte el JSON que llega del servidor en un objeto Notificacion.
  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      // El servidor llama al ID 'id_not'
      id: json['id_not'] as int,
      titulo: json['titulo'] as String?,
      contenido: json['contenido'] as String,
      estado: json['estado'] as String,
      // Si no viene el tipo, usamos texto vacío como valor seguro
      tipo: json['tipo'] as String? ?? '',
      metadata: json['metadata'] as Map<String, dynamic>?,
      // Si no viene la fecha de creación, usamos la hora actual como aproximación
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  // -------- PROPIEDADES CALCULADAS --------
  // Estas propiedades no vienen del servidor; las calculamos a partir del campo 'estado'.
  // Son atajos para que el resto de la app no tenga que comparar texto manualmente.

  // Devuelve true si la notificación ya fue leída por el usuario
  bool get esLeida => estado == 'leida';

  // Devuelve true si la notificación aún no ha sido vista
  bool get esSinLeer => estado == 'sin_leer';

  // Devuelve true si la notificación fue archivada (guardada pero ya procesada)
  bool get esArchivada => estado == 'archivada';

  // Devuelve true si la notificación fue cancelada antes de ser vista
  bool get esCancelada => estado == 'cancelada';

  // tipoLegible: convierte el código interno del tipo en un texto entendible
  // por el usuario, traducido al idioma activo. El servidor guarda 'call',
  // 'system', etc., pero en la pantalla mostramos "Llamada"/"Trucada"/"Call"…
  String tipoLegible(AppLocalizations l10n) {
    switch (tipo) {
      case 'call':
        return l10n.notifTypeCall;
      case 'system':
        return l10n.notifTypeSystem;
      case 'supervision':
        return l10n.notifTypeSupervision;
      default:
        // Si es un tipo desconocido, mostramos el código tal cual
        return tipo;
    }
  }

  // tipoIcono: devuelve el icono visual que corresponde a cada tipo de notificación.
  // Se usa en la interfaz para que el usuario reconozca el tipo de un vistazo.
  IconData get tipoIcono {
    switch (tipo) {
      case 'call':
        // Icono de teléfono para notificaciones de llamada
        return Icons.call_outlined;
      case 'system':
        // Icono de engranaje para notificaciones del sistema
        return Icons.settings_outlined;
      case 'supervision':
        // Icono de persona supervisando para notificaciones de supervisión
        return Icons.supervisor_account_outlined;
      default:
        // Icono genérico de notificación para tipos no reconocidos
        return Icons.notifications_none_outlined;
    }
  }

  // estadoColor: devuelve el nombre del color del tema que corresponde a cada estado.
  // Esto permite que la interfaz coloree la notificación según si está leída o no.
  String get estadoColor {
    // Las no leídas se resaltan con el color principal (azul, por ejemplo)
    if (esSinLeer) return 'primary';
    // Las leídas usan un color neutro (texto sobre fondo)
    if (esLeida) return 'onSurface';
    // Las archivadas usan un color tenue para indicar que ya no son urgentes
    if (esArchivada) return 'outlineVariant';
    // Para cualquier otro estado (cancelada, etc.) usamos el color secundario
    return 'secondary';
  }
}
