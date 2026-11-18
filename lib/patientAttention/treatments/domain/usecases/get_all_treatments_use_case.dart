import 'package:dentify_flutter/patientAttention/treatments/domain/model/treatment.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/repositories/treatment_repository.dart';

class GetAllTreatmentsUseCase {
  final TreatmentRepository repository;

  GetAllTreatmentsUseCase(this.repository);

  Future<List<Treatment>> call() {
    return repository.getAllTreatments();
  }
}
