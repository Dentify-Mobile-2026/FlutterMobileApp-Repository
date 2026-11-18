import 'package:flutter/material.dart';
import '../../domain/model/appointment_data_form.dart';
import '../../data/remote/dto/add_invoice_request.dart';
import '../../presentation/viewmodel/invoice_form_view_model.dart';


class AddInvoiceFormView extends StatelessWidget {
  final InvoiceFormViewModel viewModel;
  final VoidCallback toInvoices;
  final VoidCallback toBack;
  final VoidCallback onInvoicesSaved;

  AddInvoiceFormView({
    required this.viewModel,
    required this.toInvoices,
    required this.toBack,
    required this.onInvoicesSaved,
  });

  @override
  Widget build(BuildContext context) {
    final amountController = TextEditingController();
    final appointmentId = ValueNotifier<int>(0);
    final paymentMethodId = ValueNotifier<int>(0);
    final showSuccessDialog = ValueNotifier<bool>(false);

    viewModel.loadAppointments();

    return Scaffold(
      backgroundColor: const Color(0xFFF5FFFD),
      appBar: AppBar(
        title: const Text('Add a New Invoice'),
        backgroundColor: const Color(0xFF2C3E50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: const Color(0xFFFFFFFF),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.description, color: Color(0xFF2C3E50)),
                        SizedBox(width: 8),
                        Text(
                          'Add a new Invoice',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration("Amount (S/.)"),
                    ),
                    const SizedBox(height: 16),
                    AppointmentDropdown(
                      label: 'Select Appointment',
                      appointments: viewModel.appointments,
                      selectedAppointmentId: appointmentId.value,
                      onAppointmentSelected: (id) {
                        appointmentId.value = id;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Payment Method",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<int>(
                      valueListenable: paymentMethodId,
                      builder: (context, value, _) {
                        return Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => paymentMethodId.value = 1,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: value == 1 ? const Color(0xFF10B981) : Colors.grey[300],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text("Credit Card"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => paymentMethodId.value = 2,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: value == 2 ? const Color(0xFF10B981) : Colors.grey[300],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text("Cash"),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: toBack,
                      child: Center(
                        child: Text(
                          '← Go back to invoice general view',
                          style: const TextStyle(
                            color: Color(0xFF2C3E50),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                final invoice = AddInvoiceRequest(
                  amount: int.parse(amountController.text),
                  appointmentId: appointmentId.value,
                  paymentMethodId: paymentMethodId.value,
                );
                viewModel.addInvoice(invoice);
                showSuccessDialog.value = true;
                onInvoicesSaved();
              },
              icon: const Icon(Icons.save),
              label: const Text("Save Invoice"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C3E50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: ValueListenableBuilder<bool>(
        valueListenable: showSuccessDialog,
        builder: (context, showDialog, _) {
          if (showDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Invoice registered successfully!"),
              actions: [
                TextButton(
                  onPressed: () {
                    showSuccessDialog.value = false;
                    onInvoicesSaved();
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2C3E50)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2C3E50), width: 1.5),
      ),
    );
  }
}

class AppointmentDropdown extends StatelessWidget {
  final String label;
  final List<AppointmentDataForm> appointments;
  final int selectedAppointmentId;
  final Function(int) onAppointmentSelected;

  const AppointmentDropdown({
    required this.label,
    required this.appointments,
    required this.selectedAppointmentId,
    required this.onAppointmentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: selectedAppointmentId != 0 ? selectedAppointmentId : null,
      items: appointments.map((appointment) {
        return DropdownMenuItem<int>(
          value: appointment.id,
          child: Text('${appointment.patientName} - ${appointment.reason}'),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) onAppointmentSelected(value);
      },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        hintText: appointments.isEmpty ? 'No pending appointments' : 'Select an appointment',
      ),
    );
  }
}