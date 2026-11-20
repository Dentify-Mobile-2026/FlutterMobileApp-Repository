import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/inventory/data/remote/dto/item_request.dart';
import 'package:dentify_flutter/inventory/presentation/di/presentation_module.dart';
import 'package:dentify_flutter/inventory/presentation/widgets/item_form.dart';
import 'package:dentify_flutter/inventory/presentation/widgets/stock_movements_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemsView extends ConsumerStatefulWidget {
  const ItemsView({super.key});

  @override
  ConsumerState<ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends ConsumerState<ItemsView> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(itemsViewModelProvider.notifier).getAllItems();
    });
  }

  String _formatCategory(String raw) {
    return raw
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  void _openMovementsModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const StockMovementsModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allItems = ref.watch(itemsViewModelProvider);
    final isLoading = ref.watch(itemsViewModelProvider.notifier).isLoading;

    final items = allItems.where((i) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return i.name.toLowerCase().contains(q) ||
          i.category.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Inventario',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      '${allItems.length} insumos registrados',
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.muted),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Actualizar inventario',
                      visualDensity: VisualDensity.compact,
                      onPressed: () =>
                          ref.read(itemsViewModelProvider.notifier).getAllItems(),
                      icon: const Icon(Icons.refresh_rounded,
                          color: AppColors.muted),
                    ),
                    const SizedBox(width: 4),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryDark,
                        backgroundColor: AppColors.surface,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                      onPressed: () => _openMovementsModal(context),
                      icon: const Icon(Icons.history_rounded, size: 16),
                      label: const Text('Movimientos',
                          style: TextStyle(fontSize: 12.5)),
                    ),
                    const SizedBox(width: 6),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 9),
                      ),
                      onPressed: () async {
                        final result = await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (context) => const ItemFormDialog(),
                        );
                        if (result != null && result.containsKey('new')) {
                          final newItem = result['new'] as ItemRequest;
                          await ref
                              .read(itemsViewModelProvider.notifier)
                              .addItem(newItem);
                          ref
                              .read(itemsViewModelProvider.notifier)
                              .getAllItems();
                        }
                      },
                      icon: const Icon(Icons.add, size: 17),
                      label: const Text('Nuevo',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(fontSize: 13.5),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                prefixIcon: const Icon(Icons.search, size: 19),
                hintText: 'Buscar insumo o categoría...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? const Center(
                        child: Text(
                          'No se encontraron insumos.',
                          style:
                              TextStyle(fontSize: 14, color: AppColors.muted),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final isCritical = item.stockQuantity <= 3;
                          final isLow =
                              item.stockQuantity > 3 && item.stockQuantity < 10;

                          final Color borderColor = isCritical
                              ? AppColors.dangerBorder
                              : isLow
                                  ? AppColors.warningBorder
                                  : AppColors.successBorder;
                          final Color dotColor = isCritical
                              ? AppColors.danger
                              : isLow
                                  ? AppColors.warning
                                  : AppColors.success;
                          final String stockLabel = '${item.stockQuantity} uds';

                          return Card(
                            color: AppColors.surface,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: borderColor,
                                width: isCritical || isLow ? 1.3 : 1,
                              ),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceSubtle,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.inventory_2_outlined,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatCategory(item.category),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.muted,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color: AppColors.surfaceSubtle,
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                              ),
                                              child: Text(
                                                'S/. ${item.price.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.ink,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color: AppColors.surface,
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                border: Border.all(
                                                    color: borderColor),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration: BoxDecoration(
                                                      color: dotColor,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    stockLabel,
                                                    style: const TextStyle(
                                                      fontSize: 11.5,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors.ink,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Editar insumo',
                                    visualDensity: VisualDensity.compact,
                                    iconSize: 18,
                                    icon: const Icon(Icons.edit_outlined,
                                        color: AppColors.muted),
                                    onPressed: () async {
                                      final result = await showDialog<
                                          Map<String, dynamic>>(
                                        context: context,
                                        builder: (context) =>
                                            ItemFormDialog(initialItem: item),
                                      );
                                      if (result != null &&
                                          result.containsKey('edit')) {
                                        final id = result['id'] as int;
                                        final edit =
                                            result['edit'] as ItemRequest;
                                        await ref
                                            .read(
                                                itemsViewModelProvider.notifier)
                                            .updateItem(id, edit);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text('Insumo actualizado'),
                                            ),
                                          );
                                        }
                                        ref
                                            .read(
                                                itemsViewModelProvider.notifier)
                                            .getAllItems();
                                      }
                                    },
                                  ),
                                  IconButton(
                                    tooltip: 'Eliminar insumo',
                                    visualDensity: VisualDensity.compact,
                                    iconSize: 18,
                                    icon: const Icon(Icons.delete_outline,
                                        color: AppColors.muted),
                                    onPressed: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('Eliminar Insumo'),
                                          content: Text(
                                              '¿Eliminar "${item.name}" del inventario?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancelar'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.danger),
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Eliminar'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true) {
                                        await ref
                                            .read(
                                                itemsViewModelProvider.notifier)
                                            .deleteItem(item.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('Insumo eliminado'),
                                            ),
                                          );
                                        }
                                        ref
                                            .read(
                                                itemsViewModelProvider.notifier)
                                            .getAllItems();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
