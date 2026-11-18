import 'package:dentify_flutter/patientAttention/patients/domain/model/medical_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MedicalHistoryCard extends ConsumerWidget{
  const MedicalHistoryCard({super.key, required this.medicalHistory});
  final MedicalHistory medicalHistory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateTime.parse(medicalHistory.createdAt);
    final formatted = DateFormat("MMMM d, y", 'en_US').format(date);
    final formattedHour = DateFormat.Hm().format(date); 

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                      child: const Icon(
                        Icons.note_add,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatted,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Created At: $formattedHour',
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
                        label: 'Diagnosis:',
                        value: medicalHistory.diagnosis,
                      ),
                      InfoRow(
                        label: 'Description:',
                        value: medicalHistory.description,
                      ),
                      InfoRow(
                        label: 'Record:',
                        value: medicalHistory.record,
                      ),
                      InfoRow(
                        label: 'Medication:',
                        value: medicalHistory.medication,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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