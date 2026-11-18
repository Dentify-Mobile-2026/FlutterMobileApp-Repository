import 'package:dentify_flutter/main.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/add_appointment_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/update_appointment_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/presentation/di/presentation_module.dart';
import 'package:dentify_flutter/patientAttention/appointments/presentation/widgets/add_appointment_form.dart';
import 'package:dentify_flutter/patientAttention/appointments/presentation/widgets/edit_appointment_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

String formatDateTime(String isoDateTime) {
  try {
    final dateTime = DateTime.parse(isoDateTime);
    return DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
  } catch (e) {
    return isoDateTime; // fallback si algo falla
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
    return duration; // fallback si algo falla
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
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  // Este método se llama cuando vuelves a esta vista desde otra (por ejemplo, después de editar)
  @override
  void didPopNext() {
    // Esto vuelve a traer la lista actualizada
    ref.read(appointmentsViewModelProvider.notifier).getAllAppointments();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appointments = ref.watch(appointmentsViewModelProvider);
    final isLoading =
        appointments.isEmpty &&
        ref.read(appointmentsViewModelProvider.notifier).errorMessage == null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5FFFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5FFFD),
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text(
          "Appointments",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : appointments.isEmpty
              ? const Center(
                child: Text(
                  "No appointments found",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD1F2EB),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.content_paste,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appointment.patientName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    'DNI: ${appointment.dni}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    'Appointment ID: ${appointment.id}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InfoRow(
                                  label: 'Date:',
                                  value: formatDateTime(
                                    appointment.appointmentDate,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InfoRow(
                                  label: 'Reason:',
                                  value: appointment.reason,
                                ),
                                InfoRow(
                                  label: 'Completed:',
                                  value: appointment.completed.toString(),
                                ),
                                InfoRow(
                                  label: 'Duration:',
                                  value: totalMinutes(appointment.duration),
                                ),
                                InfoRow(
                                  label: 'Created:',
                                  value: formatDateTime(appointment.createdAt),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF2C3E50),
                                  ),
                                  foregroundColor: const Color(0xFF2C3E50),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  final result =
                                      await showDialog<Map<String, dynamic>>(
                                        context: context,
                                        builder:
                                            (context) => EditAppointmentForm(
                                              appointment: appointment,
                                            ),
                                      );

                                  if (result != null) {
                                    final id = result['id'] as int;
                                    final update =
                                        result['update']
                                            as UpdateAppointmentRequest;

                                    print('Edit pressed');
                                    print('Updating appointment with ID: $id');
                                    print('With data: ${update.toJson()}');

                                    await ref
                                        .read(
                                          appointmentsViewModelProvider
                                              .notifier,
                                        )
                                        .updateAppointment(id, update);

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Appointment updated"),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: const Text('Edit'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF2C3E50),
                                  ),
                                  foregroundColor: const Color(0xFF2C3E50),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Appointment'),
                                      content: const Text(
                                        'Are you sure you want to delete this appointment?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            context,
                                            false,
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            context,
                                            true,
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await ref
                                        .read(
                                          appointmentsViewModelProvider
                                              .notifier,
                                        )
                                        .deleteAppointment(appointment.id);

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text("Appointment deleted"),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
                await ref
                    .read(appointmentsViewModelProvider.notifier)
                    .addAppointment(newAppointment);
              }
            },
            icon: const Icon(Icons.add),
            label: const Text(
              'New Appointment',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C3E50),
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
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(width: 6),
          Text(value),
        ],
      ),
    );
  }
}
