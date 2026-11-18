import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum TreatmentCategory {
  prevention(
    code: 'PREVENTION',
    label: 'Prevención y Profilaxis',
    icon: Icons.cleaning_services_outlined,
    color: AppColors.primary,
    bgColor: AppColors.mint,
  ),
  restorative(
    code: 'RESTORATIVE',
    label: 'Operatoria y Restauración',
    icon: Icons.build_circle_outlined,
    color: AppColors.info,
    bgColor: AppColors.infoLight,
  ),
  endodontics(
    code: 'ENDODONTICS',
    label: 'Endodoncia',
    icon: Icons.flash_on_outlined,
    color: AppColors.danger,
    bgColor: AppColors.dangerLight,
  ),
  periodontics(
    code: 'PERIODONTICS',
    label: 'Periodoncia',
    icon: Icons.water_drop_outlined,
    color: AppColors.warning,
    bgColor: AppColors.warningLight,
  ),
  orthodontics(
    code: 'ORTHODONTICS',
    label: 'Ortodoncia',
    icon: Icons.grid_on_outlined,
    color: AppColors.purple,
    bgColor: AppColors.purpleLight,
  ),
  surgery(
    code: 'SURGERY',
    label: 'Cirugía Oral',
    icon: Icons.medical_services_outlined,
    color: AppColors.danger,
    bgColor: AppColors.dangerLight,
  ),
  prosthodontics(
    code: 'PROSTHODONTICS',
    label: 'Prótesis y Rehabilitación',
    icon: Icons.architecture_outlined,
    color: AppColors.primaryDark,
    bgColor: AppColors.mint,
  ),
  aesthetics(
    code: 'AESTHETICS',
    label: 'Estética Dental',
    icon: Icons.auto_awesome_outlined,
    color: AppColors.success,
    bgColor: AppColors.successLight,
  );

  final String code;
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const TreatmentCategory({
    required this.code,
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  static TreatmentCategory fromCode(String raw) {
    final normalized = raw.trim().toUpperCase();
    for (final cat in TreatmentCategory.values) {
      if (cat.code == normalized) return cat;
    }
    return TreatmentCategory.prevention;
  }
}
