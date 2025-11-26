import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Sección de filtro por fecha con campos "Fecha Desde" y "Fecha Hasta"
class DateFilterSection extends StatelessWidget {
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;
  final ValueChanged<DateTime?> onFechaDesdeChanged;
  final ValueChanged<DateTime?> onFechaHastaChanged;

  const DateFilterSection({
    super.key,
    this.fechaDesde,
    this.fechaHasta,
    required this.onFechaDesdeChanged,
    required this.onFechaHastaChanged,
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () =>
                        _selectDate(context, fechaDesde, onFechaDesdeChanged),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          width: 1.5,
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
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Fecha Hasta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha Hasta',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () =>
                        _selectDate(context, fechaHasta, onFechaHastaChanged),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          width: 1.5,
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
