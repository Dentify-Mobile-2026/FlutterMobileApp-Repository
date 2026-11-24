import 'package:dentify_flutter/patientAttention/patients/domain/model/medical_history.dart';
import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MedicalHistoryCard extends ConsumerWidget {
  const MedicalHistoryCard({super.key, required this.medicalHistory});
  final MedicalHistory medicalHistory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateTime.parse(
        medicalHistory.appointmentDate ?? medicalHistory.createdAt);
    final formatted = DateFormat('dd/MM/yyyy').format(date);
    final formattedHour = DateFormat.Hm().format(date);
    final fromAppointment = medicalHistory.sourceAppointmentId != null;

    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: fromAppointment ? AppColors.infoLight : AppColors.mint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    fromAppointment
                        ? Icons.event_available_outlined
                        : Icons.medical_information_outlined,
                    size: 20,
                    color: fromAppointment ? AppColors.info : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatted,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${fromAppointment ? 'Cita atendida' : 'Registro manual'} · $formattedHour',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: fromAppointment ? AppColors.infoLight : AppColors.mint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    fromAppointment ? 'Automático' : 'Manual',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color:
                          fromAppointment ? AppColors.info : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 22),
            InfoRow(
              label: 'Diagnóstico',
              value: medicalHistory.diagnosis,
            ),
            InfoRow(
              label: 'Descripción',
              value: medicalHistory.description,
            ),
            InfoRow(
              label: 'Evolución',
              value: medicalHistory.record,
            ),
            InfoRow(
              label: 'Medicación',
              value: medicalHistory.medication,
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.muted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
