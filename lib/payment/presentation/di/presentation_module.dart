//import '../../domain/usecases/add_invoice_use_case.dart';
//import '../../domain/usecases/get_all_invoices_use_case.dart';
import '../../presentation/viewmodel/invoice_form_view_model.dart';
import '../../presentation/viewmodel/invoice_view_model.dart';
import '../../data/di/data_module.dart';

class PresentationModule {
  static InvoiceViewModel getInvoicesViewModel() {
    return InvoiceViewModel(DataModule.getAllInvoicesUseCase());
  }

  static InvoiceFormViewModel getInvoiceFormViewModel() {
    return InvoiceFormViewModel(
      DataModule.addInvoiceUseCase(),
      DataModule.getAllAppointmentsFormInfoUseCase(),
    );
  }
}
