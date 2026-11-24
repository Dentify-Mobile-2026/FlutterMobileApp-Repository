import 'package:dentify_flutter/inventory/data/remote/dto/item_request.dart';
import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/inventory/domain/model/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemFormDialog extends ConsumerStatefulWidget {
  final Item? initialItem;

  const ItemFormDialog({super.key, this.initialItem});

  @override
  ConsumerState<ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends ConsumerState<ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  String? _category;
  bool _isEditing = false;

  final _categories = const [
    'DENTAL_INSTRUMENTS',
    'DISPOSABLE_SUPPLIES',
    'CLEANING_AND_DISINFECTION',
    'RESTORATIVE_MATERIALS',
    'ORTHODONTIC_SUPPLIES',
    'ENDODONTIC_SUPPLIES',
    'SURGICAL_SUPPLIES',
    'PROTECTIVE_EQUIPMENT',
    'IMAGING_EQUIPMENT',
    'CONSUMABLES',
    'MEDICATIONS',
  ];

  static const Map<String, String> _categoryLabels = {
    'DENTAL_INSTRUMENTS': 'Instrumental dental',
    'DISPOSABLE_SUPPLIES': 'Descartables',
    'CLEANING_AND_DISINFECTION': 'Limpieza y desinfección',
    'RESTORATIVE_MATERIALS': 'Materiales restauradores',
    'ORTHODONTIC_SUPPLIES': 'Ortodoncia',
    'ENDODONTIC_SUPPLIES': 'Endodoncia',
    'SURGICAL_SUPPLIES': 'Material quirúrgico',
    'PROTECTIVE_EQUIPMENT': 'Protección personal',
    'IMAGING_EQUIPMENT': 'Equipos de imagen',
    'CONSUMABLES': 'Consumibles',
    'MEDICATIONS': 'Medicamentos',
  };

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    if (item != null) {
      _isEditing = true;
      _nameController.text = item.name;
      _quantityController.text = item.stockQuantity.toString();
      _priceController.text = item.price.toString();
      _category = item.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_category == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona una categoría')),
        );
        return;
      }

      final parsedPrice =
          double.tryParse(_priceController.text.trim().replaceAll(',', '.')) ??
              0.0;
      final request = ItemRequest(
        name: _nameController.text.trim(),
        stockQuantity: int.tryParse(_quantityController.text.trim()) ?? 0,
        price: parsedPrice,
        category: _category!,
        isActive: true,
      );

      if (_isEditing) {
        Navigator.pop(context, {'id': widget.initialItem!.id, 'edit': request});
      } else {
        Navigator.pop(context, {'new': request});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        Icons.inventory_2_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEditing ? 'Editar insumo' : 'Nuevo insumo',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const Text(
                            'Completa los datos de stock y costo unitario',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField('Nombre del insumo *', _nameController),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Cantidad en stock *',
                        _quantityController,
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        'Precio unitario (S/) *',
                        _priceController,
                        isDecimal: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDropdown(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _submitForm,
                      child: Text(_isEditing ? 'Guardar' : 'Registrar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool isDecimal = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber
          ? TextInputType.number
          : isDecimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        final raw = (value ?? '').trim();
        if (raw.isEmpty) return 'Campo obligatorio';
        if (isNumber) {
          final parsed = int.tryParse(raw);
          if (parsed == null || parsed < 0) return 'Número inválido';
        } else if (isDecimal) {
          final parsed = double.tryParse(raw.replaceAll(',', '.'));
          if (parsed == null || parsed < 0) return 'Monto inválido';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _category,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Categoría *'),
      hint: const Text('Selecciona una categoría'),
      items: _categories.map((cat) {
        return DropdownMenuItem(
          value: cat,
          child: Text(_categoryLabels[cat] ?? cat),
        );
      }).toList(),
      onChanged: (value) => setState(() => _category = value),
      validator: (value) => value == null ? 'Campo obligatorio' : null,
    );
  }
}
