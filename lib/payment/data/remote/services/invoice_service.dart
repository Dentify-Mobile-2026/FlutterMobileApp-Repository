import 'dart:convert';

import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/payment/data/model/invoice_response.dart';
import 'package:dentify_flutter/payment/data/remote/dto/create_invoice_request.dart';
import 'package:dentify_flutter/payment/data/remote/services/payment_http_support.dart';
import 'package:http/http.dart' as http;

class InvoiceService {
  final String baseUrl;
  final http.Client? _client;

  InvoiceService(this.baseUrl, {http.Client? client}) : _client = client;

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
}
