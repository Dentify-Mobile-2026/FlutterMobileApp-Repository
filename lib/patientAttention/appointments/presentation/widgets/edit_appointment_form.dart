import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/update_appointment_request.dart';
import 'package:dentify_flutter/core/theme/app_theme.dart';
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
    final dateText =
        '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}';
    final timeText =
        selectedTime != null ? selectedTime!.format(context) : 'Seleccionar';

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
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
                        Icons.edit_calendar_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reprogramar cita',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          Text(
                            'Ajusta fecha, hora, motivo o duración',
                            style: TextStyle(
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
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(10),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha *',
                            prefixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                          ),
                          child: Text(
                            dateText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickTime,
                        borderRadius: BorderRadius.circular(10),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Hora *',
                            prefixIcon: Icon(Icons.access_time_outlined, size: 18),
                          ),
                          child: Text(
                            timeText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  initialValue: reason,
                  decoration: const InputDecoration(
                    labelText: 'Motivo de consulta *',
                    prefixIcon: Icon(Icons.medical_information_outlined),
                  ),
                  onChanged: (value) => reason = value,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  initialValue: duration,
                  decoration: const InputDecoration(
                    labelText: 'Duración estimada (minutos) *',
                    prefixIcon: Icon(Icons.timer_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => duration = value,
                  validator: (v) {
                    final minutes = int.tryParse(v ?? '');
                    if (minutes == null || minutes <= 0) {
                      return 'Ingresa minutos válidos';
                    }
                    return null;
                  },
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
                        if (_formKey.currentState!.validate() &&
                            selectedTime != null) {
                          final dt = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime!.hour,
                            selectedTime!.minute,
                          );
                          final fullDateTime =
                              '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}T${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00';

                          final req = UpdateAppointmentRequest(
                            appointmentDate: fullDateTime,
                            reason: reason.trim(),
                            duration: formatDurationFromMinutes(duration),
                          );
                          Navigator.pop<Map<String, dynamic>>(context, {
                            'id': widget.appointment.id,
                            'update': req,
                          });
                        }
                      },
                      child: const Text('Guardar cambios'),
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
