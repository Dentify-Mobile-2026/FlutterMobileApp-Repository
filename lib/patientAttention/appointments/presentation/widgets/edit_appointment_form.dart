import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/update_appointment_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment.dart';
import 'package:flutter/material.dart';

String formatDurationFromMinutes(String minutesString) {
  final totalMinutes = int.tryParse(minutesString) ?? 0;
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
}

class EditAppointmentForm extends StatefulWidget {
  final Appointment appointment;

  const EditAppointmentForm({super.key, required this.appointment});

  @override
  State<EditAppointmentForm> createState() => _EditAppointmentFormState();
}

class _EditAppointmentFormState extends State<EditAppointmentForm> {
  final _formKey = GlobalKey<FormState>();

  late String reason;
  late String duration;
  late DateTime selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    reason = widget.appointment.reason;

    final durationParts = widget.appointment.duration.split(":");
    final hours = int.tryParse(durationParts[0]) ?? 0;
    final minutes = int.tryParse(durationParts[1]) ?? 0;
    duration = (hours * 60 + minutes).toString();

    final originalDate = DateTime.parse(widget.appointment.appointmentDate);
    selectedDate = originalDate;
    selectedTime = TimeOfDay.fromDateTime(originalDate);
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFF5FFFD),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        "Edit Appointment",
        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: const Text("Pick date"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Date: ${selectedDate.toLocal().toString().split(' ')[0]}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.access_time),
                label: const Text("Pick time"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                selectedTime != null
                    ? "Time: ${selectedTime!.format(context)}"
                    : "No time selected",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: reason,
                decoration: _inputDecoration("Reason"),
                onChanged: (value) => reason = value,
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: duration,
                decoration: _inputDecoration("Duration (minutes)"),
                keyboardType: TextInputType.number,
                onChanged: (value) => duration = value,
                validator: (v) {
                  final minutes = int.tryParse(v ?? '');
                  if (minutes == null || minutes <= 0) {
                    return "Enter valid minutes";
                  }
                  return null;
                },
              ),
            ],
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
          onPressed: () {
            if (_formKey.currentState!.validate() && selectedTime != null) {
              final fullDateTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime!.hour,
                selectedTime!.minute,
              ).toUtc().toIso8601String();

              final req = UpdateAppointmentRequest(
                appointmentDate: fullDateTime,
                reason: reason,
                duration: formatDurationFromMinutes(duration),
              );
              Navigator.pop<Map<String, dynamic>>(context, {
                'id': widget.appointment.id,
                'update': req,
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C3E50),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text("Save"),
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
}
