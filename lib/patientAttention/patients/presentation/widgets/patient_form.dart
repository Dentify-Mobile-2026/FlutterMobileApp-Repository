import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/add_patient_request.dart';
import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/update_patient_request.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/model/patient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientForm extends ConsumerStatefulWidget {
  const PatientForm({super.key, this.patient});
  final Patient? patient;

  @override
  ConsumerState<PatientForm> createState() => _PatientFormState();
}

class _PatientFormState extends ConsumerState<PatientForm> {
  final _formKey = GlobalKey<FormState>();

  final dni = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final homeAddress = TextEditingController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      dni.text = widget.patient!.dni;
      firstName.text = widget.patient!.firstName;
      lastName.text = widget.patient!.lastName;
      email.text = widget.patient!.email;
      homeAddress.text = widget.patient!.homeAddress;
      selectedDate = DateTime.tryParse(widget.patient!.birthday);
    }
  }

  @override
  void dispose() {
    dni.dispose();
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    homeAddress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.patient == null ? "New Patient" : "Edit Patient"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: dni,
                decoration: const InputDecoration(labelText: "DNI"),
                validator: (v) => v == null || v.isEmpty ? "required" : null,
              ),
              TextFormField(
                controller: firstName,
                decoration: const InputDecoration(labelText: "First name"),
                validator: (v) => v == null || v.isEmpty ? "required" : null,
              ),
              TextFormField(
                controller: lastName,
                decoration: const InputDecoration(labelText: "Last name"),
                validator: (v) => v == null || v.isEmpty ? "required" : null,
              ),
              TextFormField(
                controller: email,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v == null || v.isEmpty ? "required" : null,
              ),
              TextFormField(
                controller: homeAddress,
                decoration: const InputDecoration(labelText: "Home Address"),
                validator: (v) => v == null || v.isEmpty ? "required" : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate != null
                          ? "Selected: ${selectedDate!.toLocal().toString().split(' ')[0]}"
                          : "Select date",
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  )
                ],
              ),
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
            if (_formKey.currentState!.validate() && selectedDate != null) {
              final birthday = "${selectedDate!.year.toString().padLeft(4, '0')}-"
                 "${selectedDate!.month.toString().padLeft(2, '0')}-"
                 "${selectedDate!.day.toString().padLeft(2, '0')}";

              if (widget.patient == null) {
                // CREACIÓN
                final request = AddPatientRequest(
                  dni: int.parse(dni.text),
                  firstName: firstName.text,
                  lastName: lastName.text,
                  email: email.text,
                  homeAddress: homeAddress.text,
                  birthday: birthday,
                );
                Navigator.pop(context, request);
              } else {
                // EDICIÓN
                final update = UpdatePatientRequest(
                  dni: int.parse(dni.text),
                  firstName: firstName.text,
                  lastName: lastName.text,
                  email: email.text,
                  homeAddress: homeAddress.text,
                  birthday: birthday,
                );
                Navigator.pop(context, {
                  'id': widget.patient!.id,
                  'update': update,
                });
              }
            }
          },
          child: Text(widget.patient == null ? "Add" : "Update"),
        ),
      ],
    );
  }
}
