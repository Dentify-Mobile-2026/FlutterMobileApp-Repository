import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/model/patient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/treatment_plan.dart';
import '../viewmodels/treatment_plans_view_model.dart';
import '../widgets/treatment_plan_form.dart';

class TreatmentPlansView extends ConsumerStatefulWidget {
  final Patient patient;
  const TreatmentPlansView({super.key, required this.patient});
  @override
  ConsumerState<TreatmentPlansView> createState() => _TreatmentPlansViewState();
}

class _TreatmentPlansViewState extends ConsumerState<TreatmentPlansView> {
  bool _busy = false;
  TreatmentPlansViewModel get model =>
      ref.read(treatmentPlansProvider(widget.patient.id).notifier);

  Future<void> _update(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel(TreatmentPlan plan) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Cancelar plan'),
                content: Text(
                    '¿Cancelar “${plan.title}”? Se conservará el avance registrado.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Volver')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Cancelar plan'))
                ]));
    if (confirmed == true && mounted) {
      await _update(() => model.changeStatus(plan.id, 'CANCELLED'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(treatmentPlansProvider(widget.patient.id));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Planes de tratamiento'), actions: [
        IconButton(
            tooltip: 'Actualizar',
            onPressed: _busy ? null : model.load,
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
                    Text(widget.patient.fullName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    FilledButton.icon(
                        onPressed: _busy
                            ? null
                            : () => showDialog<void>(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) =>
                                    TreatmentPlanForm(onSave: model.create)),
                        icon: const Icon(Icons.add),
                        label: const Text('Nuevo presupuesto')),
                  ])),
          if (_busy) const LinearProgressIndicator(),
          Expanded(
              child: plans.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(error.toString()),
                      TextButton(
                          onPressed: model.load,
                          child: const Text('Reintentar'))
                    ]))),
            data: (list) => list.isEmpty
                ? const Center(
                    child: Text('Este paciente aún no tiene presupuestos.'))
                : RefreshIndicator(
                    onRefresh: model.load,
                    child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: list.length,
                        itemBuilder: (_, index) => _card(list[index]))),
          )),
        ]),
      )),
    );
  }

  Widget _card(TreatmentPlan plan) => Card(
        margin: const EdgeInsets.only(bottom: 14),
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(plan.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 12, runSpacing: 8, children: [
                    Text(plan.statusLabel),
                    Text(plan.totalAmount.formatted,
                        style: const TextStyle(fontWeight: FontWeight.w700))
                  ]),
                  if (plan.notes.isNotEmpty)
                    Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(plan.notes)),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                      value: plan.progress,
                      backgroundColor: AppColors.background,
                      color: AppColors.primary),
                  const SizedBox(height: 6),
                  Text(
                      '${plan.completedItems}/${plan.totalItems} sesiones realizadas · ${(plan.progress * 100).round()}%'),
                  const Divider(height: 24),
                  for (final item in plan.items)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(item.treatmentName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Text(
                                  '${item.toothNumber == null ? 'Sin pieza específica' : 'Pieza ${item.toothNumber}'} · ${item.agreedPrice.formatted}',
                                  style:
                                      const TextStyle(color: AppColors.muted)),
                              DropdownButton<String>(
                                  value: item.itemStatus,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'PENDING',
                                        child: Text('Pendiente')),
                                    DropdownMenuItem(
                                        value: 'IN_PROGRESS',
                                        child: Text('En curso')),
                                    DropdownMenuItem(
                                        value: 'DONE', child: Text('Realizado'))
                                  ],
                                  onChanged: _busy || !plan.canUpdateItems
                                      ? null
                                      : (status) {
                                          if (status != null) {
                                            _update(() =>
                                                model.changeItemStatus(
                                                    plan.id, item.id, status));
                                          }
                                        }),
                            ])),
                  Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (plan.status == 'DRAFT')
                          FilledButton(
                              onPressed: _busy
                                  ? null
                                  : () => _update(() =>
                                      model.changeStatus(plan.id, 'APPROVED')),
                              child: const Text('Aprobar presupuesto')),
                        if (plan.status != 'CANCELLED' &&
                            plan.status != 'COMPLETED')
                          TextButton(
                              onPressed: _busy ? null : () => _cancel(plan),
                              child: const Text('Cancelar plan')),
                      ]),
                ])),
      );
}
