import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/add_patient_request.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/di/presentation_module.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/widgets/patient_card.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/widgets/patient_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientsView extends ConsumerWidget {
  const PatientsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPatients = ref.watch(patientsViewModelProvider);
    final patients = ref.watch(filteredPatientsProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final onlyAlerts = ref.watch(patientOnlyAlertsFilterProvider);
    final alertCount = allPatients.where((p) => p.hasMedicalAlerts).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        title: const Text(
          'Directorio de Pacientes',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar lista',
            onPressed: () =>
                ref.read(patientsViewModelProvider.notifier).getAllPatients(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Row(
              children: [
                _statBadge(
                  icon: Icons.people_alt_outlined,
                  label: 'Total',
                  value: '${allPatients.length}',
                  bgColor: AppColors.mint,
                  textColor: AppColors.primaryDark,
                ),
                const SizedBox(width: 10),
                _statBadge(
                  icon: Icons.warning_amber_rounded,
                  label: 'Con Alerta Médica',
                  value: '$alertCount',
                  bgColor: AppColors.dangerLight,
                  textColor: AppColors.danger,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      ref.read(patientSearchQueryProvider.notifier).state = value;
                    },
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Buscar por nombre, DNI, teléfono o alergia...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilterChip(
                  label: const Text('Solo Alertas'),
                  selected: onlyAlerts,
                  selectedColor: AppColors.dangerLight,
                  checkmarkColor: AppColors.danger,
                  avatar: Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: onlyAlerts ? AppColors.danger : AppColors.muted,
                  ),
                  onSelected: (v) {
                    ref.read(patientOnlyAlertsFilterProvider.notifier).state = v;
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : patients.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_search_outlined,
                                size: 54, color: AppColors.muted),
                            const SizedBox(height: 12),
                            Text(
                              allPatients.isEmpty
                                  ? 'Aún no hay pacientes registrados.'
                                  : 'No se encontraron pacientes con ese filtro.',
                              style: const TextStyle(
                                  fontSize: 16, color: AppColors.muted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                        itemCount: patients.length,
                        itemBuilder: (context, index) {
                          final patient = patients[index];
                          return PatientCard(patient: patient);
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
              final newPatient = await showDialog<AddPatientRequest>(
                context: context,
                builder: (context) => const PatientForm(),
              );
              if (newPatient != null) {
                await ref
                    .read(patientsViewModelProvider.notifier)
                    .addPatient(newPatient);
                final vm = ref.read(patientsViewModelProvider.notifier);
                if (context.mounted) {
                  if (vm.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${vm.errorMessage}'),
                        backgroundColor: AppColors.danger,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Paciente registrado correctamente'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                }
              }
            },
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Nuevo Paciente'),
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

  Widget _statBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color bgColor,
    required Color textColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 22),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
