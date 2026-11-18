import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/update_patient_request.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/model/patient.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/di/presentation_module.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/view/medical_histories_view.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/widgets/patient_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientCard extends ConsumerWidget {
  const PatientCard({super.key, required this.patient});
  final Patient patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final age = patient.age;

    return Card(
      color: AppColors.surface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: patient.hasMedicalAlerts
              ? AppColors.danger.withValues(alpha: 0.35)
              : AppColors.border,
          width: patient.hasMedicalAlerts ? 1.4 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      patient.hasMedicalAlerts ? AppColors.dangerLight : AppColors.mint,
                  child: Text(
                    patient.initials,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: patient.hasMedicalAlerts
                          ? AppColors.danger
                          : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              patient.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          if (age != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$age años',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          _metaChip(Icons.badge_outlined, 'DNI: ${patient.dni}'),
                          if (patient.phone.isNotEmpty)
                            _metaChip(Icons.phone_outlined, patient.phone),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Editar paciente',
                      icon: const Icon(Icons.edit_outlined,
                          size: 20, color: AppColors.primary),
                      onPressed: () => _onEdit(context, ref),
                    ),
                    IconButton(
                      tooltip: 'Eliminar paciente',
                      icon: const Icon(Icons.delete_outline,
                          size: 20, color: AppColors.danger),
                      onPressed: () => _onDelete(context, ref),
                    ),
                  ],
                ),
              ],
            ),

            if (patient.hasMedicalAlerts) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.dangerLight.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (patient.hasAllergies)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              size: 16, color: AppColors.danger),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Alergias: ${patient.allergies}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (patient.hasAllergies && patient.hasSystemicConditions)
                      const SizedBox(height: 4),
                    if (patient.hasSystemicConditions)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.monitor_heart_outlined,
                              size: 16, color: AppColors.ink),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Condiciones: ${patient.systemicConditions}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            Wrap(
              spacing: 18,
              runSpacing: 8,
              children: [
                _infoDetail(Icons.email_outlined, 'Email', patient.email),
                _infoDetail(Icons.cake_outlined, 'Nacimiento', patient.birthday),
                _infoDetail(Icons.location_on_outlined, 'Dirección', patient.homeAddress),
                if (patient.emergencyContactName.isNotEmpty ||
                    patient.emergencyContactPhone.isNotEmpty)
                  _infoDetail(
                    Icons.emergency_outlined,
                    'Emergencia',
                    [
                      if (patient.emergencyContactName.isNotEmpty)
                        patient.emergencyContactName,
                      if (patient.emergencyContactPhone.isNotEmpty)
                        '(${patient.emergencyContactPhone})',
                    ].join(' '),
                  ),
              ],
            ),

            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MedicalHistoriesView(patient: patient),
                      ),
                    );
                  },
                  icon: const Icon(Icons.folder_shared_outlined, size: 18),
                  label: const Text(
                    'Historial Clínico',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.muted),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _infoDetail(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 5),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.ink,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onEdit(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => PatientForm(patient: patient),
    );

    if (result != null) {
      final id = result['id'] as int;
      final update = result['update'] as UpdatePatientRequest;

      await ref.read(patientsViewModelProvider.notifier).updatePatient(id, update);

      if (context.mounted) {
        final error = ref.read(patientsViewModelProvider.notifier).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Ficha de paciente actualizada'),
            backgroundColor: error != null ? AppColors.danger : AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _onDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Paciente'),
        content: Text(
          '¿Estás seguro de eliminar a ${patient.fullName}? Se eliminarán también sus citas e historial clínico.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref
          .read(patientsViewModelProvider.notifier)
          .deletePatientAndRefresh(patient.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Paciente eliminado' : 'Error al eliminar paciente',
            ),
            backgroundColor: success ? AppColors.primary : AppColors.danger,
          ),
        );
      }
    }
  }
}
