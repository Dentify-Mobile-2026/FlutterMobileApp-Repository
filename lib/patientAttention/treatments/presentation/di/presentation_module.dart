import 'package:dentify_flutter/patientAttention/treatments/data/di/dependency_injection.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/model/treatment.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/usecases/add_treatment_use_case.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/usecases/delete_treatment_use_case.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/usecases/get_all_treatments_use_case.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/usecases/update_treatment_use_case.dart';
import 'package:dentify_flutter/patientAttention/treatments/presentation/viewmodel/treatment_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getAllTreatmentsUseCaseProvider = Provider<GetAllTreatmentsUseCase>((ref) {
  return GetAllTreatmentsUseCase(ref.read(treatmentRepositoryProvider));
});

final addTreatmentUseCaseProvider = Provider<AddTreatmentUseCase>((ref) {
  return AddTreatmentUseCase(ref.read(treatmentRepositoryProvider));
});

final updateTreatmentUseCaseProvider = Provider<UpdateTreatmentUseCase>((ref) {
  return UpdateTreatmentUseCase(ref.read(treatmentRepositoryProvider));
});

final deleteTreatmentUseCaseProvider = Provider<DeleteTreatmentUseCase>((ref) {
  return DeleteTreatmentUseCase(ref.read(treatmentRepositoryProvider));
});

final treatmentLoadingProvider = StateProvider<bool>((ref) => true);

final treatmentsViewModelProvider =
    StateNotifierProvider<TreatmentViewModel, List<Treatment>>((ref) {
  return TreatmentViewModel(
    ref.read(getAllTreatmentsUseCaseProvider),
    ref.read(addTreatmentUseCaseProvider),
    ref.read(updateTreatmentUseCaseProvider),
    ref.read(deleteTreatmentUseCaseProvider),
    ref,
  );
});

final treatmentSearchQueryProvider = StateProvider<String>((ref) => '');
final treatmentSelectedCategoryProvider = StateProvider<String?>((ref) => null);

final filteredTreatmentsProvider = Provider<List<Treatment>>((ref) {
  final treatments = ref.watch(treatmentsViewModelProvider);
  final query = ref.watch(treatmentSearchQueryProvider).toLowerCase().trim();
  final category = ref.watch(treatmentSelectedCategoryProvider);

  return treatments.where((t) {
    if (category != null && t.category != category) return false;
    if (query.isEmpty) return true;
    return t.name.toLowerCase().contains(query) ||
        t.description.toLowerCase().contains(query) ||
        t.categoryEnum.label.toLowerCase().contains(query);
  }).toList();
});
