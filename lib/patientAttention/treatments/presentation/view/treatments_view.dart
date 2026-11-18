import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/patientAttention/treatments/data/remote/dto/treatment_request.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/model/treatment_category.dart';
import 'package:dentify_flutter/patientAttention/treatments/presentation/di/presentation_module.dart';
import 'package:dentify_flutter/patientAttention/treatments/presentation/widgets/treatment_card.dart';
import 'package:dentify_flutter/patientAttention/treatments/presentation/widgets/treatment_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TreatmentsView extends ConsumerWidget {
  const TreatmentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTreatments = ref.watch(treatmentsViewModelProvider);
    final treatments = ref.watch(filteredTreatmentsProvider);
    final isLoading = ref.watch(treatmentLoadingProvider);
    final selectedCat = ref.watch(treatmentSelectedCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        title: const Text(
          'Catálogo de Tratamientos Dentales',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Recargar catálogo',
            onPressed: () =>
                ref.read(treatmentsViewModelProvider.notifier).getAllTreatments(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: TextField(
              onChanged: (v) {
                ref.read(treatmentSearchQueryProvider.notifier).state = v;
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar tratamiento o especialidad...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('Todos (${allTreatments.length})'),
                    selected: selectedCat == null,
                    selectedColor: AppColors.mint,
                    onSelected: (_) {
                      ref.read(treatmentSelectedCategoryProvider.notifier).state =
                          null;
                    },
                  ),
                ),
                ...TreatmentCategory.values.map((cat) {
                  final isSelected = selectedCat == cat.code;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: Icon(cat.icon, size: 16, color: cat.color),
                      label: Text(cat.label),
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
          const SizedBox(height: 6),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : treatments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.medical_services_outlined,
                                size: 54, color: AppColors.muted),
                            const SizedBox(height: 12),
                            Text(
                              allTreatments.isEmpty
                                  ? 'No hay tratamientos en tu catálogo aún.'
                                  : 'Ningún tratamiento coincide con la búsqueda.',
                              style: const TextStyle(
                                  fontSize: 16, color: AppColors.muted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                        itemCount: treatments.length,
                        itemBuilder: (context, index) {
                          return TreatmentCard(treatment: treatments[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final req = await showDialog<TreatmentRequest>(
                context: context,
                builder: (_) => const TreatmentForm(),
              );
              if (req != null) {
                await ref
                    .read(treatmentsViewModelProvider.notifier)
                    .addTreatment(req);
                final vm = ref.read(treatmentsViewModelProvider.notifier);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          vm.errorMessage ?? 'Tratamiento agregado al catálogo'),
                      backgroundColor: vm.errorMessage != null
                          ? AppColors.danger
                          : AppColors.success,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Nuevo Tratamiento Dental'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
