import 'package:dentify_flutter/patientAttention/patients/presentation/view/patients_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Map<String, WidgetBuilder> patientsRoutes(WidgetRef ref) {
  return {
    '/patients': (context) => PatientsView()
  };
}