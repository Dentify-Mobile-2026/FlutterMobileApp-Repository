import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/patientAttention/business_hours/data/business_hours_service.dart';
import 'package:dentify_flutter/patientAttention/business_hours/domain/business_day.dart';
import 'package:flutter/material.dart';

/// Pantalla para definir el horario de atención del consultorio (US09).
///
/// El horario solo se aplica a las citas que se creen o reprogramen después de
/// guardarlo; las citas ya agendadas no cambian.
class BusinessHoursView extends StatefulWidget {
  const BusinessHoursView({super.key, this.service});

  /// Permite inyectar un servicio en las pruebas.
  final BusinessHoursService? service;

  @override
  State<BusinessHoursView> createState() => _BusinessHoursViewState();
}

class _BusinessHoursViewState extends State<BusinessHoursView> {
  late final BusinessHoursService _service =
      widget.service ?? BusinessHoursService(ApiConstants.baseUrl);

  List<BusinessDay> _days = [];
  bool _configured = false;
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final hours = await _service.getBusinessHours();
      if (!mounted) return;
      setState(() {
        _days = hours.days;
        _configured = hours.configured;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _loading = false;
      });
    }
  }

  bool get _allValid => _days.isNotEmpty && _days.every((d) => d.isValid);

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final saved = await _service.saveBusinessHours(_days);
      if (!mounted) return;
      setState(() {
        _days = saved.days;
        _configured = saved.configured;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Horario guardado. Se aplicará a las citas nuevas o reprogramadas.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickTime(int index, {required bool opening}) async {
    final day = _days[index];
    final current = opening ? day.opensAt : day.closesAt;
    final minutes = BusinessDay.minutesOf(current) ?? (opening ? 540 : 1080);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
      helpText: opening
          ? 'Hora de apertura del ${day.label.toLowerCase()}'
          : 'Hora de cierre del ${day.label.toLowerCase()}',
    );
    if (picked == null || !mounted) return;
    final value =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() {
      _days[index] = opening
          ? day.copyWith(opensAt: value)
          : day.copyWith(closesAt: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Horario de atención')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(_loadError!, textAlign: TextAlign.center),
                      TextButton(
                          onPressed: _load, child: const Text('Reintentar')),
                    ]),
                  ),
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (!_configured)
                          Container(
                            key: const Key('business-hours-proposal'),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.warningLight,
                              border:
                                  Border.all(color: AppColors.warningBorder),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Todavía no guardaste tu horario, así que ninguna cita se restringe. '
                              'Te proponemos lunes a viernes de 09:00 a 18:00.',
                              style: TextStyle(color: AppColors.warning),
                            ),
                          ),
                        const Text(
                          'Las citas nuevas o reprogramadas deben caer dentro de este horario. '
                          'Las citas ya agendadas no cambian.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                        const SizedBox(height: 12),
                        for (var i = 0; i < _days.length; i++) _dayCard(i),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          key: const Key('business-hours-save'),
                          onPressed: _allValid && !_saving ? _save : null,
                          icon: _saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.save_outlined),
                          label:
                              Text(_saving ? 'Guardando…' : 'Guardar horario'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _dayCard(int index) {
    final day = _days[index];
    final times = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton.icon(
          key: Key('opens-${day.dayOfWeek}'),
          onPressed: () => _pickTime(index, opening: true),
          icon: const Icon(Icons.schedule, size: 18),
          label: Text('Abre ${day.opensAt ?? '--:--'}'),
        ),
        OutlinedButton.icon(
          key: Key('closes-${day.dayOfWeek}'),
          onPressed: () => _pickTime(index, opening: false),
          icon: const Icon(Icons.schedule_outlined, size: 18),
          label: Text('Cierra ${day.closesAt ?? '--:--'}'),
        ),
      ],
    );

    return Card(
      color: AppColors.surface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(day.label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: AppColors.ink)),
              ),
              Text(day.open ? 'Atiende' : 'Cerrado',
                  style: TextStyle(
                      color: day.open ? AppColors.success : AppColors.muted)),
              Switch(
                key: Key('open-${day.dayOfWeek}'),
                value: day.open,
                onChanged: (value) =>
                    setState(() => _days[index] = day.copyWith(open: value)),
              ),
            ]),
            if (day.open) times,
            if (!day.isValid)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('La apertura debe ser antes del cierre.',
                    style: TextStyle(color: AppColors.danger, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}
