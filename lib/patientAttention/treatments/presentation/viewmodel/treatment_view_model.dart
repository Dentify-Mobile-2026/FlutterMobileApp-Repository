import 'package:dentify_flutter/patientAttention/treatments/data/remote/dto/treatment_request.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/model/treatment.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/usecases/add_treatment_use_case.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/usecases/delete_treatment_use_case.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/usecases/get_all_treatments_use_case.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/usecases/update_treatment_use_case.dart';
import 'package:dentify_flutter/patientAttention/treatments/presentation/di/presentation_module.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TreatmentViewModel extends StateNotifier<List<Treatment>> {
  final GetAllTreatmentsUseCase getAllTreatmentsUseCase;
  final AddTreatmentUseCase addTreatmentUseCase;
  final UpdateTreatmentUseCase updateTreatmentUseCase;
  final DeleteTreatmentUseCase deleteTreatmentUseCase;
  final Ref ref;
  String? errorMessage;

  TreatmentViewModel(
    this.getAllTreatmentsUseCase,
    this.addTreatmentUseCase,
    this.updateTreatmentUseCase,
    this.deleteTreatmentUseCase,
    this.ref,
  ) : super([]) {
    Future.microtask(getAllTreatments);
  }

  Future<void> getAllTreatments() async {
    try {
      errorMessage = null;
      ref.read(treatmentLoadingProvider.notifier).state = true;
      final list = await getAllTreatmentsUseCase();
      state = list;
    } catch (e) {
      errorMessage = e.toString();
      state = [];
    } finally {
      ref.read(treatmentLoadingProvider.notifier).state = false;
    }
  }

  Future<void> addTreatment(TreatmentRequest request) async {
    try {
      errorMessage = null;
      await addTreatmentUseCase(request);
      await getAllTreatments();
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  Future<void> updateTreatment(int id, TreatmentRequest request) async {
    try {
      errorMessage = null;
      await updateTreatmentUseCase(id, request);
      await getAllTreatments();
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  Future<void> deleteTreatment(int id) async {
    try {
      errorMessage = null;
      await deleteTreatmentUseCase(id);
      await getAllTreatments();
    } catch (e) {
      errorMessage = e.toString();
    }
  }
}
