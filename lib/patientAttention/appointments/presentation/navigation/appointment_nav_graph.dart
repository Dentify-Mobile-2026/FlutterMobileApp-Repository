import 'package:dentify_flutter/patientAttention/appointments/presentation/view/appointments_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Map<String, WidgetBuilder> appointmentRoutes(WidgetRef ref) {
  return {
    '/appointments': (context) => AppointmentsView()
  };
}