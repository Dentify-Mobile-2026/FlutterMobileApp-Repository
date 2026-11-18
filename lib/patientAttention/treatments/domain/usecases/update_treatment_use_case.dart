import 'package:dentify_flutter/patientAttention/treatments/data/remote/dto/treatment_request.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/repositories/treatment_repository.dart';

class UpdateTreatmentUseCase {
  final TreatmentRepository repository;

  UpdateTreatmentUseCase(this.repository);

  Future<void> call(int id, TreatmentRequest request) {
    return repository.updateTreatment(id, request);
  }
}
