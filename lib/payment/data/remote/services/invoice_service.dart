import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../model/invoice_response.dart';
import '../../remote/dto/add_invoice_request.dart';
import '../../../../core/network/api_constants.dart';
part 'invoice_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class InvoiceService {
  factory InvoiceService(Dio dio, {String baseUrl}) = _InvoiceService;

  @GET("v1/invoices")
  Future<List<InvoiceResponse>> getAllInvoices();

  @POST("v1/invoices")
  Future<void> addInvoice(@Body() AddInvoiceRequest invoice);
}
