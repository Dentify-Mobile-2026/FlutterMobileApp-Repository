import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/patientAttention/treatment_plans/presentation/views/treatment_plans_view.dart';
import 'package:dentify_flutter/core/utils/whatsapp_helper.dart';
import 'package:dentify_flutter/iam/presentation/di/presentation_module.dart'
    as iam_di;
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment_status.dart';
import 'package:dentify_flutter/patientAttention/appointments/presentation/di/presentation_module.dart'
    as appts_di;
import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/update_patient_request.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/model/patient.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/di/presentation_module.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/view/medical_histories_view.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/widgets/patient_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PatientCard extends ConsumerWidget {
  const PatientCard({super.key, required this.patient});
  final Patient patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final age = patient.age;

    return Card(
      color: AppColors.surface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: patient.hasMedicalAlerts
              ? AppColors.dangerBorder
              : AppColors.border,
          width: patient.hasMedicalAlerts ? 1.3 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surfaceSubtle,
                  child: Text(
                    patient.initials,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          if (age != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$age años',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: 10,
                        runSpacing: 2,
                        children: [
                          _metaChip(
                              Icons.badge_outlined, 'DNI: ${patient.dni}'),
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
                      visualDensity: VisualDensity.compact,
                      iconSize: 18,
                      icon: const Icon(Icons.edit_outlined,
                          color: AppColors.muted),
                      onPressed: () => _onEdit(context, ref),
                    ),
                    IconButton(
                      tooltip: 'Eliminar paciente',
                      visualDensity: VisualDensity.compact,
                      iconSize: 18,
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.danger),
                      onPressed: () => _onDelete(context, ref),
                    ),
                  ],
                ),
              ],
            ),
            if (patient.hasMedicalAlerts) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.dangerBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        const Text(
                          'Alerta Médica',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (patient.hasAllergies)
                      Text(
                        'Alergias: ${patient.allergies}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    if (patient.hasAllergies && patient.hasSystemicConditions)
                      const SizedBox(height: 3),
                    if (patient.hasSystemicConditions)
                      Text(
                        'Condiciones: ${patient.systemicConditions}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.muted,
                        ),
                      ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Text(
                    'Sin alertas médicas registradas',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted,
                    ),
                  ),
                ],
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
                _infoDetail(
                    Icons.cake_outlined, 'Nacimiento', patient.birthday),
                _infoDetail(Icons.location_on_outlined, 'Dirección',
                    patient.homeAddress),
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
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: const BorderSide(color: AppColors.successBorder),
                      backgroundColor: AppColors.successLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _onSendWhatsApp(context, ref),
                    icon: const Icon(Icons.chat_outlined, size: 17),
                    label: const Text(
                      'WhatsApp',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                TreatmentPlansView(patient: patient))),
                    icon: const Icon(Icons.receipt_long_outlined, size: 18),
                    label: const Text('Planes de tratamiento'),
                  ),
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
                          builder: (_) =>
                              MedicalHistoriesView(patient: patient),
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

  Future<void> _onSendWhatsApp(BuildContext context, WidgetRef ref) async {
    final phone = patient.phone.trim();
    if (phone.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('El paciente no tiene un número de teléfono registrado.'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
      return;
    }

    if (ref.read(iam_di.profileViewModelProvider).userInfo == null) {
      try {
        await ref
            .read(iam_di.profileViewModelProvider.notifier)
            .fetchUserInfo();
      } catch (_) {}
    }
    final clinicName =
        ref.read(iam_di.profileViewModelProvider).userInfo?.companyName ??
            'Dentify';

    final appointments = ref.read(appts_di.appointmentsViewModelProvider);
    final now = DateTime.now();
    final patientAppts = appointments
        .where((a) =>
            a.dni == patient.dni &&
            a.statusEnum != AppointmentStatus.cancelled &&
            a.statusEnum != AppointmentStatus.noShow)
        .toList()
      ..sort((a, b) => (a.startDateTime ?? DateTime(2100))
          .compareTo(b.startDateTime ?? DateTime(2100)));

    Appointment? nextAppt;
    for (final a in patientAppts) {
      final dt = a.startDateTime;
      if (dt != null && !dt.isBefore(now)) {
        nextAppt = a;
        break;
      }
    }
    nextAppt ??= patientAppts.isNotEmpty ? patientAppts.last : null;

    final dt = nextAppt?.startDateTime;
    final dateLabel =
        dt != null ? DateFormat('dd/MM/yyyy').format(dt) : 'por confirmar';
    final timeLabel =
        dt != null ? DateFormat('hh:mm a').format(dt) : 'por confirmar';
    final treatmentLabel = nextAppt != null
        ? (nextAppt.treatmentName.trim().isNotEmpty
            ? nextAppt.treatmentName.trim()
            : nextAppt.reason.trim())
        : 'Evaluación odontológica';

    final opened = await WhatsAppHelper.openAppointmentReminder(
      phone: phone,
      patientName: patient.fullName,
      appointmentDate: dateLabel,
      appointmentTime: timeLabel,
      treatment: treatmentLabel,
      clinicName: clinicName,
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir WhatsApp en este dispositivo.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _onEdit(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => PatientForm(patient: patient),
    );

    if (result != null) {
      final id = result['id'] as int;
      final update = result['update'] as UpdatePatientRequest;

      await ref
          .read(patientsViewModelProvider.notifier)
          .updatePatient(id, update);

      if (context.mounted) {
        final error = ref.read(patientsViewModelProvider.notifier).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Ficha de paciente actualizada'),
            backgroundColor:
                error != null ? AppColors.danger : AppColors.success,
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
