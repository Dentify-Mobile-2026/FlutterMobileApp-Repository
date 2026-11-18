import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/update_patient_request.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/model/patient.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/di/presentation_module.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/view/medical_histories_view.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/widgets/patient_form.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class PatientCard extends ConsumerWidget {
  const PatientCard({super.key, required this.patient});
  final Patient patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        children: [
          Padding(
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
                      child: const Icon(Icons.people, color: Color(0xFF2C3E50)),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${patient.firstName} ${patient.lastName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'DNI: ${patient.dni}',
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
                      InfoRow(label: 'Email:', value: patient.email),
                      InfoRow(label: 'Birthday:', value: patient.birthday),
                      InfoRow(
                        label: 'Home Address:',
                        value: patient.homeAddress,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Color(0xFFD1F2EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      // TODO: acción de ver historial
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => MedicalHistoriesView(patient: patient),
                        ),
                      );
                    },
                    child: const Text('View Medical Histories'),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white, // Fondo blanco
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.black),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      final result = await showDialog<Map<String, dynamic>>(
                        context: context,
                        builder: (context) => PatientForm(patient: patient),
                      );

                      if (result != null) {
                        final id = result['id'] as int;
                        final update = result['update'] as UpdatePatientRequest;

                        print('Edit pressed');
                        print('Updating patient with ID: $id');
                        print('With data: ${update.toJson()}');

                        await ref
                            .read(patientsViewModelProvider.notifier)
                            .updatePatient(id, update);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Patient updated")),
                          );
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.black),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: const Text("Confirm Delete"),
                              content: const Text(
                                "Are you sure you want to delete this patient?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2C3E50),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("Delete"),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        print('Delete pressed');
                        print('Deleting patient with ID: ${patient.id}');

                        final success = await ref
                            .read(patientsViewModelProvider.notifier)
                            .deletePatientAndRefresh(patient.id);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? "Patient deleted"
                                    : "Error deleting patient",
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Text(value),
        ],
      ),
    );
  }
}
