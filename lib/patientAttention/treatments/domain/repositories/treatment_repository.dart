import 'package:dentify_flutter/patientAttention/treatments/data/remote/dto/treatment_request.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/model/treatment.dart';

abstract class TreatmentRepository {
  Future<List<Treatment>> getAllTreatments();
  Future<void> addTreatment(TreatmentRequest request);
  Future<void> updateTreatment(int id, TreatmentRequest request);
  Future<void> deleteTreatment(int id);
}
