import 'package:dentify_flutter/core/theme/app_theme.dart';
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

  static const List<String> _commonAllergies = [
    'Penicilina',
    'Lidocaína / Anestesia',
    'Látex',
    'AINEs / Ibuprofeno',
    'Aspirina',
  ];

  static const List<String> _commonConditions = [
    'Hipertensión',
    'Diabetes',
    'Cardiopatía',
    'Coagulopatía',
    'Asma',
    'Embarazo',
  ];

  final dni = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final homeAddress = TextEditingController();
  final allergies = TextEditingController();
  final systemicConditions = TextEditingController();
  final emergencyContactName = TextEditingController();
  final emergencyContactPhone = TextEditingController();

  bool hasMedicalAlert = false;
  DateTime? selectedDate;
  bool dateError = false;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    if (p != null) {
      dni.text = p.dni;
      firstName.text = p.firstName;
      lastName.text = p.lastName;
      email.text = p.email;
      phone.text = p.phone;
      homeAddress.text = p.homeAddress;
      allergies.text = p.hasAllergies ? p.allergies : '';
      systemicConditions.text =
          p.hasSystemicConditions ? p.systemicConditions : '';
      hasMedicalAlert = p.hasMedicalAlerts;
      emergencyContactName.text = p.emergencyContactName;
      emergencyContactPhone.text = p.emergencyContactPhone;
      selectedDate = DateTime.tryParse(p.birthday);
    }
  }

  @override
  void dispose() {
    dni.dispose();
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    phone.dispose();
    homeAddress.dispose();
    allergies.dispose();
    systemicConditions.dispose();
    emergencyContactName.dispose();
    emergencyContactPhone.dispose();
    super.dispose();
  }

  String _normalize(String s) {
    return s
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .trim();
  }

  bool _matchesTag(String item, String tag) {
    final normItem = _normalize(item);
    final normTag = _normalize(tag);
    if (normItem == normTag) return true;
    final tagParts = normTag.split('/').map((e) => e.trim()).where((e) => e.isNotEmpty);
    for (final part in tagParts) {
      if (normItem.contains(part) || part.contains(normItem)) {
        return true;
      }
    }
    return false;
  }

  void _toggleQuickTag(TextEditingController controller, String tag) {
    final currentItems = controller.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final exists = currentItems.any((e) => _matchesTag(e, tag));
    setState(() {
      if (exists) {
        currentItems.removeWhere((e) => _matchesTag(e, tag));
      } else {
        currentItems.add(tag);
      }
      controller.text = currentItems.join(', ');
      hasMedicalAlert = allergies.text.trim().isNotEmpty ||
          systemicConditions.text.trim().isNotEmpty;
    });
  }

  bool _isTagSelected(TextEditingController controller, String tag) {
    final currentItems = controller.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty);
    return currentItems.any((e) => _matchesTag(e, tag));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.patient != null;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
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
                          color: AppColors.mint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isEditing ? Icons.manage_accounts : Icons.person_add_alt_1,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing ? 'Editar Ficha de Paciente' : 'Nuevo Paciente',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            const Text(
                              'Datos clínicos, contacto y alertas médicas',
                              style: TextStyle(fontSize: 13, color: AppColors.muted),
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
                  const Divider(height: 28),

                  _sectionHeader(Icons.badge_outlined, 'Datos de Identificación'),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: dni,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'DNI (8 dígitos) *',
                            prefixIcon: Icon(Icons.credit_card, size: 20),
                            counterText: '',
                          ),
                          maxLength: 8,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Requerido';
                            if (!RegExp(r'^\d{8}$').hasMatch(v.trim())) {
                              return 'Debe tener 8 dígitos';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _pickBirthday,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Fecha de Nacimiento *',
                              prefixIcon: const Icon(Icons.cake_outlined, size: 20),
                              errorText: dateError && selectedDate == null
                                  ? 'Seleccione la fecha'
                                  : null,
                            ),
                            child: Text(
                              selectedDate != null
                                  ? '${selectedDate!.year.toString().padLeft(4, '0')}-'
                                      '${selectedDate!.month.toString().padLeft(2, '0')}-'
                                      '${selectedDate!.day.toString().padLeft(2, '0')}'
                                  : 'Seleccionar fecha',
                              style: TextStyle(
                                color: selectedDate != null ? AppColors.ink : AppColors.muted,
                                fontWeight: selectedDate != null
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: firstName,
                          decoration: const InputDecoration(
                            labelText: 'Nombres *',
                            prefixIcon: Icon(Icons.person_outline, size: 20),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Requerido' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: lastName,
                          decoration: const InputDecoration(
                            labelText: 'Apellidos *',
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Requerido' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _sectionHeader(Icons.contact_phone_outlined, 'Contacto y Ubicación'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: phone,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono / WhatsApp',
                            hintText: 'Ej: 987654321',
                            prefixIcon: Icon(Icons.phone_outlined, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Correo Electrónico *',
                            prefixIcon: Icon(Icons.email_outlined, size: 20),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Requerido';
                            if (!RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$')
                                .hasMatch(v.trim())) {
                              return 'Correo inválido';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: homeAddress,
                    decoration: const InputDecoration(
                      labelText: 'Dirección Domiciliaria *',
                      prefixIcon: Icon(Icons.home_outlined, size: 20),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Dirección requerida' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: emergencyContactName,
                          decoration: const InputDecoration(
                            labelText: 'Contacto de Emergencia',
                            hintText: 'Nombre de familiar/tutor',
                            prefixIcon: Icon(Icons.supervisor_account_outlined, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: emergencyContactPhone,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Tel. Emergencia',
                            prefixIcon: Icon(Icons.phone_in_talk_outlined, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _sectionHeader(
                    hasMedicalAlert
                        ? Icons.warning_amber_rounded
                        : Icons.verified_user_outlined,
                    'Estado Clínico y Alertas Médicas',
                    color: hasMedicalAlert ? AppColors.danger : AppColors.success,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        avatar: const Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: AppColors.success,
                        ),
                        label: const Text(
                          'Sin Alertas (Estable)',
                          style: TextStyle(
                              fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                        selected: !hasMedicalAlert,
                        selectedColor: AppColors.successLight,
                        onSelected: (_) {
                          setState(() {
                            hasMedicalAlert = false;
                            allergies.clear();
                            systemicConditions.clear();
                          });
                        },
                      ),
                      ChoiceChip(
                        avatar: const Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: AppColors.danger,
                        ),
                        label: const Text(
                          'Con Alerta Médica',
                          style: TextStyle(
                              fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                        selected: hasMedicalAlert,
                        selectedColor: AppColors.dangerLight,
                        onSelected: (_) {
                          setState(() {
                            hasMedicalAlert = true;
                          });
                        },
                      ),
                    ],
                  ),
                  if (!hasMedicalAlert) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_outlined,
                              color: AppColors.success, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Sin alergias ni condiciones de riesgo registradas. Al guardar se quitará cualquier alerta roja.',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Selecciona o escribe alergias a medicamentos/anestesia:',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _commonAllergies.map((tag) {
                        final selected = _isTagSelected(allergies, tag);
                        return FilterChip(
                          label: Text(tag, style: const TextStyle(fontSize: 12)),
                          selected: selected,
                          selectedColor: AppColors.dangerLight,
                          checkmarkColor: AppColors.danger,
                          onSelected: (_) => _toggleQuickTag(allergies, tag),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: allergies,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Alergias (separadas por coma)',
                        hintText: 'Ej: Penicilina, Lidocaína, Látex',
                        prefixIcon: const Icon(
                          Icons.medical_information_outlined,
                          color: AppColors.danger,
                          size: 20,
                        ),
                        suffixIcon: allergies.text.isNotEmpty
                            ? IconButton(
                                tooltip: 'Limpiar alergias',
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => setState(() => allergies.clear()),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Condiciones sistémicas o preexistentes:',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _commonConditions.map((tag) {
                        final selected = _isTagSelected(systemicConditions, tag);
                        return FilterChip(
                          label: Text(tag, style: const TextStyle(fontSize: 12)),
                          selected: selected,
                          selectedColor: AppColors.warningLight,
                          checkmarkColor: AppColors.warning,
                          onSelected: (_) =>
                              _toggleQuickTag(systemicConditions, tag),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: systemicConditions,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Condiciones Preexistentes',
                        hintText: 'Ej: Hipertensión, Diabetes, Embarazo',
                        prefixIcon: const Icon(
                          Icons.monitor_heart_outlined,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        suffixIcon: systemicConditions.text.isNotEmpty
                            ? IconButton(
                                tooltip: 'Limpiar condiciones',
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () =>
                                    setState(() => systemicConditions.clear()),
                              )
                            : null,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _submit,
                        icon: Icon(isEditing ? Icons.save_outlined : Icons.check),
                        label: Text(isEditing ? 'Guardar Cambios' : 'Registrar Paciente'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title, {Color color = AppColors.primary}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateError = false;
      });
    }
  }

  void _submit() {
    final isValid = _formKey.currentState!.validate();
    if (selectedDate == null) {
      setState(() => dateError = true);
    }
    if (!isValid || selectedDate == null) return;

    final birthday = '${selectedDate!.year.toString().padLeft(4, '0')}-'
        '${selectedDate!.month.toString().padLeft(2, '0')}-'
        '${selectedDate!.day.toString().padLeft(2, '0')}';

    final finalAllergies = hasMedicalAlert ? allergies.text.trim() : '';
    final finalConditions =
        hasMedicalAlert ? systemicConditions.text.trim() : '';

    if (widget.patient == null) {
      final request = AddPatientRequest(
        dni: dni.text.trim(),
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        email: email.text.trim(),
        homeAddress: homeAddress.text.trim(),
        birthday: birthday,
        phone: phone.text.trim(),
        allergies: finalAllergies,
        systemicConditions: finalConditions,
        emergencyContactName: emergencyContactName.text.trim(),
        emergencyContactPhone: emergencyContactPhone.text.trim(),
      );
      Navigator.pop(context, request);
    } else {
      final update = UpdatePatientRequest(
        dni: dni.text.trim(),
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        email: email.text.trim(),
        homeAddress: homeAddress.text.trim(),
        birthday: birthday,
        phone: phone.text.trim(),
        allergies: finalAllergies,
        systemicConditions: finalConditions,
        emergencyContactName: emergencyContactName.text.trim(),
        emergencyContactPhone: emergencyContactPhone.text.trim(),
      );
      Navigator.pop(context, {
        'id': widget.patient!.id,
        'update': update,
      });
    }
  }
}
