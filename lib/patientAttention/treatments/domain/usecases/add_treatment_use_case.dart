import 'package:dentify_flutter/patientAttention/treatments/data/remote/dto/treatment_request.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/repositories/treatment_repository.dart';

class AddTreatmentUseCase {
  final TreatmentRepository repository;

  AddTreatmentUseCase(this.repository);

  Future<void> call(TreatmentRequest request) {
    return repository.addTreatment(request);
  }
}
