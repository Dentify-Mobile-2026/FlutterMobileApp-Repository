import 'package:flutter/material.dart';
import '../../domain/model/invoice.dart';
import '../../domain/usecases/get_all_invoices_use_case.dart';

class InvoiceViewModel extends ChangeNotifier {
  final GetAllInvoicesUseCase getAllInvoicesUseCase;

  List<Invoice> _invoices = [];
  List<Invoice> get invoices => _invoices;

  InvoiceViewModel(this.getAllInvoicesUseCase);

  Future<void> getAllInvoices() async {
    try {
      _invoices = await getAllInvoicesUseCase.call();
      notifyListeners(); // Notificar a la UI que el estado ha cambiado
    } catch (e) {
      print("Error al obtener las facturas: ${e.toString()}");
    }
  }
}
