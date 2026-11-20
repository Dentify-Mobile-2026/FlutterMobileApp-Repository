import 'dart:convert';

import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/payment/data/model/invoice_payment_response.dart';
import 'package:dentify_flutter/payment/data/model/invoice_response.dart';
import 'package:dentify_flutter/payment/data/remote/dto/create_invoice_request.dart';
import 'package:dentify_flutter/payment/data/remote/dto/register_payment_request.dart';
import 'package:dentify_flutter/payment/data/remote/services/payment_http_support.dart';
import 'package:http/http.dart' as http;

class InvoiceService {
  final String baseUrl;
  final http.Client? _client;

  InvoiceService(this.baseUrl, {http.Client? client}) : _client = client;

  /// Mensajes de los endpoints de abonos cuando el servidor no envía `error`.
  static const Map<int, String> _paymentFallbackMessages = {
    400: 'El monto del abono no es válido.',
    404: 'El comprobante no existe.',
    409: 'No se pudo registrar el abono porque el saldo del comprobante cambió. '
        'Revise el saldo e intente nuevamente.',
  };

  Future<List<InvoiceResponse>> getAllInvoices() async {
    final get = _client?.get ?? http.get;
    final response = await get(
      ApiConstants.endpoint(baseUrl, 'v1/invoices'),
      headers: await paymentRequestHeaders(),
    );

    if (response.statusCode == 404) return [];
    if (!isSuccessStatus(response.statusCode)) {
      throw paymentApiExceptionFrom(response);
    }
    return decodePaymentList(response).map(InvoiceResponse.fromJson).toList();
  }

  Future<void> createInvoice(CreateInvoiceRequest request) async {
    final post = _client?.post ?? http.post;
    final response = await post(
      ApiConstants.endpoint(baseUrl, 'v1/invoices'),
      headers: await paymentRequestHeaders(),
      body: json.encode(request.toJson()),
    );

    if (!isSuccessStatus(response.statusCode)) {
      throw paymentApiExceptionFrom(response);
    }
  }

  /// Abonos de un comprobante. A diferencia de los listados generales, un 404
  /// es un error: el comprobante no existe.
  Future<List<InvoicePaymentResponse>> getInvoicePayments(int invoiceId) async {
    final get = _client?.get ?? http.get;
    final response = await get(
      ApiConstants.endpoint(baseUrl, 'v1/invoices/$invoiceId/payments'),
      headers: await paymentRequestHeaders(),
    );

    if (!isSuccessStatus(response.statusCode)) {
      throw paymentApiExceptionFrom(
        response,
        fallbackMessages: _paymentFallbackMessages,
      );
    }
    return decodePaymentList(response)
        .map(InvoicePaymentResponse.fromJson)
        .toList();
  }

  /// Registra un abono y devuelve el comprobante actualizado. Tanto 201 (abono
  /// creado) como 200 (reintento idempotente con el mismo `requestId`) son
  /// éxito y traen el comprobante vigente.
  Future<InvoiceResponse> registerPayment(
    int invoiceId,
    RegisterPaymentRequest request,
  ) async {
    final post = _client?.post ?? http.post;
    final response = await post(
      ApiConstants.endpoint(baseUrl, 'v1/invoices/$invoiceId/payments'),
      headers: await paymentRequestHeaders(),
      body: json.encode(request.toJson()),
    );

    if (!isSuccessStatus(response.statusCode)) {
      throw paymentApiExceptionFrom(
        response,
        fallbackMessages: _paymentFallbackMessages,
      );
    }
    final body = decodePaymentBody(response);
    if (body is! Map) {
      throw const FormatException('Respuesta inesperada del servidor');
    }
    return InvoiceResponse.fromJson(Map<String, dynamic>.from(body));
  }
}
