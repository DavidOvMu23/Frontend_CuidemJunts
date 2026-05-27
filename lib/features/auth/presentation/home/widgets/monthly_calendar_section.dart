import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/loading_skeleton.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/llamadas.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/calls/widgets/call_detail_dialog.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/home/widgets/call_card.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/llamadas_provider.dart';

// Sección del calendario mensual — muestra un grid con los días del mes
// y marca aquellos que tienen llamadas asignadas con puntos de colores.
// Al pulsar un día con llamadas, abre un diálogo con la lista de esas llamadas.
class MonthlyCalendarSection extends ConsumerStatefulWidget {
  // Lista de llamadas del mes (puede estar cargando, tener error o datos)
  final AsyncValue<List<Llamadas>> callsAsync;
  // Cuando es true, el calendario ocupa todo el espacio disponible (modo escritorio)
  final bool expandContent;

  const MonthlyCalendarSection({
    super.key,
    required this.callsAsync,
    this.expandContent = false,
  });

  @override
  ConsumerState<MonthlyCalendarSection> createState() =>
      _MonthlyCalendarSectionState();
}

class _MonthlyCalendarSectionState
    extends ConsumerState<MonthlyCalendarSection> {
  // El mes que se está mostrando actualmente en el calendario
  late DateTime _focusedMonth;
  // El día que está seleccionado (cuando el usuario pulsa uno con llamadas)
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    // Al iniciar, mostramos el mes actual
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
  }

  // Comprueba si dos fechas corresponden al mismo día (ignorando la hora)
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // Comprueba si una fecha es hoy
  bool _isToday(DateTime d) => _isSameDay(d, DateTime.now());

  // Cuando el usuario pulsa un día del calendario:
  // si tiene llamadas, guarda el día seleccionado y abre el diálogo con ellas
  void _onDayTapped(BuildContext context, DateTime day, List<Llamadas> calls) {
    if (calls.isEmpty) return;
    setState(() => _selectedDay = day);
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => _DayCallsDialog(day: day, calls: calls),
    ).then((_) {
      // Al cerrar el diálogo, quitamos la selección del día
      if (mounted) setState(() => _selectedDay = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.monthlyCalendar,
              style: textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            if (widget.expandContent)
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return widget.callsAsync.when(
                      data: (calls) => _buildGrid(context, calls,
                          availableHeight: constraints.maxHeight,
                          availableWidth: constraints.maxWidth),
                      loading: () =>
                          const AppSkeletonCard(height: double.infinity),
                      error: (_, __) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(l10n.errorCallsLoading),
                      ),
                    );
                  },
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  return widget.callsAsync.when(
                    data: (calls) => _buildGrid(context, calls,
                        availableWidth: constraints.maxWidth),
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: AppSkeletonCard(height: 260),
                    ),
                    error: (_, __) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(l10n.errorCallsLoading),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // Construye el grid del calendario agrupando las llamadas por día
  Widget _buildGrid(BuildContext context, List<Llamadas> calls,
      {double? availableHeight, double? availableWidth}) {
    // Creamos un mapa día→llamadas para acceder rápidamente a las llamadas de cada día
    final Map<int, List<Llamadas>> callsByDay = {};
    int monthCompleted = 0;
    int monthPending = 0;
    int monthNoAnswer = 0;

    for (final c in calls) {
      // Solo incluimos las llamadas que pertenecen al mes que se está mostrando
      if (c.fecha.year == _focusedMonth.year &&
          c.fecha.month == _focusedMonth.month) {
        callsByDay.putIfAbsent(c.fecha.day, () => []).add(c);
        final estado = c.estado.toLowerCase();
        if (estado == CallStatus.completada) {
          monthCompleted++;
        } else if (estado == CallStatus.pendiente) {
          monthPending++;
        } else if (estado == CallStatus.noContesto || estado == CallStatus.cancelada) {
          monthNoAnswer++;
        }
      }
    }

    return _CalendarGrid(
      focusedMonth: _focusedMonth,
      selectedDay: _selectedDay,
      callsByDay: callsByDay,
      isToday: _isToday,
      availableHeight: availableHeight,
      availableWidth: availableWidth,
      monthCompleted: monthCompleted,
      monthPending: monthPending,
      monthNoAnswer: monthNoAnswer,
      onDayTapped: (date, dayCalls) =>
          _onDayTapped(context, date, dayCalls),
      onPrev: () => setState(() => _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
      onNext: () => setState(() => _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
    );
  }
}

// ── Rejilla del calendario: pinta la cabecera con el mes y las filas de días ──

class _CalendarGrid extends StatelessWidget {
  // El mes actualmente visible en pantalla
  final DateTime focusedMonth;
  // El día seleccionado (si hay alguno) para resaltarlo
  final DateTime? selectedDay;
  // Mapa con las llamadas agrupadas por número de día del mes
  final Map<int, List<Llamadas>> callsByDay;
  // Función para comprobar si un día es hoy
  final bool Function(DateTime) isToday;
  // Función que se llama al pulsar un día con llamadas
  final void Function(DateTime day, List<Llamadas> calls) onDayTapped;
  // Funciones para ir al mes anterior o al siguiente
  final VoidCallback onPrev;
  final VoidCallback onNext;
  // Dimensiones disponibles para calcular el tamaño óptimo de cada celda
  final double? availableHeight;
  final double? availableWidth;
  // Conteos totales del mes por estado
  final int monthCompleted;
  final int monthPending;
  final int monthNoAnswer;

  const _CalendarGrid({
    required this.focusedMonth,
    required this.selectedDay,
    required this.callsByDay,
    required this.isToday,
    required this.onDayTapped,
    required this.onPrev,
    required this.onNext,
    this.availableHeight,
    this.availableWidth,
    this.monthCompleted = 0,
    this.monthPending = 0,
    this.monthNoAnswer = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final raw = DateFormat('MMMM yyyy', locale).format(focusedMonth);
    final monthLabel = raw[0].toUpperCase() + raw.substring(1);

    // Calculamos cuántos días tiene el mes y en qué día de la semana empieza
    // para saber cuántas celdas vacías poner al principio
    final daysInMonth =
        DateUtils.getDaysInMonth(focusedMonth.year, focusedMonth.month);
    final firstWeekday =
        DateTime(focusedMonth.year, focusedMonth.month, 1).weekday;
    final totalCells = (firstWeekday - 1) + daysInMonth;
    // Número de filas necesarias para mostrar todos los días en semanas de 7
    final rowCount = (totalCells / 7).ceil();

    final totalMonth = monthCompleted + monthPending + monthNoAnswer;

    // Calcula aspecto dinámico usando el ancho real del contenedor.
    // Hay que descontar TODA la altura no-grid: header (mes + flechas), la fila
    // de pastillas de resumen si está visible, el row de nombres de día y los
    // espacios entre secciones. Si se olvida alguno, la última fila se sale por
    // abajo (el clásico "BOTTOM OVERFLOWED BY N PIXELS" amarillo a rayas).
    const headerH = 36.0;
    const dayNamesH = 22.0;
    const spacingH = 16.0;
    // Fila de _StatPill (padding vertical 3*2 + texto fontSize 11 ≈ 14 + border 2)
    // más la SizedBox(height: 8) que la precede cuando se muestra.
    final statsH = totalMonth > 0 ? 30.0 : 0.0;
    double aspectRatio = 1.3;
    final w = availableWidth;
    if (w != null && w > 0) {
      final cellW = w / 7;
      if (availableHeight != null && availableHeight! > 0) {
        final gridH =
            availableHeight! - headerH - dayNamesH - spacingH - statsH;
        final cellH = (gridH - (rowCount - 1) * 2) / rowCount;
        aspectRatio = (cellW / cellH).clamp(0.5, 4.0);
      } else {
        // Mobile: celdas cuadradas con mínimo de 44px
        final cellH = (cellW / 1.1).clamp(44.0, 90.0);
        aspectRatio = cellW / cellH;
      }
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavButton(icon: Icons.chevron_left, onTap: onPrev),
            Text(monthLabel,
                style: textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700, fontSize: 14)),
            _NavButton(icon: Icons.chevron_right, onTap: onNext),
          ],
        ),
        // ── Resumen mensual ──────────────────────────────────────────────────
        if (totalMonth > 0) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatPill(color: Colors.green.shade400, count: monthCompleted, label: l10n.monthStatsShortCompleted),
              const SizedBox(width: 6),
              _StatPill(color: Colors.orange.shade400, count: monthPending, label: l10n.monthStatsShortPending),
              if (monthNoAnswer > 0) ...[
                const SizedBox(width: 6),
                _StatPill(color: Colors.red.shade400, count: monthNoAnswer, label: l10n.monthStatsShortNoAnswer),
              ],
            ],
          ),
        ],
        const SizedBox(height: 8),
        // ── Nombres de días de la semana ─────────────────────────────────────
        Row(
          children: ['L', 'M', 'X', 'J', 'V', 'S', 'D'].map((d) {
            final isWeekend = d == 'S' || d == 'D';
            return Expanded(
              child: Center(
                child: Text(
                  d,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: isWeekend
                        ? colorScheme.primary.withValues(alpha: 0.5)
                        : colorScheme.onSurface.withValues(alpha: 0.35),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 2,
            crossAxisSpacing: 0,
            childAspectRatio: aspectRatio,
          ),
          itemCount: (firstWeekday - 1) + daysInMonth,
          itemBuilder: (context, index) {
            if (index < firstWeekday - 1) return const SizedBox.shrink();
            final day = index - (firstWeekday - 1) + 1;
            final date = DateTime(focusedMonth.year, focusedMonth.month, day);
            final dayCalls = callsByDay[day] ?? [];
            final selected = selectedDay != null &&
                selectedDay!.year == date.year &&
                selectedDay!.month == date.month &&
                selectedDay!.day == date.day;

            return _DayCell(
              day: day,
              dayCalls: dayCalls,
              isToday: isToday(date),
              isSelected: selected,
              onTap: () => onDayTapped(date, dayCalls),
            );
          },
        ),
      ],
    );
  }
}

