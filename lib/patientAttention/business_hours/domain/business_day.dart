/// Un día del horario de atención del consultorio (US09).
///
/// [dayOfWeek] usa el nombre que entiende el servicio (MONDAY a SUNDAY) y las
/// horas van en formato HH:mm, solo cuando el día está abierto.
class BusinessDay {
  final String dayOfWeek;
  final bool open;
  final String? opensAt;
  final String? closesAt;

  const BusinessDay({
    required this.dayOfWeek,
    required this.open,
    this.opensAt,
    this.closesAt,
  });

  static const List<String> week = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];

  static const Map<String, String> _labels = {
    'MONDAY': 'Lunes',
    'TUESDAY': 'Martes',
    'WEDNESDAY': 'Miércoles',
    'THURSDAY': 'Jueves',
    'FRIDAY': 'Viernes',
    'SATURDAY': 'Sábado',
    'SUNDAY': 'Domingo',
  };

  String get label => _labels[dayOfWeek] ?? dayOfWeek;

  /// Un día abierto necesita apertura anterior al cierre.
  bool get isValid {
    if (!open) return true;
    final from = minutesOf(opensAt);
    final to = minutesOf(closesAt);
    return from != null && to != null && from < to;
  }

  static int? minutesOf(String? hhmm) {
    if (hhmm == null) return null;
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
      return null;
    }
    return h * 60 + m;
  }

  BusinessDay copyWith({bool? open, String? opensAt, String? closesAt}) {
    final isOpen = open ?? this.open;
    return BusinessDay(
      dayOfWeek: dayOfWeek,
      open: isOpen,
      opensAt: isOpen ? (opensAt ?? this.opensAt ?? '09:00') : null,
      closesAt: isOpen ? (closesAt ?? this.closesAt ?? '18:00') : null,
    );
  }

  factory BusinessDay.fromJson(Map<String, dynamic> json) {
    return BusinessDay(
      dayOfWeek: (json['dayOfWeek'] as String?)?.toUpperCase() ?? 'MONDAY',
      open: json['open'] == true,
      opensAt: json['opensAt'] as String?,
      closesAt: json['closesAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek,
        'open': open,
        'opensAt': open ? opensAt : null,
        'closesAt': open ? closesAt : null,
      };
}

/// Horario completo. [configured] es falso mientras el consultorio no lo haya
/// guardado: en ese caso los días son una propuesta y ninguna cita se restringe.
class BusinessHours {
  final bool configured;
  final List<BusinessDay> days;

  const BusinessHours({required this.configured, required this.days});

  factory BusinessHours.fromJson(Map<String, dynamic> json) {
    final days = (json['days'] as List<dynamic>? ?? [])
        .map((d) => BusinessDay.fromJson(d as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => BusinessDay.week
          .indexOf(a.dayOfWeek)
          .compareTo(BusinessDay.week.indexOf(b.dayOfWeek)));
    return BusinessHours(configured: json['configured'] == true, days: days);
  }
}
