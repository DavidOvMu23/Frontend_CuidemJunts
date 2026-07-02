import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';

import 'package:frontend_cuidemjunts/features/auth/data/models/llamadas.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';

// Ventana emergente (diálogo) que muestra todos los detalles de una llamada
// y permite editarla o eliminarla.
class CallDetailDialog extends StatelessWidget {
  // Los datos de la llamada a mostrar
  final Llamadas llamada;
  // Función opcional que se llama si el usuario pulsa "Eliminar"
  final VoidCallback? onDelete;
  // Función opcional que se llama si el usuario pulsa el botón de editar
  final VoidCallback? onEdit;

  const CallDetailDialog({
    super.key,
    required this.llamada,
    this.onDelete,
    this.onEdit,
  });

  // Muestra un segundo diálogo de confirmación antes de borrar la llamada,
  // para evitar eliminaciones accidentales
  void _confirmarEliminacion(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteCall),
        content: Text(l10n.deleteCallConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          general_deletebutton(
            ctx,
            l10n.delete,
            onPressed: () {
              Navigator.pop(ctx);
              if (onDelete != null) onDelete!();
            },
          ),
        ],
      ),
    );
  }

  // Crea una fila reutilizable con icono, etiqueta y valor para mostrar
  // cada campo del detalle (fecha, duración, grupo, etc.)
  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurface),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
        // Convierte el estado interno (como "no_contesto") en un texto legible para el usuario
        String estadoLegible(String estado) {
          final l10n = AppLocalizations.of(context)!;
          switch (estado.trim().toLowerCase()) {
            case CallStatus.completada:
              return l10n.callCompleted;
            case CallStatus.pendiente:
              return l10n.callPending;
            case CallStatus.noContesto:
            case 'no contestó':
            case 'no contestada':
              return l10n.callNoAnswer;
            default:
              return estado;
          }
        }
    // ...existing code...
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(
              llamada.resumen.isNotEmpty ? llamada.resumen : l10n.calls,
              style: textTheme.headlineLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
              softWrap: true,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
              if (onEdit != null) onEdit!();
            },
            icon: const Icon(Icons.edit, size: 20),
            tooltip: l10n.edit,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              if (llamada.usuarioNombre != null && llamada.usuarioNombre!.isNotEmpty)
                _buildDetailRow(
                  context,
                  Icons.person_outline,
                  l10n.user,
                  llamada.usuarioApellidos != null && llamada.usuarioApellidos!.isNotEmpty
                      ? '${llamada.usuarioNombre} ${llamada.usuarioApellidos}'
                      : llamada.usuarioNombre!,
                ),
              _buildDetailRow(
                context,
                Icons.calendar_today,
                l10n.date,
                '${llamada.fecha.day.toString().padLeft(2, '0')}/${llamada.fecha.month.toString().padLeft(2, '0')}/${llamada.fecha.year}',
              ),
              _buildDetailRow(
                context,
                Icons.timer,
                l10n.duration,
                llamada.duracion,
              ),
              _buildDetailRow(
                context,
                Icons.group,
                l10n.group_label,
                llamada.grupoNombre?.isNotEmpty == true ? llamada.grupoNombre! : l10n.noGroupAssigned,
              ),
              _buildDetailRow(
                context,
                Icons.support_agent,
                l10n.supervisorInfoForOperator,
                llamada.informacionSupervisor.isNotEmpty ? llamada.informacionSupervisor : '-',
              ),
              _buildDetailRow(
                context,
                Icons.info_outline,
                l10n.comments,
                llamada.observaciones.isNotEmpty ? llamada.observaciones : '-',
              ),
              _buildDetailRow(
                context,
                Icons.verified_user,
                l10n.callStatus,
                llamada.estado.isNotEmpty ? estadoLegible(llamada.estado) : l10n.noStatus,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close),
        ),
        general_deletebutton(
          context,
          l10n.delete,
          onPressed: () => _confirmarEliminacion(context),
        ),
      ],
    );
  }
}
