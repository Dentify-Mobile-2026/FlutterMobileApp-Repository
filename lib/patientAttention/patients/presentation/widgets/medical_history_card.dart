import 'package:dentify_flutter/patientAttention/patients/domain/model/medical_history.dart';
import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MedicalHistoryCard extends ConsumerWidget {
  const MedicalHistoryCard(
      {super.key, required this.medicalHistory, this.onAnnul});
  final MedicalHistory medicalHistory;

  /// Si se indica y la entrada está vigente, muestra el botón «Anular» (US18).
  final VoidCallback? onAnnul;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateTime.parse(
        medicalHistory.appointmentDate ?? medicalHistory.createdAt);
    final formatted = DateFormat('dd/MM/yyyy').format(date);
    final formattedHour = DateFormat.Hm().format(date);
    final fromAppointment = medicalHistory.sourceAppointmentId != null;
    final annulled = medicalHistory.annulled;

    return Opacity(
      opacity: annulled ? 0.75 : 1,
      child: Card(
        color: annulled ? AppColors.surfaceSubtle : AppColors.surface,
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
                      color: fromAppointment
                          ? AppColors.infoLight
                          : AppColors.mint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      fromAppointment
                          ? Icons.event_available_outlined
                          : Icons.medical_information_outlined,
                      size: 20,
                      color:
                          fromAppointment ? AppColors.info : AppColors.primary,
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
                      color: fromAppointment
                          ? AppColors.infoLight
                          : AppColors.mint,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      fromAppointment ? 'Automático' : 'Manual',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: fromAppointment
                            ? AppColors.info
                            : AppColors.primary,
                      ),
                    ),
                  ),
                  if (annulled) ...[
                    const SizedBox(width: 6),
                    Container(
                      key: const Key('medical-history-annulled'),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.dangerLight,
                        border: Border.all(color: AppColors.dangerBorder),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Anulada',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const Divider(height: 22),
              if (annulled)
                InfoRow(
                  label: 'Motivo de anulación',
                  value: medicalHistory.annulmentReason ?? '',
                ),
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
              if (!annulled && onAnnul != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    key: const Key('medical-history-annul'),
                    style:
                        TextButton.styleFrom(foregroundColor: AppColors.danger),
                    onPressed: onAnnul,
                    icon: const Icon(Icons.block_outlined, size: 18),
                    label: const Text('Anular'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pide el motivo de la anulación (US18). Devuelve el motivo o null si se cancela.
class AnnulMedicalHistoryDialog extends StatefulWidget {
  const AnnulMedicalHistoryDialog({super.key});

  @override
  State<AnnulMedicalHistoryDialog> createState() =>
      _AnnulMedicalHistoryDialogState();
}

class _AnnulMedicalHistoryDialogState extends State<AnnulMedicalHistoryDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reason = _reason.text.trim();
    return AlertDialog(
      title: const Text('Anular entrada'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'La entrada no se borra: queda marcada como anulada y sigue visible con su motivo.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('annul-reason'),
            controller: _reason,
            maxLength: 250,
            maxLines: 3,
            minLines: 1,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Motivo de la anulación',
              hintText: 'Ej.: se registró en otro paciente',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('annul-confirm'),
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          onPressed:
              reason.isEmpty ? null : () => Navigator.of(context).pop(reason),
          child: const Text('Anular'),
        ),
      ],
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
