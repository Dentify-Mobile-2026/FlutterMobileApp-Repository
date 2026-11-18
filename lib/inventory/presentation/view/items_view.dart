import 'package:dentify_flutter/inventory/data/remote/dto/item_request.dart';
import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/inventory/presentation/widgets/item_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dentify_flutter/inventory/presentation/di/presentation_module.dart';

class ItemsView extends ConsumerWidget {
  const ItemsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itemsViewModelProvider);
    final isLoading = ref.watch(itemsViewModelProvider.notifier).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background, // Fondo general
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        title: const Text(
          "Items",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(
              child: Text(
                "No items found",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  color: const Color.fromARGB(255, 255, 255, 255), // Color de la tarjeta
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.mint,
                            borderRadius: BorderRadius.circular(12)
                          ),
                          padding: const EdgeInsets.all(12),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        tooltip: 'Edit',
                                        icon: const Icon(Icons.edit, color: Colors.black87),
                                        onPressed: () async {
                                          final result = await showDialog<Map<String, dynamic>>(
                                            context: context,
                                            builder: (context) => ItemFormDialog(initialItem: item),
                                          );
                                          if (result != null && result.containsKey('edit')) {
                                            final id = result['id'] as int;
                                            final edit = result['edit'] as ItemRequest;
                                            await ref.read(itemsViewModelProvider.notifier).updateItem(id, edit);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Item updated")),
                                              );
                                            }
                                            ref.read(itemsViewModelProvider.notifier).getAllItems();
                                          }
                                        },
                                      ),
                                      IconButton(
                                        tooltip: 'Delete',
                                        icon: Icon(Icons.delete, color: Colors.black87),
                                        onPressed: () async {
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text("Delete Item"),
                                              content: const Text("Are you sure you want to delete this item?"),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
                                              ],
                                            ),
                                          );
                                          if (confirmed == true) {
                                            ref.read(itemsViewModelProvider.notifier).deleteItem(item.id);
                                        
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Item deleted")),
                                              );
                                            }
                                            ref.read(itemsViewModelProvider.notifier).getAllItems();
                                          }
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.category,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                children: [
                                  _InfoText(label: 'Price', value: 'S/ ${item.price.toStringAsFixed(2)}'),
                                  _InfoText(label: 'Stock', value: '${item.stockQuantity}'),
                                  _InfoText(label: 'Active', value: item.isActive ? 'Yes' : 'No'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (context) => const ItemFormDialog(),
          );
          if (result != null && result.containsKey('new')) {
            final newItem = result['new'] as ItemRequest;
            await ref.read(itemsViewModelProvider.notifier).addItem(newItem);
            ref.read(itemsViewModelProvider.notifier).getAllItems();
          }
        },
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        label: const Text(
          'New Item',
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: Colors.white,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _InfoText extends StatelessWidget {
  final String label;
  final String value;

  const _InfoText({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}