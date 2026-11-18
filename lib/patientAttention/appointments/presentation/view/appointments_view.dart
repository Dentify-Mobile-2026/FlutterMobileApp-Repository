import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/main.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/add_appointment_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/update_appointment_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/update_appointment_status_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment_status.dart';
import 'package:dentify_flutter/patientAttention/appointments/presentation/di/presentation_module.dart';
import 'package:dentify_flutter/patientAttention/appointments/presentation/widgets/add_appointment_form.dart';
import 'package:dentify_flutter/patientAttention/appointments/presentation/widgets/appointment_status_dialog.dart';
import 'package:dentify_flutter/patientAttention/appointments/presentation/widgets/edit_appointment_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

String formatDateTime(String isoDateTime) {
  try {
    final dateTime = DateTime.parse(isoDateTime);
    return DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
  } catch (e) {
    return isoDateTime;
  }
}

String totalMinutes(String duration) {
  try {
    final parts = duration.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final total = hours * 60 + minutes;
    return '$total min';
  } catch (e) {
    return duration;
  }
}

class AppointmentsView extends ConsumerStatefulWidget {
  const AppointmentsView({super.key});

  @override
  ConsumerState<AppointmentsView> createState() => _AppointmentsViewState();
}

class _AppointmentsViewState extends ConsumerState<AppointmentsView>
    with RouteAware {
  @override
  void initState() {
    super.initState();
    ref.read(appointmentsViewModelProvider.notifier).getAllAppointments();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    ref.read(appointmentsViewModelProvider.notifier).getAllAppointments();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allAppointments = ref.watch(appointmentsViewModelProvider);
    final appointments = ref.watch(filteredAppointmentsProvider);
    final isLoading = ref.watch(appointmentsViewModelProvider.notifier).isLoading;
    final selectedStatus = ref.watch(appointmentStatusFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text(
          'Agenda de Citas Clínicas',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar agenda',
            onPressed: () => ref
                .read(appointmentsViewModelProvider.notifier)
                .getAllAppointments(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: TextField(
              onChanged: (v) {
                ref.read(appointmentSearchQueryProvider.notifier).state = v;
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar cita por paciente, DNI o tratamiento...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('Todas (${allAppointments.length})'),
                    selected: selectedStatus == null,
                    selectedColor: AppColors.mint,
                    onSelected: (_) {
                      ref.read(appointmentStatusFilterProvider.notifier).state =
                          null;
                    },
                  ),
                ),
                ...AppointmentStatus.values.map((st) {
                  final count = allAppointments
                      .where((a) => a.statusEnum == st)
                      .length;
                  final isSelected = selectedStatus == st.code;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: Icon(st.icon, size: 16, color: st.color),
                      label: Text('${st.label} ($count)'),
                      selected: isSelected,
                      selectedColor: st.bgColor,
                      onSelected: (_) {
                        ref
                            .read(appointmentStatusFilterProvider.notifier)
                            .state = isSelected ? null : st.code;
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : appointments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.event_busy_outlined,
                                size: 54, color: AppColors.muted),
                            const SizedBox(height: 12),
                            Text(
                              allAppointments.isEmpty
                                  ? 'No hay citas registradas en la agenda.'
                                  : 'No hay citas con el estado seleccionado.',
                              style: const TextStyle(
                                  fontSize: 16, color: AppColors.muted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          return _buildAppointmentCard(
                              context, appointments[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final newAppointment = await showDialog<AddAppointmentRequest>(
                context: context,
                builder: (context) => const AddAppointmentForm(),
              );
              if (newAppointment != null) {
                final error = await ref
                    .read(appointmentsViewModelProvider.notifier)
                    .addAppointment(newAppointment);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error ?? 'Cita agendada correctamente'),
                      backgroundColor:
                          error != null ? AppColors.danger : AppColors.success,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.add),
            label: const Text(
              'Agendar Nueva Cita',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Appointment appointment) {
    final st = appointment.statusEnum;

    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: st.color.withValues(alpha: 0.35)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 7),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: st.bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(st.icon, color: st.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patientName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: 10,
                        children: [
                          Text(
                            'DNI: ${appointment.dni}',
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.muted),
                          ),
                          if (appointment.patientPhone.isNotEmpty)
                            Text(
                              'Tel: ${appointment.patientPhone}',
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.muted),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _openStatusDialog(context, appointment),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: st.bgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(st.icon, size: 14, color: st.color),
                        const SizedBox(width: 4),
                        Text(
                          st.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: st.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _detailChip(
                  Icons.event_outlined,
                  'Fecha y Hora',
                  formatDateTime(appointment.appointmentDate),
                ),
                _detailChip(
                  Icons.timer_outlined,
                  'Duración',
                  totalMinutes(appointment.duration),
                ),
                _detailChip(
                  Icons.medical_information_outlined,
                  'Motivo',
                  appointment.reason,
                ),
                if (appointment.treatmentName.isNotEmpty)
                  _detailChip(
                    Icons.healing_outlined,
                    'Tratamiento',
                    appointment.treatmentName,
                  ),
              ],
            ),

            if (appointment.clinicalNotes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.assignment_outlined,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Evolución clínica: ${appointment.clinicalNotes}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.ink,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: AppColors.primaryDark,
                  ),
                  onPressed: () => _openStatusDialog(context, appointment),
                  icon: const Icon(Icons.fact_check_outlined, size: 18),
                  label: const Text('Estado / Evolución'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Reprogramar cita',
                  icon: const Icon(Icons.edit_calendar_outlined,
                      color: AppColors.primary),
                  onPressed: () => _onEdit(context, appointment),
                ),
                IconButton(
                  tooltip: 'Eliminar cita',
                  icon:
                      const Icon(Icons.delete_outline, color: AppColors.danger),
                  onPressed: () => _onDelete(context, appointment),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailChip(IconData icon, String label, String value) {
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
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openStatusDialog(
      BuildContext context, Appointment appointment) async {
    final req = await showDialog<UpdateAppointmentStatusRequest>(
      context: context,
      builder: (_) => AppointmentStatusDialog(appointment: appointment),
    );
    if (req != null) {
      final error = await ref
          .read(appointmentsViewModelProvider.notifier)
          .updateAppointmentStatus(appointment.id, req);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Estado y evolución actualizados'),
            backgroundColor:
                error != null ? AppColors.danger : AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _onEdit(BuildContext context, Appointment appointment) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditAppointmentForm(appointment: appointment),
    );

    if (result != null) {
      final id = result['id'] as int;
      final update = result['update'] as UpdateAppointmentRequest;

      final error = await ref
          .read(appointmentsViewModelProvider.notifier)
          .updateAppointment(id, update);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Cita reprogramada'),
            backgroundColor:
                error != null ? AppColors.danger : AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _onDelete(BuildContext context, Appointment appointment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cita'),
        content:
            const Text('¿Estás seguro de eliminar esta cita de la agenda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(appointmentsViewModelProvider.notifier)
          .deleteAppointment(appointment.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cita eliminada')),
        );
      }
    }
  }
}
