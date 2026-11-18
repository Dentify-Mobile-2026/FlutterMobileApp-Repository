import 'package:dentify_flutter/patientAttention/treatments/data/remote/dto/treatment_request.dart';
import 'package:dentify_flutter/patientAttention/treatments/data/remote/services/treatment_service.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/model/treatment.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/repositories/treatment_repository.dart';

class TreatmentRepositoryImpl implements TreatmentRepository {
  final TreatmentService service;

  TreatmentRepositoryImpl(this.service);

  @override
  Future<List<Treatment>> getAllTreatments() async {
    final responses = await service.getAllTreatments();
    return responses.map((r) => r.toDomain()).toList();
  }

  @override
  Future<void> addTreatment(TreatmentRequest request) async {
    await service.createTreatment(request);
  }

  @override
  Future<void> updateTreatment(int id, TreatmentRequest request) async {
    await service.updateTreatment(id, request);
  }

  @override
  Future<void> deleteTreatment(int id) async {
    await service.deleteTreatment(id);
  }
}
