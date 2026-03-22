import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Sección de filtro por fecha con campos "Fecha Desde" y "Fecha Hasta"
class DateFilterSection extends StatelessWidget {
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;
  final ValueChanged<DateTime?> onFechaDesdeChanged;
  final ValueChanged<DateTime?> onFechaHastaChanged;
  final VoidCallback? onClearDates;

  const DateFilterSection({
    super.key,
    this.fechaDesde,
    this.fechaHasta,
    required this.onFechaDesdeChanged,
    required this.onFechaHastaChanged,
    this.onClearDates,
  });

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
    final dateFormat = DateFormat('dd/MM/yy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Filtrar por fecha:',
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
                  'Quitar filtro',
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
        Row(
          children: [
            // Fecha Desde
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha Desde',
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
                    'Fecha Hasta',
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
                            : 'Hoy',
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
        ),
      ],
    );
  }
}
