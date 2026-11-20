import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/payment/domain/model/payment_method.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Selector de método de pago con `ChoiceChip`s, con estados de carga, error
/// (con "Reintentar") y lista vacía.
class PaymentMethodPicker extends StatelessWidget {
  final AsyncValue<List<PaymentMethod>> methodsState;
  final int? selectedMethodId;
  final bool enabled;
  final ValueChanged<int> onSelected;
  final VoidCallback onRetry;

  const PaymentMethodPicker({
    super.key,
    required this.methodsState,
    required this.selectedMethodId,
    required this.onSelected,
    required this.onRetry,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return methodsState.when(
      loading: () => const Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Flexible(
            child: Text(
              'Cargando métodos de pago…',
              style: TextStyle(fontSize: 12.5, color: AppColors.muted),
            ),
          ),
        ],
      ),
      error: (_, __) => PaymentInlineRetry(
        message: 'No se pudieron cargar los métodos de pago.',
        onRetry: onRetry,
      ),
      data: (methods) {
        if (methods.isEmpty) {
          return const Text(
            'No hay métodos de pago configurados.',
            style: TextStyle(fontSize: 12.5, color: AppColors.muted),
          );
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final method in methods)
              ChoiceChip(
                label: Text(
                  method.name,
                  style: TextStyle(
                    fontWeight: method.id == selectedMethodId
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: method.id == selectedMethodId
                        ? AppColors.primaryDark
                        : AppColors.ink,
                  ),
                ),
                tooltip:
                    method.description.isNotEmpty ? method.description : null,
                selected: method.id == selectedMethodId,
                selectedColor: AppColors.mint,
                onSelected: enabled ? (_) => onSelected(method.id) : null,
              ),
          ],
        );
      },
    );
  }
}

/// Mensaje de error en línea con botón "Reintentar".
class PaymentInlineRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const PaymentInlineRetry({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          Text(
            message,
            style: const TextStyle(fontSize: 12.5, color: AppColors.danger),
          ),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
