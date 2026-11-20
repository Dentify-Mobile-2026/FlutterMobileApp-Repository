import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/payment/data/model/payment_method_response.dart';
import 'package:dentify_flutter/payment/data/remote/services/payment_http_support.dart';
import 'package:http/http.dart' as http;

class PaymentMethodService {
  final String baseUrl;
  final http.Client? _client;

  PaymentMethodService(this.baseUrl, {http.Client? client}) : _client = client;

  Future<List<PaymentMethodResponse>> getAllPaymentMethods() async {
    final get = _client?.get ?? http.get;
    final response = await get(
      ApiConstants.endpoint(baseUrl, 'v1/payment-methods'),
      headers: await paymentRequestHeaders(),
    );

    if (response.statusCode == 404) return [];
    if (!isSuccessStatus(response.statusCode)) {
      throw paymentApiExceptionFrom(response);
    }
    return decodePaymentList(response)
        .map(PaymentMethodResponse.fromJson)
        .toList();
  }
}
