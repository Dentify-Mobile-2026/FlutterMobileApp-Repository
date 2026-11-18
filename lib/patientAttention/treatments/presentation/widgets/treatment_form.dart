import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/patientAttention/treatments/data/remote/dto/treatment_request.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/model/treatment.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/model/treatment_category.dart';
import 'package:flutter/material.dart';

class TreatmentForm extends StatefulWidget {
  final Treatment? treatment;

  const TreatmentForm({super.key, this.treatment});

  @override
  State<TreatmentForm> createState() => _TreatmentFormState();
}

class _TreatmentFormState extends State<TreatmentForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController(text: '30');

  TreatmentCategory _selectedCategory = TreatmentCategory.prevention;

  @override
  void initState() {
    super.initState();
    final t = widget.treatment;
    if (t != null) {
      _nameController.text = t.name;
      _descriptionController.text = t.description;
      _priceController.text = t.price.toStringAsFixed(2);
      _durationController.text = t.estimatedDurationMinutes.toString();
      _selectedCategory = t.categoryEnum;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.treatment != null;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
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
                        child: const Icon(
                          Icons.medical_services_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing
                                  ? 'Editar Tratamiento Dental'
                                  : 'Nuevo Tratamiento Dental',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            const Text(
                              'Define arancel, especialidad y duración estándar',
                              style: TextStyle(fontSize: 12, color: AppColors.muted),
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

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Procedimiento *',
                      hintText: 'Ej: Profilaxis y Destartraje Ultrasónico',
                      prefixIcon: Icon(Icons.healing_outlined, size: 20),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Nombre requerido' : null,
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<TreatmentCategory>(
                    value: _selectedCategory,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Especialidad Odontológica *',
                      prefixIcon: Icon(Icons.category_outlined, size: 20),
                    ),
                    items: TreatmentCategory.values.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            Icon(cat.icon, size: 18, color: cat.color),
                            const SizedBox(width: 8),
                            Flexible(child: Text(cat.label)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedCategory = v);
                    },
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Precio Base (S/.) *',
                            prefixIcon: Icon(Icons.payments_outlined, size: 20),
                          ),
                          validator: (v) {
                            final price = double.tryParse(v?.trim() ?? '');
                            if (price == null || price < 0) return 'Precio inválido';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Duración (min) *',
                            prefixIcon: Icon(Icons.timer_outlined, size: 20),
                          ),
                          validator: (v) {
                            final min = int.tryParse(v?.trim() ?? '');
                            if (min == null || min < 5) return 'Mínimo 5 min';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Descripción / Protocolo clínico',
                      hintText: 'Incluye materiales o pasos principales...',
                      prefixIcon: Icon(Icons.notes_outlined, size: 20),
                    ),
                  ),
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
                        icon: Icon(isEditing ? Icons.save_outlined : Icons.add),
                        label: Text(isEditing ? 'Guardar' : 'Crear Tratamiento'),
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final request = TreatmentRequest(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory.code,
      price: double.parse(_priceController.text.trim()),
      estimatedDurationMinutes: int.parse(_durationController.text.trim()),
      isActive: true,
    );

    Navigator.pop(context, request);
  }
}
