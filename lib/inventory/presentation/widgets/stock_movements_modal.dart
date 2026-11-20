import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/inventory/domain/model/log_entry.dart';
import 'package:dentify_flutter/inventory/presentation/di/presentation_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class StockMovementsModal extends ConsumerStatefulWidget {
  const StockMovementsModal({super.key});

  @override
  ConsumerState<StockMovementsModal> createState() =>
      _StockMovementsModalState();
}

class _StockMovementsModalState extends ConsumerState<StockMovementsModal> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(logEntriesViewModelProvider.notifier).getAllLogEntries();
    });
  }

  String _formatDate(LogEntry entry) {
    final dt = entry.createdAtDate;
    if (dt == null) {
      return entry.createdAt.isNotEmpty ? entry.createdAt : 'Fecha no disponible';
    }
    return DateFormat('dd/MM/yyyy · hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final entriesState = ref.watch(logEntriesViewModelProvider);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 640,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      size: 19,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Movimientos de Stock',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          'Historial cronológico de entradas y salidas',
                          style: TextStyle(fontSize: 12, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Actualizar movimientos',
                    onPressed: () => ref
                        .read(logEntriesViewModelProvider.notifier)
                        .getAllLogEntries(),
                    icon: const Icon(Icons.refresh_rounded,
                        size: 20, color: AppColors.muted),
                  ),
                  IconButton(
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close,
                        size: 20, color: AppColors.muted),
                  ),
                ],
              ),
              const Divider(height: 20),
              Flexible(
                child: entriesState.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 36, color: AppColors.danger),
                          const SizedBox(height: 8),
                          const Text(
                            'No se pudieron cargar los movimientos.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: () => ref
                                .read(logEntriesViewModelProvider.notifier)
                                .getAllLogEntries(),
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (entries) {
                    if (entries.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.inventory_2_outlined,
                                  size: 38, color: AppColors.muted),
                              SizedBox(height: 8),
                              Text(
                                'Sin movimientos registrados',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Cada alta o ajuste de stock aparecerá aquí.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, index) =>
                          _buildMovementItem(entries[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovementItem(LogEntry entry) {
    final isIncrease = entry.isIncrease;
    final isDecrease = entry.isDecrease;
    final Color badgeBg = isDecrease
        ? AppColors.dangerLight
        : isIncrease
            ? AppColors.successLight
            : AppColors.surfaceSubtle;
    final Color badgeBorder = isDecrease
        ? AppColors.dangerBorder
        : isIncrease
            ? AppColors.successBorder
            : AppColors.border;
    final Color badgeText = isDecrease
        ? AppColors.danger
        : isIncrease
            ? AppColors.success
            : AppColors.muted;

    final deltaText = entry.delta > 0
        ? '+${entry.delta}'
        : entry.delta < 0
            ? '${entry.delta}'
            : '0';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: badgeBorder),
            ),
            child: Icon(
              isDecrease
                  ? Icons.arrow_downward_rounded
                  : isIncrease
                      ? Icons.arrow_upward_rounded
                      : Icons.sync_alt_rounded,
              size: 17,
              color: badgeText,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.itemName,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.reason,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.ink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDate(entry),
                  style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: badgeBorder),
                ),
                child: Text(
                  '$deltaText uds',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: badgeText,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${entry.previousStock} → ${entry.newStock}',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