// ── Celda individual de un día del calendario ─────────────────────────────────
// Se resalta si es hoy o está seleccionado, y muestra puntos de colores si
// hay llamadas ese día (verde=completada, naranja=pendiente, rojo=no contestada)

class _DayCell extends StatefulWidget {
  // Número del día del mes (1-31)
  final int day;
  // Lista de llamadas que hay en este día
  final List<Llamadas> dayCalls;
  // Indica si este día es el día de hoy
  final bool isToday;
  // Indica si el usuario ha seleccionado este día pulsando sobre él
  final bool isSelected;
  // Función que se llama al pulsar la celda
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.dayCalls,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> {
  // Controla si el ratón está encima de esta celda
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Determinamos si hay alguna llamada en este día para mostrar los puntos
    final hasCalls = widget.dayCalls.isNotEmpty;

    // Calculamos el color de fondo de la celda según su estado
    Color bgColor = Colors.transparent;
    if (widget.isSelected) {
      // Día seleccionado: fondo del color primario (azul/morado)
      bgColor = colorScheme.primary;
    } else if (widget.isToday) {
      // Día de hoy: fondo semitransparente del color primario
      bgColor = colorScheme.primary.withValues(alpha: 0.18);
    } else if (_hovered && hasCalls) {
      // Al pasar el ratón por un día con llamadas, se resalta levemente
      bgColor = colorScheme.primary.withValues(alpha: 0.08);
    }

    final textColor =
        widget.isSelected ? colorScheme.onPrimary : colorScheme.onSurface;

    return MouseRegion(
      cursor:
          hasCalls ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: hasCalls && !widget.isSelected
                ? Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.25),
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.day}',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  fontWeight: widget.isToday || widget.isSelected || hasCalls
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: textColor,
                ),
              ),
              if (hasCalls) ...[
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: _buildDots(widget.dayCalls, widget.isSelected, colorScheme),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Construye los puntos de colores debajo del número del día.
  // Cada color representa un tipo de estado de llamada diferente ese día.
  List<Widget> _buildDots(
      List<Llamadas> calls, bool selected, ColorScheme colorScheme) {
    final dots = <Widget>[];
    // Punto verde si hay alguna llamada completada
    if (calls.any((c) => c.estado == CallStatus.completada)) {
      dots.add(_dot(selected ? Colors.white70 : Colors.green.shade400));
    }
    // Punto naranja si hay alguna llamada pendiente
    if (calls.any((c) => c.estado == CallStatus.pendiente)) {
      dots.add(_dot(selected ? Colors.white70 : Colors.orange.shade400));
    }
    // Punto rojo si hay alguna llamada cancelada o no contestada
    if (calls.any((c) => c.estado == CallStatus.cancelada || c.estado == CallStatus.noContesto)) {
      dots.add(_dot(selected ? Colors.white70 : Colors.red.shade400));
    }
    return dots;
  }

  // Crea un pequeño círculo de color para indicar el estado de las llamadas del día
  Widget _dot(Color color) => Container(
        width: 5,
        height: 5,
        margin: const EdgeInsets.symmetric(horizontal: 1.5),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

// ── Diálogo flotante que aparece al pulsar un día con llamadas ────────────────
// Muestra la lista de llamadas de ese día y permite ver o eliminar cada una.

class _DayCallsDialog extends ConsumerStatefulWidget {
  // El día que se está mostrando
  final DateTime day;
  // Las llamadas de ese día
  final List<Llamadas> calls;

  const _DayCallsDialog({required this.day, required this.calls});

  @override
  ConsumerState<_DayCallsDialog> createState() => _DayCallsDialogState();
}

enum _CallFilter { all, completed, pending, noAnswer }

class _DayCallsDialogState extends ConsumerState<_DayCallsDialog> {
  // Copia local de las llamadas para poder actualizarla si el usuario elimina alguna
  late List<Llamadas> _calls;
  _CallFilter _filter = _CallFilter.all;

  @override
  void initState() {
    super.initState();
    // Hacemos una copia para no modificar la lista original
    _calls = List.from(widget.calls);
  }

  // Abre el diálogo de detalle de una llamada concreta con opciones de editar y eliminar
  void _openDetail(Llamadas llamada) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => CallDetailDialog(
        llamada: llamada,
        onEdit: () {
          // El diálogo de detalle ya se cerró antes de llamar a onEdit
          Navigator.pop(context);  // cierra DayCallsDialog también
          // Marcamos la llamada para que la pantalla de llamadas la abra en modo edición
          ref.read(pendingCallEditProvider.notifier).set(llamada);
        },
        onDelete: () async {
          final service = ref.read(llamadasServiceProvider);
          final scaffoldMsg = ScaffoldMessenger.of(context);
          final nav = Navigator.of(context);
          final navCtx = Navigator.of(ctx);
          try {
            await service.delete(llamada.id);
            // Recargamos la lista de llamadas del proveedor para que los datos estén actualizados
            ref.invalidate(llamadasProvider);
            if (!mounted) return;
            // Quitamos la llamada borrada de la lista local para actualizar la UI sin recargar
            setState(() => _calls.removeWhere((c) => c.id == llamada.id));
            navCtx.pop();
            scaffoldMsg.showSnackBar(SnackBar(content: Text(l10n.callDeletedSuccessfully)));
            // Si ya no quedan llamadas en el día, cerramos también este diálogo
            if (_calls.isEmpty) nav.pop();
          } catch (e) {
            if (!mounted) return;
            scaffoldMsg.showSnackBar(SnackBar(content: Text(l10n.errorDeletingCall(e.toString()))));
          }
        },
      ),
    );
  }

  List<Llamadas> get _filteredCalls {
    switch (_filter) {
      case _CallFilter.completed:
        return _calls.where((c) => c.estado.toLowerCase() == CallStatus.completada).toList();
      case _CallFilter.pending:
        return _calls.where((c) => c.estado.toLowerCase() == CallStatus.pendiente).toList();
      case _CallFilter.noAnswer:
        return _calls.where((c) {
          final e = c.estado.toLowerCase();
          return e == CallStatus.noContesto || e == CallStatus.cancelada;
        }).toList();
      case _CallFilter.all:
        return _calls;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final raw = DateFormat('d MMMM yyyy', locale).format(widget.day);
    final dayLabel = raw[0].toUpperCase() + raw.substring(1);
    final l10n = AppLocalizations.of(context)!;

    final hasCompleted = _calls.any((c) => c.estado.toLowerCase() == CallStatus.completada);
    final hasPending = _calls.any((c) => c.estado.toLowerCase() == CallStatus.pendiente);
    final hasNoAnswer = _calls.any((c) {
      final e = c.estado.toLowerCase();
      return e == CallStatus.noContesto || e == CallStatus.cancelada;
    });
    final showFilterRow = hasCompleted && (hasPending || hasNoAnswer) ||
        hasPending && (hasCompleted || hasNoAnswer);

    final visible = _filteredCalls;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Cabecera ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.calendar_today_rounded,
                          size: 16, color: colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dayLabel,
                              style: textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          Text(
                            l10n.dayCallsCountHeader(_calls.length),
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded,
                          size: 20,
                          color: colorScheme.onSurface.withValues(alpha: 0.45)),
                      onPressed: () => Navigator.of(context).pop(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: colorScheme.onSurface.withValues(alpha: 0.08)),

              // ── Chips de filtro (solo si hay más de un estado) ─────────────
              if (showFilterRow)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: l10n.all,
                          selected: _filter == _CallFilter.all,
                          color: colorScheme.primary,
                          onTap: () => setState(() => _filter = _CallFilter.all),
                        ),
                        if (hasCompleted) ...[
                          const SizedBox(width: 6),
                          _FilterChip(
                            label: l10n.callCompleted,
                            selected: _filter == _CallFilter.completed,
                            color: Colors.green.shade400,
                            onTap: () => setState(() => _filter = _CallFilter.completed),
                          ),
                        ],
                        if (hasPending) ...[
                          const SizedBox(width: 6),
                          _FilterChip(
                            label: l10n.callPending,
                            selected: _filter == _CallFilter.pending,
                            color: Colors.orange.shade400,
                            onTap: () => setState(() => _filter = _CallFilter.pending),
                          ),
                        ],
                        if (hasNoAnswer) ...[
                          const SizedBox(width: 6),
                          _FilterChip(
                            label: l10n.callNoAnswer,
                            selected: _filter == _CallFilter.noAnswer,
                            color: Colors.red.shade400,
                            onTap: () => setState(() => _filter = _CallFilter.noAnswer),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

              // ── Lista de llamadas ────────────────────────────────────────────
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: visible.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.noCallsWithStatus,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: visible.length,
                        itemBuilder: (context, i) => InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _openDetail(visible[i]),
                          child: CallCard(
                            usuarioNombre: visible[i].usuarioNombre,
                            usuarioApellidos: visible[i].usuarioApellidos,
                            grupoNombre: visible[i].grupoNombre,
                            hora: visible[i].hora,
                            estado: visible[i].estado,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Chip de filtro para el diálogo de llamadas del día ────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.35),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? color : color.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

// ── Pastilla de estadística mensual (color + número + etiqueta) ───────────────

class _StatPill extends StatelessWidget {
  final Color color;
  final int count;
  final String label;

  const _StatPill({required this.color, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            '$count $label',
            style: textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Botón de navegación para cambiar de mes (flecha izquierda/derecha) ────────

class _NavButton extends StatefulWidget {
  // El icono que se mostrará (flecha izquierda o derecha)
  final IconData icon;
  // Función que se llama al pulsar el botón para cambiar el mes
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  // Controla si el ratón está encima del botón para resaltarlo
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _hovered
                ? colorScheme.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(widget.icon,
              size: 20,
              color: colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}
