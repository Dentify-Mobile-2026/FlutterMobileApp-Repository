import 'package:dio/dio.dart';
//import 'package:retrofit/retrofit.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/remote/services/invoice_service.dart';
import '../../data/repository/invoice_repository_impl.dart';
import '../../domain/usecases/add_invoice_use_case.dart';
import '../../domain/usecases/get_all_invoices_use_case.dart';
import '../../../iam/data/storage/token_storage.dart';
import '../../../patientAttention/appointments/domain/usecases/get_all_appointments_form_info_use_case.dart';
import '../../../patientAttention/appointments/data/di/appointments_module.dart';

class DataModule {
  static final Dio _dio = Dio();

  // Configurar el cliente Retrofit
  static Dio getRetrofit() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
    return _dio;
  }

  // Servicio de facturas
  static InvoiceService getInvoiceService() {
    return InvoiceService(getRetrofit());
  }

  // Repositorio de facturas
  static InvoiceRepositoryImpl getInvoiceRepository() {
    return InvoiceRepositoryImpl(getInvoiceService());
  }

  // Casos de uso
  static GetAllInvoicesUseCase getAllInvoicesUseCase() {
    return GetAllInvoicesUseCase(getInvoiceRepository());
  }

  static AddInvoiceUseCase addInvoiceUseCase() {
    return AddInvoiceUseCase(getInvoiceRepository());
  }

  static GetAllAppointmentsFormInfoUseCase getAllAppointmentsFormInfoUseCase() {
    return GetAllAppointmentsFormInfoUseCase(
      AppointmentsModule.provideAppointmentRepository(),
    );
  }
}