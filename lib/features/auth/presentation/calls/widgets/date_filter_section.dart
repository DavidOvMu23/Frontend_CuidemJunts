import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

// Sección de filtro por fecha con campos "Fecha Desde" y "Fecha Hasta".
// Permite al supervisor buscar llamadas dentro de un rango de fechas concreto.
class DateFilterSection extends StatelessWidget {
  // La fecha de inicio del rango (puede ser nula si no se ha seleccionado)
  final DateTime? fechaDesde;
  // La fecha de fin del rango (puede ser nula si no se ha seleccionado)
  final DateTime? fechaHasta;
  // Funciones que se llaman cuando el usuario cambia alguna fecha
  final ValueChanged<DateTime?> onFechaDesdeChanged;
  final ValueChanged<DateTime?> onFechaHastaChanged;
  // Función para borrar el filtro de fechas; es nula cuando no hay fechas activas
  final VoidCallback? onClearDates;
  // Controla si usar el diseño de escritorio (campos en fila) o móvil (en columna)
  final bool isDesktop;

  const DateFilterSection({
    super.key,
    this.fechaDesde,
    this.fechaHasta,
    required this.onFechaDesdeChanged,
    required this.onFechaHastaChanged,
    this.onClearDates,
    this.isDesktop = false,
  });

  // Abre el selector de fecha del sistema operativo y, si el usuario elige una,
  // llama a onChanged para actualizar el valor en la pantalla padre
  Future<void> _selectDate(
    BuildContext context,
    DateTime? currentDate,
    ValueChanged<DateTime?> onChanged,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    // Formato de fecha que se mostrará en los botones (día/mes/año corto)
    final dateFormat = DateFormat('dd/MM/yy');

    // Los dos botones de fecha se agrupan en una misma fila
    final dateInputs = Row(
      children: [
        // Campo para seleccionar la fecha de inicio del rango
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.initDate,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: () =>
                    _selectDate(context, fechaDesde, onFechaDesdeChanged),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    fechaDesde != null
                        ? dateFormat.format(fechaDesde!)
                        : 'DD/MM/AA',
                    style: textTheme.bodyMedium?.copyWith(
                      color: fechaDesde != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Fecha Hasta
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.endDate,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: () =>
                    _selectDate(context, fechaHasta, onFechaHastaChanged),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    fechaHasta != null
                        ? dateFormat.format(fechaHasta!)
                        : l10n.today,
                    style: textTheme.bodyMedium?.copyWith(
                      color: fechaHasta != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    // En escritorio se muestra el botón "Quitar filtro" al lado del título para ahorrar espacio
    if (isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.filterDate,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 12),
              // Solo se muestra el botón de limpiar si hay alguna fecha seleccionada
              if ((fechaDesde != null || fechaHasta != null) &&
                  onClearDates != null)
                TextButton.icon(
                  onPressed: onClearDates,
                  icon: Icon(Icons.clear, color: colorScheme.error),
                  label: Text(
                    l10n.removeFilter,
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    minimumSize: const Size(0, 32),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          dateInputs,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.filterDate,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
        // Botón para quitar filtro de fecha (debajo del título, alineado a la derecha)
        if ((fechaDesde != null || fechaHasta != null) && onClearDates != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onClearDates,
                icon: Icon(Icons.clear, color: colorScheme.error),
                label: Text(
                  l10n.removeFilter,
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  minimumSize: Size(0, 32),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        dateInputs,
      ],
    );
  }
}
