import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/model/treatment.dart';
import 'package:dentify_flutter/patientAttention/treatments/presentation/di/presentation_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/plan_amount.dart';
import '../../domain/model/treatment_plan.dart';

class TreatmentPlanForm extends ConsumerStatefulWidget {
  final Future<void> Function(TreatmentPlanDraft) onSave;
  const TreatmentPlanForm({super.key, required this.onSave});
  @override
  ConsumerState<TreatmentPlanForm> createState() => _TreatmentPlanFormState();
}

class _QuoteRow {
  Treatment? treatment;
  final tooth = TextEditingController();
  final price = TextEditingController();
  void dispose() {
    tooth.dispose();
    price.dispose();
  }
}

class _TreatmentPlanFormState extends ConsumerState<TreatmentPlanForm> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _notes = TextEditingController();
  final _rows = <_QuoteRow>[_QuoteRow(), _QuoteRow()];
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      if (ref.read(treatmentsViewModelProvider).isEmpty) {
        ref.read(treatmentsViewModelProvider.notifier).getAllTreatments();
      }
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(TreatmentPlanDraft(
          title: _title.text.trim(),
          notes: _notes.text.trim(),
          items: _rows
              .map((row) => PlanItemDraft(
                  treatmentId: row.treatment!.id,
                  toothNumber: row.tooth.text.trim().isEmpty
                      ? null
                      : row.tooth.text.trim(),
                  agreedPrice: PlanAmount.tryParse(row.price.text)!))
              .toList()));
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref
        .watch(treatmentsViewModelProvider)
        .where((t) => t.isActive)
        .toList();
    final loading = ref.watch(treatmentLoadingProvider);
    final total = PlanAmount(_rows.fold(0,
        (sum, row) => sum + (PlanAmount.tryParse(row.price.text)?.cents ?? 0)));
    return PopScope(
      canPop: !_saving,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
                key: _form,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Nuevo presupuesto',
                          style: TextStyle(
                              fontSize: 21, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
                      TextFormField(
                          controller: _title,
                          enabled: !_saving,
                          maxLength: 120,
                          decoration: const InputDecoration(
                              labelText: 'Título del plan'),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Ingresa un título'
                                  : null),
                      TextFormField(
                          controller: _notes,
                          enabled: !_saving,
                          maxLength: 1000,
                          maxLines: 2,
                          decoration: const InputDecoration(
                              labelText: 'Notas (opcional)')),
                      if (loading) const LinearProgressIndicator(),
                      if (!loading && catalog.isEmpty)
                        Column(children: [
                          const Text(
                              'No hay tratamientos activos disponibles. Revisa el catálogo o vuelve a cargarlo.'),
                          TextButton(
                              onPressed: () => ref
                                  .read(treatmentsViewModelProvider.notifier)
                                  .getAllTreatments(),
                              child: const Text('Recargar catálogo')),
                        ]),
                      for (var index = 0; index < _rows.length; index++) ...[
                        const SizedBox(height: 12),
                        _buildRow(index, catalog),
                      ],
                      const SizedBox(height: 12),
                      TextButton.icon(
                          onPressed: _saving || _rows.length >= 100
                              ? null
                              : () => setState(() => _rows.add(_QuoteRow())),
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar tratamiento / pieza')),
                      const Divider(height: 24),
                      Text('Total: ${total.formatted}',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink)),
                      if (_error != null)
                        Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(_error!,
                                style:
                                    const TextStyle(color: AppColors.danger))),
                      const SizedBox(height: 20),
                      Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            TextButton(
                                onPressed: _saving
                                    ? null
                                    : () => Navigator.pop(context),
                                child: const Text('Cancelar')),
                            FilledButton(
                                onPressed: _saving || loading || catalog.isEmpty
                                    ? null
                                    : _save,
                                child: Text(_saving
                                    ? 'Guardando…'
                                    : 'Crear presupuesto')),
                          ]),
                    ])),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(int index, List<Treatment> catalog) {
    final row = _rows[index];
    return Container(
      key: ObjectKey(row),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.background, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
              child: Text('Tratamiento ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          if (_rows.length > 2)
            IconButton(
                tooltip: 'Quitar tratamiento',
                onPressed: _saving
                    ? null
                    : () => setState(() {
                          _rows.removeAt(index);
                          row.dispose();
                        }),
                icon: const Icon(Icons.close, size: 18)),
        ]),
        DropdownButtonFormField<int>(
            initialValue: row.treatment?.id,
            isExpanded: true,
            decoration:
                const InputDecoration(labelText: 'Tratamiento del catálogo'),
            items: catalog
                .map((t) => DropdownMenuItem(
                    value: t.id,
                    child: Text(t.name, overflow: TextOverflow.ellipsis)))
                .toList(),
            validator: (value) =>
                value == null ? 'Selecciona un tratamiento' : null,
            onChanged: _saving
                ? null
                : (id) => setState(() {
                      row.treatment = catalog.firstWhere((t) => t.id == id);
                      row.price.text = row.treatment!.price.toStringAsFixed(2);
                    })),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: TextFormField(
                  controller: row.tooth,
                  enabled: !_saving,
                  maxLength: 2,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Pieza (opcional)', hintText: '11'),
                  validator: (value) => value == null ||
                          value.trim().isEmpty ||
                          RegExp(r'^([1-4][1-8]|[5-8][1-5])$')
                              .hasMatch(value.trim())
                      ? null
                      : 'Usa numeración FDI')),
          const SizedBox(width: 12),
          Expanded(
              child: TextFormField(
                  controller: row.price,
                  enabled: !_saving,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Precio S/.'),
                  onChanged: (_) => setState(() {}),
                  validator: (value) => PlanAmount.tryParse(value ?? '') == null
                      ? 'Monto inválido (2 decimales)'
                      : null)),
        ]),
      ]),
    );
  }
}
