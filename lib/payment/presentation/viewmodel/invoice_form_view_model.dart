import 'package:flutter/material.dart';
import '../../domain/model/appointment_data_form.dart';
import '../../domain/usecases/add_invoice_use_case.dart';
//import '../../domain/usecases/get_all_invoices_use_case.dart';
import '../../data/remote/dto/add_invoice_request.dart';
import '../../../patientAttention/appointments/domain/usecases/get_all_appointments_form_info_use_case.dart';

class InvoiceFormViewModel extends ChangeNotifier {
  final AddInvoiceUseCase addInvoiceUseCase;
  final GetAllAppointmentsFormInfoUseCase getAllAppointmentsFormInfoUseCase;

  List<AppointmentDataForm> appointments = [];

  InvoiceFormViewModel(this.addInvoiceUseCase, this.getAllAppointmentsFormInfoUseCase);

  Future<void> addInvoice(AddInvoiceRequest invoice) async {
    try {
      await addInvoiceUseCase.call(invoice);
      print("Factura enviada correctamente.");
    } catch (e) {
      print("Error al enviar la factura: ${e.toString()}");
    }
  }

  Future<void> loadAppointments() async {
    try {
      final appointmentList = await getAllAppointmentsFormInfoUseCase.call();

      appointments = appointmentList
          .map((appointment) => AppointmentDataForm.fromAppointment(appointment))
          .where((it) => !it.completed)
          .toList();

      notifyListeners();
    } catch (e) {
      print("Error al cargar las citas: ${e.toString()}");
    }
  }
}
