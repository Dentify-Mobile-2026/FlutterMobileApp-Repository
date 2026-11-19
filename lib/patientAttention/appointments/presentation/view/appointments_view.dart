import 'dart:async';

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
import 'package:dentify_flutter/patientAttention/appointments/presentation/widgets/dynamic_appointment_calendar.dart';
import 'package:dentify_flutter/patientAttention/appointments/presentation/widgets/edit_appointment_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

String formatDateTime(String isoDateTime) {
  try {
    final dateTime = DateTime.parse(isoDateTime);
    return DateFormat('dd/MM/yyyy · hh:mm a').format(dateTime);
  } catch (e) {
    return isoDateTime;
  }
}

String formatTimeOnly(String isoDateTime) {
  try {
    final dateTime = DateTime.parse(isoDateTime);
    return DateFormat('hh:mm a').format(dateTime);
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
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(appointmentsViewModelProvider.notifier).getAllAppointments();
    });
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
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
    _clockTimer?.cancel();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void _handleDayTapped(BuildContext context, DateTime? day) {
    ref.read(appointmentSelectedDateProvider.notifier).state = day;
    if (day == null) return;
    _showDayAppointmentsModal(context, day);
  }

  Future<void> _showDayAppointmentsModal(
      BuildContext context, DateTime day) async {
    final formattedDay = DateFormat('dd/MM/yyyy').format(day);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Consumer(
          builder: (ctx, modalRef, _) {
            final all = modalRef.watch(appointmentsViewModelProvider);
            final dayAppointments = all.where((a) {
              final dt = a.startDateTime;
              return dt != null &&
                  dt.year == day.year &&
                  dt.month == day.month &&
                  dt.day == day.day;
            }).toList()
              ..sort((a, b) => (a.startDateTime ?? DateTime(0))
                  .compareTo(b.startDateTime ?? DateTime(0)));

            return SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.8,
                  maxWidth: 680,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Citas del $formattedDay',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  ),
                                ),
                                Text(
                                  dayAppointments.isEmpty
                                      ? 'Sin pacientes programados'
                                      : '${dayAppointments.length} paciente(s) en agenda',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () async {
                              Navigator.pop(sheetContext);
                              await _onAddAppointment(context, day);
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Agendar'),
                          ),
                          const SizedBox(width: 2),
                          IconButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: const Icon(Icons.close,
                                size: 20, color: AppColors.muted),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      if (dayAppointments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 28),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.event_available_outlined,
                                    size: 36, color: AppColors.muted),
                                SizedBox(height: 8),
                                Text(
                                  'Agenda libre en esta fecha',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Pulsa "Agendar" para reservar una cita.',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: dayAppointments.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, index) {
                              return _buildModalDayItem(
                                sheetContext,
                                context,
                                dayAppointments[index],
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalDayItem(
    BuildContext sheetContext,
    BuildContext parentContext,
    Appointment appt,
  ) {
    final st = appt.statusEnum;
    final needsValidation = appt.isTimeOverAndPending;
    final borderColor = needsValidation || st == AppointmentStatus.inProgress
        ? AppColors.warningBorder
        : st == AppointmentStatus.cancelled
            ? AppColors.dangerBorder
            : AppColors.border;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: borderColor != AppColors.border ? 1.3 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  formatTimeOnly(appt.appointmentDate),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appt.patientName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      '${appt.reason} · ${totalMinutes(appt.duration)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _statusPill(st),
            ],
          ),
          if (appt.clinicalNotes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                appt.clinicalNotes,
                style: const TextStyle(fontSize: 12, color: AppColors.ink),
              ),
            ),
          ],
          if (needsValidation) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warningBorder),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  const Text(
                    '¿La cita se concretó?',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  Wrap(
                    spacing: 4,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.success,
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => _quickChangeStatus(
                          parentContext,
                          appt,
                          AppointmentStatus.completed,
                        ),
                        child: const Text('Sí, Atendida',
                            style: TextStyle(fontSize: 12)),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.muted,
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => _quickChangeStatus(
                          parentContext,
                          appt,
                          AppointmentStatus.noShow,
                        ),
                        child: const Text('No Asistió',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (st == AppointmentStatus.inProgress)
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.success,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () => _quickChangeStatus(
                    parentContext,
                    appt,
                    AppointmentStatus.completed,
                  ),
                  child: const Text('Atendida', style: TextStyle(fontSize: 12)),
                ),
              TextButton(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _openStatusDialog(parentContext, appt);
                },
                child: const Text('Evolución', style: TextStyle(fontSize: 12)),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.muted,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _onEdit(parentContext, appt);
                },
                child:
                    const Text('Reprogramar', style: TextStyle(fontSize: 12)),
              ),
              IconButton(
                tooltip: 'Eliminar cita',
                visualDensity: VisualDensity.compact,
                iconSize: 17,
                icon: const Icon(Icons.delete_outline, color: AppColors.muted),
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _onDelete(parentContext, appt);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allAppointments = ref.watch(appointmentsViewModelProvider);
    final isLoading = ref.watch(appointmentsViewModelProvider.notifier).isLoading;
    final selectedDate = ref.watch(appointmentSelectedDateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context, selectedDate),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DynamicAppointmentCalendar(
                              appointments: allAppointments,
                              selectedDate: selectedDate,
                              onDateSelected: (d) =>
                                  _handleDayTapped(context, d),
                            ),
                            const SizedBox(height: 12),
                            _buildStatusSummaryBox(allAppointments),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DateTime? selectedDate) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agenda de Citas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Toca un día del calendario para ver sus pacientes',
                  style: TextStyle(fontSize: 12.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Actualizar agenda',
            onPressed: () => ref
                .read(appointmentsViewModelProvider.notifier)
                .getAllAppointments(),
            icon: const Icon(Icons.refresh_rounded, color: AppColors.muted),
          ),
          const SizedBox(width: 6),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => _onAddAppointment(context, selectedDate),
            icon: const Icon(Icons.add, size: 17),
            label: const Text(
              'Nueva',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSummaryBox(List<Appointment> all) {
    final reserved =
        all.where((a) => a.statusEnum == AppointmentStatus.scheduled).length;
    final inProgress =
        all.where((a) => a.statusEnum == AppointmentStatus.inProgress).length;
    final completed =
        all.where((a) => a.statusEnum == AppointmentStatus.completed).length;
    final pendingValidation = all.where((a) => a.isTimeOverAndPending).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de Agenda',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          _summaryRow('Reservadas', reserved, AppColors.primary),
          _summaryRow('En Atención', inProgress, AppColors.warning),
          _summaryRow('Atendidas', completed, AppColors.success),
          if (pendingValidation > 0)
            _summaryRow(
                'Por confirmar cierre', pendingValidation, AppColors.danger),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
            ),
          ),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(AppointmentStatus st) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: st.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: st.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            st.label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onAddAppointment(
      BuildContext context, DateTime? initialDate) async {
    final newAppointment = await showDialog<AddAppointmentRequest>(
      context: context,
      builder: (context) => AddAppointmentForm(initialDate: initialDate),
    );
    if (newAppointment != null) {
      final error = await ref
          .read(appointmentsViewModelProvider.notifier)
          .addAppointment(newAppointment);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Cita reservada correctamente'),
            backgroundColor:
                error != null ? AppColors.danger : AppColors.primary,
          ),
        );
      }
    }
  }

  Future<void> _quickChangeStatus(
    BuildContext context,
    Appointment appointment,
    AppointmentStatus targetStatus,
  ) async {
    final req = UpdateAppointmentStatusRequest(
      status: targetStatus.code,
      clinicalNotes: appointment.clinicalNotes,
    );
    final error = await ref
        .read(appointmentsViewModelProvider.notifier)
        .updateAppointmentStatus(appointment.id, req);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Cita marcada como "${targetStatus.label}"'),
          backgroundColor:
              error != null ? AppColors.danger : AppColors.primary,
        ),
      );
    }
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
                error != null ? AppColors.danger : AppColors.primary,
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
                error != null ? AppColors.danger : AppColors.primary,
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
