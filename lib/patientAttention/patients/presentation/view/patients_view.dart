import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/add_patient_request.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/di/presentation_module.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/widgets/patient_card.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/widgets/patient_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientsView extends ConsumerStatefulWidget {
  const PatientsView({super.key});

  @override
  ConsumerState<PatientsView> createState() => _PatientsViewState();
}

class _PatientsViewState extends ConsumerState<PatientsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(patientsViewModelProvider.notifier).getAllPatients();
    });
  }

  @override
  Widget build(BuildContext context) {
    final allPatients = ref.watch(patientsViewModelProvider);
    final patients = ref.watch(filteredPatientsProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final onlyAlerts = ref.watch(patientOnlyAlertsFilterProvider);
    final alertCount = allPatients.where((p) => p.hasMedicalAlerts).length;

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
                        'Pacientes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        '${allPatients.length} registrados · $alertCount con alerta médica',
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Actualizar lista',
                  onPressed: () => ref
                      .read(patientsViewModelProvider.notifier)
                      .getAllPatients(),
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
                  onPressed: () => _onAddPatient(context),
                  icon: const Icon(Icons.person_add_alt_1, size: 17),
                  label: const Text('Nuevo', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      ref.read(patientSearchQueryProvider.notifier).state =
                          value;
                    },
                    style: const TextStyle(fontSize: 13.5),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surface,
                      prefixIcon: const Icon(Icons.search, size: 19),
                      hintText: 'Buscar por nombre, DNI, teléfono o alergia...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    'Alertas ($alertCount)',
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  selected: onlyAlerts,
                  selectedColor: AppColors.dangerLight,
                  checkmarkColor: AppColors.danger,
                  avatar: Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: onlyAlerts ? AppColors.danger : AppColors.muted,
                  ),
                  onSelected: (v) {
                    ref.read(patientOnlyAlertsFilterProvider.notifier).state =
                        v;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : patients.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_search_outlined,
                                size: 44, color: AppColors.muted),
                            const SizedBox(height: 10),
                            Text(
                              allPatients.isEmpty
                                  ? 'Aún no hay pacientes registrados.'
                                  : 'No se encontraron pacientes con ese filtro.',
                              style: const TextStyle(
                                  fontSize: 14, color: AppColors.muted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: patients.length,
                        itemBuilder: (context, index) {
                          return PatientCard(patient: patients[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _onAddPatient(BuildContext context) async {
    final newPatient = await showDialog<AddPatientRequest>(
      context: context,
      builder: (context) => const PatientForm(),
    );
    if (newPatient != null) {
      await ref.read(patientsViewModelProvider.notifier).addPatient(newPatient);
      final vm = ref.read(patientsViewModelProvider.notifier);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.errorMessage ?? 'Paciente registrado correctamente'),
            backgroundColor:
                vm.errorMessage != null ? AppColors.danger : AppColors.success,
          ),
        );
      }
    }
  }
}
