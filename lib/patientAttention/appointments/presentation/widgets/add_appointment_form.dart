import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/add_appointment_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/patient_data_form.dart';
import 'package:dentify_flutter/patientAttention/appointments/presentation/di/presentation_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String formatDurationFromMinutes(String minutesString) {
  final totalMinutes = int.tryParse(minutesString) ?? 0;
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
}

class AddAppointmentForm extends ConsumerStatefulWidget {
  const AddAppointmentForm({super.key});

  @override
  ConsumerState<AddAppointmentForm> createState() => _AddAppointmentFormState();
}

class _AddAppointmentFormState extends ConsumerState<AddAppointmentForm> {
  final _formKey = GlobalKey<FormState>();

  String reason = "";
  String duration = "";
  DateTime? selectedDate;
  int? selectedPatientId;
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientsDataFormProvider);

    return AlertDialog(
      backgroundColor: const Color(0xFFF5FFFD),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        "New Appointment",
        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
      ),
      content: patientsAsync.when(
        loading:
            () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        error:
            (err, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text("Error loading patients: $err"),
            ),
        data:
            (patients) => Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _dropdownPatients(patients),
                    const SizedBox(height: 12),
                    _textField(
                      label: "Reason",
                      onChanged: (v) => reason = v,
                      validator:
                          (v) => v == null || v.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      label: "Duration (minutes)",
                      keyboardType: TextInputType.number,
                      onChanged: (v) => duration = v,
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Required";
                        if (int.tryParse(v) == null) return "Only numbers";
                        return null;
                      },
                    ),
                    _datePickerRow(context),
                    const SizedBox(height: 16),
                    _timePickerRow(context),
                  ],
                ),
              ),
            ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[800],
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C3E50),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text("Add"),
        ),
      ],
    );
  }

  // --- Widgets auxiliares ---

  DropdownButtonFormField<int> _dropdownPatients(
    List<PatientDataForm> patients,
  ) {
    return DropdownButtonFormField<int>(
      decoration: _inputDecoration("Select patient"),
      value: selectedPatientId,
      items:
          patients
              .map(
                (p) => DropdownMenuItem<int>(
                  value: p.id,
                  child: Text("${p.firstName} ${p.lastName}"),
                ),
              )
              .toList(),
      onChanged: (v) => setState(() => selectedPatientId = v),
      validator: (v) => v == null ? "Required" : null,
    );
  }

  TextFormField _textField({
    required String label,
    TextInputType keyboardType = TextInputType.text,
    required void Function(String) onChanged,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      decoration: _inputDecoration(label),
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Row _datePickerRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            selectedDate != null
                ? "Selected: ${selectedDate!.toLocal().toString().split(' ')[0]}"
                : "Select date",
            style: const TextStyle(fontSize: 14),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today, color: Color(0xFF2C3E50)),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() => selectedDate = picked);
            }
          },
        ),
      ],
    );
  }

  Row _timePickerRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            selectedTime != null
                ? "Time: ${selectedTime!.format(context)}"
                : "Select time",
            style: const TextStyle(fontSize: 14),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.access_time, color: Color(0xFF2C3E50)),
          onPressed: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (picked != null) {
              setState(() => selectedTime = picked);
            }
          },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2C3E50)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2C3E50), width: 1.5),
      ),
    );
  }

  // --- Submit ---

  void _submit() {
    if (_formKey.currentState!.validate() &&
        selectedDate != null &&
        selectedTime != null) {
      final localDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      final appointmentDate = localDateTime.toUtc().toIso8601String();

      final req = AddAppointmentRequest(
        appointmentDate: appointmentDate,
        reason: reason,
        duration: formatDurationFromMinutes(duration),
        patientId: selectedPatientId!,
      );

      Navigator.pop(context, req);
    }
  }
}
