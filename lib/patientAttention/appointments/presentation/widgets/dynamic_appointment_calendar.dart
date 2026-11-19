import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment.dart';
import 'package:flutter/material.dart';

/// Calendario dinámico mensual minimalista que se actualiza automáticamente
/// al reservar, iniciar, atender, cancelar o reprogramar citas.
class DynamicAppointmentCalendar extends StatefulWidget {
  final List<Appointment> appointments;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;

  const DynamicAppointmentCalendar({
    super.key,
    required this.appointments,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<DynamicAppointmentCalendar> createState() =>
      _DynamicAppointmentCalendarState();
}

class _DynamicAppointmentCalendarState
    extends State<DynamicAppointmentCalendar> {
  late DateTime _focusedMonth;
  bool _collapsed = false;

  static const List<String> _months = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  static const List<String> _weekDays = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  void initState() {
    super.initState();
    final ref = widget.selectedDate ?? DateTime.now();
    _focusedMonth = DateTime(ref.year, ref.month);
  }

  Map<String, List<Appointment>> _groupByDay() {
    final map = <String, List<Appointment>>{};
    for (final a in widget.appointments) {
      final dt = a.startDateTime;
      if (dt == null) continue;
      final key = '${dt.year}-${dt.month}-${dt.day}';
      map.putIfAbsent(key, () => []).add(a);
    }
    return map;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final grouped = _groupByDay();

    final firstOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final leadingEmpty = firstOfMonth.weekday - 1; // Lunes = 0

    final cells = <DateTime?>[
      ...List<DateTime?>.filled(leadingEmpty, null),
      for (int d = 1; d <= daysInMonth; d++)
        DateTime(_focusedMonth.year, _focusedMonth.month, d),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded,
                  size: 17, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${_months[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.selectedDate != null)
                TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: const Size(0, 28),
                  ),
                  onPressed: () => widget.onDateSelected(null),
                  child: const Text('Todas', style: TextStyle(fontSize: 11.5)),
                ),
              TextButton(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: const Size(0, 28),
                ),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(today.year, today.month);
                  });
                  widget.onDateSelected(today);
                },
                child: const Text('Hoy', style: TextStyle(fontSize: 11.5)),
              ),
              IconButton(
                tooltip: 'Mes anterior',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                iconSize: 18,
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left, color: AppColors.muted),
              ),
              IconButton(
                tooltip: 'Mes siguiente',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                iconSize: 18,
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right, color: AppColors.muted),
              ),
              IconButton(
                tooltip: _collapsed ? 'Mostrar calendario' : 'Ocultar calendario',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                iconSize: 18,
                onPressed: () => setState(() => _collapsed = !_collapsed),
                icon: Icon(
                  _collapsed ? Icons.expand_more : Icons.expand_less,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
          if (!_collapsed) ...[
            const SizedBox(height: 6),
            Row(
              children: _weekDays
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 4),
            for (int row = 0; row < cells.length; row += 7)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.5),
                child: Row(
                  children: [
                    for (int col = 0; col < 7; col++)
                      Expanded(
                        child: _buildDayCell(
                          cells[row + col],
                          today,
                          grouped,
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 6),
            const Divider(height: 1),
            const SizedBox(height: 6),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: [
                _legendDot(AppColors.primary, 'Reservada'),
                _legendDot(AppColors.warning, 'En Atención'),
                _legendDot(AppColors.success, 'Atendida'),
                _legendDot(AppColors.danger, 'Cancelada'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDayCell(
    DateTime? date,
    DateTime today,
    Map<String, List<Appointment>> grouped,
  ) {
    if (date == null) return const SizedBox(height: 36);

    final key = '${date.year}-${date.month}-${date.day}';
    final dayAppts = grouped[key] ?? const <Appointment>[];
    final isToday = _isSameDay(date, today);
    final isSelected =
        widget.selectedDate != null && _isSameDay(date, widget.selectedDate!);

    final dotColors = dayAppts
        .map((a) => a.statusEnum.color)
        .toSet()
        .take(3)
        .toList();

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => widget.onDateSelected(date),
      child: Container(
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : isToday
                  ? AppColors.mint
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isToday && !isSelected
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.45))
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected || isToday || dayAppts.isNotEmpty
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : isToday
                        ? AppColors.primaryDark
                        : AppColors.ink,
              ),
            ),
            if (dotColors.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: dotColors
                    .map(
                      (c) => Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : c,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
      ],
    );
  }
}
