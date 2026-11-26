import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/update_appointment_status_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment_status.dart';
import 'package:flutter/material.dart';

class AppointmentStatusDialog extends StatefulWidget {
  final Appointment appointment;

  const AppointmentStatusDialog({super.key, required this.appointment});

  @override
  State<AppointmentStatusDialog> createState() =>
      _AppointmentStatusDialogState();
}

class _AppointmentStatusDialogState extends State<AppointmentStatusDialog> {
  late AppointmentStatus _selectedStatus;
  late TextEditingController _notesController;
  bool _recordInMedicalHistory = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.appointment.statusEnum;
    _notesController =
        TextEditingController(text: widget.appointment.clinicalNotes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                        color: _selectedStatus.bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _selectedStatus.icon,
                        color: _selectedStatus.color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estado y Evolución Clínica',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          Text(
                            'Paciente: ${widget.appointment.patientName}',
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.muted),
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
                const Divider(height: 26),
                const Text(
                  'Estado de la Cita:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppointmentStatus.values.where((st) {
                    // US43: una cita atendida solo puede guardar de nuevo su evolución.
                    if (widget.appointment.isAttended &&
                        st != AppointmentStatus.completed) {
                      return false;
                    }
                    // "En Atención" ocurre automáticamente en su horario; no permitir forzarla antes de la hora.
                    if (st == AppointmentStatus.inProgress &&
                        widget.appointment.isFuture) {
                      return false;
                    }
                    return true;
                  }).map((st) {
                    final selected = _selectedStatus == st;
                    return ChoiceChip(
                      avatar: Icon(st.icon, size: 17, color: st.color),
                      label: Text(
                        st.label,
                        style: TextStyle(
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? st.color : AppColors.ink,
                        ),
                      ),
                      selected: selected,
                      selectedColor: st.bgColor,
                      onSelected: (_) {
                        setState(() => _selectedStatus = st);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Notas Clínicas / Evolución de la Sesión:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    hintText:
                        'Registra qué procedimiento se realizó, piezas tratadas, anestesia aplicada o indicaciones...',
                  ),
                ),
                if (_selectedStatus == AppointmentStatus.completed)
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                        'Registrar automáticamente en el Historial Médico'),
                    subtitle: widget.appointment.treatmentId == null
                        ? const Text(
                            'La cita debe tener un tratamiento vinculado.')
                        : null,
                    value: _recordInMedicalHistory,
                    onChanged: widget.appointment.treatmentId == null
                        ? null
                        : (value) =>
                            setState(() => _recordInMedicalHistory = value),
                  ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.end,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        final req = UpdateAppointmentStatusRequest(
                          status: _selectedStatus.code,
                          clinicalNotes: _notesController.text.trim(),
                          recordInMedicalHistory:
                              _selectedStatus == AppointmentStatus.completed &&
                                  _recordInMedicalHistory,
                        );
                        Navigator.pop(context, req);
                      },
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Guardar Evolución'),
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
