import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/add_medical_history_request.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/model/patient.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/di/presentation_module.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/widgets/medical_history_card.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/widgets/medical_history_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedicalHistoriesView extends ConsumerWidget {
  const MedicalHistoriesView({super.key, required this.patient});
  final Patient patient;

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Map<String, dynamic>>(
        context: context, builder: (_) => MedicalHistoryForm(patient: patient));
    if (result == null || !context.mounted) return;
    final model =
        ref.read(medicalHistoriesViewModelProvider(patient.id).notifier);
    await model.addMedicalHistory(
        result['request'] as AddMedicalHistoryRequest, patient.id);
    if (context.mounted && model.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(model.errorMessage!)));
    }
  }

  Future<void> _annul(
      BuildContext context, WidgetRef ref, int historyId) async {
    final reason = await showDialog<String>(
        context: context, builder: (_) => const AnnulMedicalHistoryDialog());
    if (reason == null || reason.trim().isEmpty || !context.mounted) return;
    final model =
        ref.read(medicalHistoriesViewModelProvider(patient.id).notifier);
    final error =
        await model.annulMedicalHistory(patient.id, historyId, reason.trim());
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(error ?? 'Entrada anulada. Sigue visible en el historial.')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = medicalHistoriesViewModelProvider(patient.id);
    final histories = [...ref.watch(provider)]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final model = ref.watch(provider.notifier);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Historial médico'), actions: [
        IconButton(
            tooltip: 'Actualizar historial',
            onPressed: () => model.getAllMedicalHistories(patient.id),
            icon: const Icon(Icons.refresh)),
      ]),
      body: Center(
          child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    Text(patient.fullName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    FilledButton.icon(
                        onPressed: () => _add(context, ref),
                        icon: const Icon(Icons.add),
                        label: const Text('Nueva evolución')),
                  ])),
          Expanded(
              child: model.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : model.errorMessage != null
                      ? Center(
                          child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(model.errorMessage!),
                                    TextButton(
                                        onPressed: () => model
                                            .getAllMedicalHistories(patient.id),
                                        child: const Text('Reintentar')),
                                  ])))
                      : histories.isEmpty
                          ? const Center(
                              child: Text(
                                  'Aún no hay evoluciones médicas registradas.'))
                          : RefreshIndicator(
                              onRefresh: () =>
                                  model.getAllMedicalHistories(patient.id),
                              child: ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 8, 24),
                                  itemCount: histories.length,
                                  itemBuilder: (_, index) => MedicalHistoryCard(
                                      medicalHistory: histories[index],
                                      onAnnul: () => _annul(context, ref,
                                          histories[index].id))))),
        ]),
      )),
    );
  }
}
