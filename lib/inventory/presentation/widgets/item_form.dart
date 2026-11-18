import 'package:dentify_flutter/inventory/data/remote/dto/item_request.dart';
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
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    print('name: ${_nameController.text}');
    print('quantity: ${_quantityController.text}');
    print('price: ${_priceController.text}');
    print('category: $_category');

    final request = ItemRequest(
      name: _nameController.text.trim(),
      stockQuantity: int.tryParse(_quantityController.text.trim()) ?? 0,
      price: double.tryParse(_priceController.text.trim()) ?? 0.0,
      category: _category!,
      isActive: true,
    );

    print('request toJson: ${request.toJson()}');

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFFF5FFFD), // Fondo como las tarjetas
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing ? 'Edit Item' : 'New Item',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField('Name', _nameController),
              _buildTextField('Quantity', _quantityController, isNumber: true),
              _buildTextField('Price', _priceController, isDecimal: true),
              _buildDropdown(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[800],
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3E50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(_isEditing ? 'Save' : 'Register'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false, bool isDecimal = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber
            ? TextInputType.number
            : isDecimal
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Required';
          if ((isNumber || isDecimal) && double.tryParse(value) == null) {
            return 'Invalid number';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: DropdownButtonFormField<String>(
        value: _category,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Category',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        hint: const Text("Select a category"),
        items: _categories.map((cat) {
          return DropdownMenuItem(value: cat, child: Text(cat));
        }).toList(),
        onChanged: (value) => setState(() => _category = value),
        validator: (value) => value == null ? 'Required' : null,
      ),
    );
  }
}
