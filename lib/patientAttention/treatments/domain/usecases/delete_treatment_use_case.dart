import 'package:dentify_flutter/patientAttention/treatments/domain/repositories/treatment_repository.dart';

class DeleteTreatmentUseCase {
  final TreatmentRepository repository;

  DeleteTreatmentUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deleteTreatment(id);
  }
}
