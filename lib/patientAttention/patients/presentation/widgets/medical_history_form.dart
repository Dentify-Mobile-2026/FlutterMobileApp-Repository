import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/add_medical_history_request.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/model/patient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedicalHistoryForm extends ConsumerStatefulWidget {
  const MedicalHistoryForm({super.key, required this.patient});
  final Patient patient;

  @override
  ConsumerState<MedicalHistoryForm> createState() => _MedicalHistoryFormState();
}

class _MedicalHistoryFormState extends ConsumerState<MedicalHistoryForm> {
  final _formKey = GlobalKey<FormState>();

  String description = '';
  String record = '';
  String diagnosis = '';
  String medication = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.note_add_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nueva evolución clínica',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          Text(
                            widget.patient.fullName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Descripción / Motivo *',
                  ),
                  onChanged: (value) => description = value,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Evolución clínica *',
                  ),
                  maxLines: 2,
                  onChanged: (value) => record = value,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Diagnóstico *',
                  ),
                  onChanged: (value) => diagnosis = value,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Medicación / Indicaciones *',
                  ),
                  onChanged: (value) => medication = value,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final request = AddMedicalHistoryRequest(
                            description: description.trim(),
                            record: record.trim(),
                            diagnosis: diagnosis.trim(),
                            medication: medication.trim(),
                          );
                          Navigator.pop(context, {
                            'request': request,
                            'id': widget.patient.id,
                          });
                        }
                      },
                      child: const Text('Guardar evolución'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}