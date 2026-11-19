import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum AppointmentStatus {
  scheduled(
    code: 'SCHEDULED',
    label: 'Reservada',
    icon: Icons.event_available_outlined,
    color: AppColors.primary,
    bgColor: AppColors.mint,
  ),
  inProgress(
    code: 'IN_PROGRESS',
    label: 'En Atención',
    icon: Icons.medical_services_outlined,
    color: AppColors.warning,
    bgColor: AppColors.warningLight,
  ),
  completed(
    code: 'COMPLETED',
    label: 'Atendida',
    icon: Icons.check_circle_outline,
    color: AppColors.success,
    bgColor: AppColors.successLight,
  ),
  cancelled(
    code: 'CANCELLED',
    label: 'Cancelada',
    icon: Icons.cancel_outlined,
    color: AppColors.danger,
    bgColor: AppColors.dangerLight,
  ),
  noShow(
    code: 'NO_SHOW',
    label: 'No Asistió',
    icon: Icons.person_off_outlined,
    color: AppColors.muted,
    bgColor: AppColors.border,
  );

  final String code;
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const AppointmentStatus({
    required this.code,
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  /// Mapea códigos del backend al estado simplificado (CONFIRMED se unifica con SCHEDULED = "Reservada").
  static AppointmentStatus fromCode(String raw, {bool fallbackCompleted = false}) {
    final normalized = raw.trim().toUpperCase();
    if (normalized == 'CONFIRMED') return AppointmentStatus.scheduled;
    for (final s in AppointmentStatus.values) {
      if (s.code == normalized) return s;
    }
    return fallbackCompleted
        ? AppointmentStatus.completed
        : AppointmentStatus.scheduled;
  }
}
