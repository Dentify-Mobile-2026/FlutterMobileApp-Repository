import 'package:dentify_flutter/payment/domain/model/payment_method.dart';

abstract class PaymentMethodRepository {
  Future<List<PaymentMethod>> getAll();
}
