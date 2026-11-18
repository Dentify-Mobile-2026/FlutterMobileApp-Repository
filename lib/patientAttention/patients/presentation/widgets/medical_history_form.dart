import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/add_medical_history_request.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/model/patient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedicalHistoryForm extends ConsumerStatefulWidget {
  const MedicalHistoryForm({super.key, required this.patient});
  final Patient patient;

  @override
  ConsumerState<MedicalHistoryForm> createState() => _MedicalHistoryFormState();

}

class _MedicalHistoryFormState extends ConsumerState<MedicalHistoryForm> {
  final _formKey = GlobalKey<FormState>();

  String description = "";
  String record = "";
  String diagnosis = "";
  String medication = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New Medical History"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Description"),
                onChanged: (value) => description = value,
                validator: (v) => v == null || v.isEmpty ? "required" : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Record"),
                onChanged: (value) => record = value,
                validator: (v) => v == null || v.isEmpty ? "required" : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Diagnosis"),
                onChanged: (value) => diagnosis = value,
                validator: (v) => v == null || v.isEmpty ? "required" : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Medication"),
                onChanged: (value) => medication = value,
                validator: (v) => v == null || v.isEmpty ? "required" : null,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final request = AddMedicalHistoryRequest(
                description: description,
                record: record,
                diagnosis: diagnosis,
                medication: medication,
              );
              // Navigator.pop(context, request, patient.id);
              Navigator.pop(context, {
                'request': request,
                'id': widget.patient.id,
              });
            }
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}