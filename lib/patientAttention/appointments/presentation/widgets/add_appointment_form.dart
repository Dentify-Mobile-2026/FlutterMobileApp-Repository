import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/add_appointment_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/patient_data_form.dart';
import 'package:dentify_flutter/patientAttention/appointments/presentation/di/presentation_module.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/model/treatment.dart';
import 'package:dentify_flutter/patientAttention/treatments/presentation/di/presentation_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String formatDurationFromMinutes(String minutesString) {
  final totalMinutes = int.tryParse(minutesString) ?? 0;
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
}

class AddAppointmentForm extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  const AddAppointmentForm({super.key, this.initialDate});

  @override
  ConsumerState<AddAppointmentForm> createState() => _AddAppointmentFormState();
}

class _AddAppointmentFormState extends ConsumerState<AddAppointmentForm> {
  final _formKey = GlobalKey<FormState>();

  final _reasonController = TextEditingController();
  final _durationController = TextEditingController(text: '30');

  DateTime? selectedDate;
  int? selectedPatientId;
  int? selectedTreatmentId;
  TimeOfDay? selectedTime;
  bool dateError = false;
  bool timeError = false;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientsDataFormProvider);
    final treatments = ref.watch(treatmentsViewModelProvider);

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: patientsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error al cargar pacientes: $err'),
            ),
            data: (patients) => Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            Icons.calendar_month_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Agendar Nueva Cita',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              Text(
                                'Selecciona paciente, tratamiento y horario',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: AppColors.muted),
                        ),
                      ],
                    ),
                    const Divider(height: 28),

                    _dropdownPatients(patients),
                    const SizedBox(height: 14),

                    if (treatments.isNotEmpty) ...[
                      _dropdownTreatments(treatments),
                      const SizedBox(height: 14),
                    ],

                    TextFormField(
                      controller: _reasonController,
                      decoration: const InputDecoration(
                        labelText: 'Motivo de Consulta / Procedimiento *',
                        prefixIcon: Icon(Icons.edit_note_outlined, size: 20),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Duración estimada (minutos) *',
                        prefixIcon: Icon(Icons.timer_outlined, size: 20),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requerido';
                        final min = int.tryParse(v.trim());
                        if (min == null || min <= 0) return 'Ingrese minutos válidos';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _pickDate,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Fecha *',
                                prefixIcon: const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 18),
                                errorText: dateError && selectedDate == null
                                    ? 'Elija fecha'
                                    : null,
                              ),
                              child: Text(
                                selectedDate != null
                                    ? selectedDate!
                                        .toLocal()
                                        .toString()
                                        .split(' ')[0]
                                    : 'Elegir fecha',
                                style: TextStyle(
                                  color: selectedDate != null
                                      ? AppColors.ink
                                      : AppColors.muted,
                                  fontWeight: selectedDate != null
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _pickTime,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Hora *',
                                prefixIcon: const Icon(Icons.access_time,
                                    size: 18),
                                errorText: timeError && selectedTime == null
                                    ? 'Elija hora'
                                    : null,
                              ),
                              child: Text(
                                selectedTime != null
                                    ? selectedTime!.format(context)
                                    : 'Elegir hora',
                                style: TextStyle(
                                  color: selectedTime != null
                                      ? AppColors.ink
                                      : AppColors.muted,
                                  fontWeight: selectedTime != null
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.event_available),
                          label: const Text('Agendar Cita'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DropdownButtonFormField<int> _dropdownPatients(
    List<PatientDataForm> patients,
  ) {
    return DropdownButtonFormField<int>(
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Seleccionar Paciente *',
        prefixIcon: Icon(Icons.person_outline, size: 20),
      ),
      value: selectedPatientId,
      items: patients
          .map(
            (p) => DropdownMenuItem<int>(
              value: p.id,
              child: Text('${p.firstName} ${p.lastName}'),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => selectedPatientId = v),
      validator: (v) => v == null ? 'Seleccione un paciente' : null,
    );
  }

  DropdownButtonFormField<int?> _dropdownTreatments(
    List<Treatment> treatments,
  ) {
    return DropdownButtonFormField<int?>(
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Tratamiento del Catálogo (Opcional)',
        prefixIcon: Icon(Icons.medical_services_outlined, size: 20),
      ),
      value: selectedTreatmentId,
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text('Consulta general / Personalizado'),
        ),
        ...treatments.map(
          (t) => DropdownMenuItem<int?>(
            value: t.id,
            child: Text(
                '${t.name} (S/. ${t.price.toStringAsFixed(0)} · ${t.estimatedDurationMinutes} min)'),
          ),
        ),
      ],
      onChanged: (v) {
        setState(() {
          selectedTreatmentId = v;
          if (v != null) {
            final t = treatments.firstWhere((e) => e.id == v);
            _reasonController.text = t.name;
            _durationController.text = t.estimatedDurationMinutes.toString();
          }
        });
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateError = false;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        timeError = false;
      });
    }
  }

  void _submit() {
    final isValid = _formKey.currentState!.validate();
    setState(() {
      dateError = selectedDate == null;
      timeError = selectedTime == null;
    });

    if (isValid && selectedDate != null && selectedTime != null) {
      final localDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      final appointmentDate = _toLocalIso(localDateTime);

      final req = AddAppointmentRequest(
        appointmentDate: appointmentDate,
        reason: _reasonController.text.trim(),
        duration: formatDurationFromMinutes(_durationController.text.trim()),
        patientId: selectedPatientId!,
        treatmentId: selectedTreatmentId,
      );

      Navigator.pop(context, req);
    }
  }

  String _toLocalIso(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-${d}T$h:$min:00';
  }
}
