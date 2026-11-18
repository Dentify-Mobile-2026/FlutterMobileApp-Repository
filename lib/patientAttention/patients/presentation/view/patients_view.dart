import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/add_patient_request.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/di/presentation_module.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/widgets/patient_card.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/widgets/patient_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientsView extends ConsumerWidget {
  const PatientsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patients = ref.watch(filteredPatientsProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5FFFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5FFFD),
        automaticallyImplyLeading: false,
        title: const Text("Patients",
      style: TextStyle(fontWeight: FontWeight.bold),)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                ref.read(patientSearchQueryProvider.notifier).state = value;
              },
            cursorColor: const Color(0xFF2C3E50),
            decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.search),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 1,
                color: const Color(0xFF2C3E50),
                ),
              borderRadius: BorderRadius.circular(24),
              ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
            hintText: "Search",
              ),
            )
          ),
          Expanded(
            // child: patients.isEmpty ? const Center(child: CircularProgressIndicator())
            //   : ListView.builder(
            //     padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
            //     itemCount: patients.length,
            //     itemBuilder:(context, index) {
            //       final patient = patients[index];
            //       return PatientCard(patient: patient);
            //     },)

            child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : patients.isEmpty
                  ? const Center(child: Text('No patients found.'))
              : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                itemCount: patients.length,
                itemBuilder:(context, index) {
                  final patient = patients[index];
                  return PatientCard(patient: patient);
                },)
            )
        ],
      ),  
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final newPatient = await showDialog<AddPatientRequest>(
                context: context,
                builder: (context) => const PatientForm(),
              );
              if (newPatient != null) {
                await ref
                    .read(patientsViewModelProvider.notifier)
                    .addPatient(newPatient);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C3E50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            child: const Text('New Patient'),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

