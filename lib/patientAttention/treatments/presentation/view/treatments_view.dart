import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/patientAttention/treatments/data/remote/dto/treatment_request.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/model/treatment_category.dart';
import 'package:dentify_flutter/patientAttention/treatments/presentation/di/presentation_module.dart';
import 'package:dentify_flutter/patientAttention/treatments/presentation/widgets/treatment_card.dart';
import 'package:dentify_flutter/patientAttention/treatments/presentation/widgets/treatment_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TreatmentsView extends ConsumerStatefulWidget {
  const TreatmentsView({super.key});

  @override
  ConsumerState<TreatmentsView> createState() => _TreatmentsViewState();
}

class _TreatmentsViewState extends ConsumerState<TreatmentsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(treatmentsViewModelProvider.notifier).getAllTreatments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final allTreatments = ref.watch(treatmentsViewModelProvider);
    final treatments = ref.watch(filteredTreatmentsProvider);
    final isLoading = ref.watch(treatmentLoadingProvider);
    final selectedCat = ref.watch(treatmentSelectedCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Catálogo de Tratamientos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        '${allTreatments.length} procedimientos con arancel y duración base',
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Recargar catálogo',
                  onPressed: () => ref
                      .read(treatmentsViewModelProvider.notifier)
                      .getAllTreatments(),
                  icon:
                      const Icon(Icons.refresh_rounded, color: AppColors.muted),
                ),
                const SizedBox(width: 6),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  ),
                  onPressed: () => _onAddTreatment(context),
                  icon: const Icon(Icons.add, size: 17),
                  label: const Text('Nuevo', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              onChanged: (v) {
                ref.read(treatmentSearchQueryProvider.notifier).state = v;
              },
              style: const TextStyle(fontSize: 13.5),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                prefixIcon: const Icon(Icons.search, size: 19),
                hintText: 'Buscar tratamiento o especialidad...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    visualDensity: VisualDensity.compact,
                    label: Text(
                      'Todos (${allTreatments.length})',
                      style: const TextStyle(fontSize: 12),
                    ),
                    selected: selectedCat == null,
                    selectedColor: AppColors.mint,
                    onSelected: (_) {
                      ref
                          .read(treatmentSelectedCategoryProvider.notifier)
                          .state = null;
                    },
                  ),
                ),
                ...TreatmentCategory.values.map((cat) {
                  final isSelected = selectedCat == cat.code;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      visualDensity: VisualDensity.compact,
                      avatar: Icon(cat.icon, size: 15, color: cat.color),
                      label: Text(
                        cat.label,
                        style: const TextStyle(fontSize: 12),
                      ),
                      selected: isSelected,
                      selectedColor: cat.bgColor,
                      onSelected: (_) {
                        ref
                            .read(treatmentSelectedCategoryProvider.notifier)
                            .state = isSelected ? null : cat.code;
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : treatments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.medical_services_outlined,
                                size: 44, color: AppColors.muted),
                            const SizedBox(height: 10),
                            Text(
                              allTreatments.isEmpty
                                  ? 'No hay tratamientos en tu catálogo aún.'
                                  : 'Ningún tratamiento coincide con la búsqueda.',
                              style: const TextStyle(
                                  fontSize: 14, color: AppColors.muted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: treatments.length,
                        itemBuilder: (context, index) {
                          return TreatmentCard(treatment: treatments[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _onAddTreatment(BuildContext context) async {
    final req = await showDialog<TreatmentRequest>(
      context: context,
      builder: (_) => const TreatmentForm(),
    );
    if (req != null) {
      await ref.read(treatmentsViewModelProvider.notifier).addTreatment(req);
      final vm = ref.read(treatmentsViewModelProvider.notifier);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(vm.errorMessage ?? 'Tratamiento agregado al catálogo'),
            backgroundColor:
                vm.errorMessage != null ? AppColors.danger : AppColors.success,
          ),
        );
      }
    }
  }
}
