import 'package:dentify_flutter/payment/data/remote/services/payment_method_service.dart';
import 'package:dentify_flutter/payment/domain/model/payment_method.dart';
import 'package:dentify_flutter/payment/domain/repository/payment_method_repository.dart';

class PaymentMethodRepositoryImpl implements PaymentMethodRepository {
  final PaymentMethodService paymentMethodService;

  PaymentMethodRepositoryImpl(this.paymentMethodService);

  @override
  Future<List<PaymentMethod>> getAll() async {
    final responses = await paymentMethodService.getAllPaymentMethods();
    // Sin id válido no se puede registrar el cobro: se descartan.
    return responses
        .where((r) => r.id > 0)
        .map((r) => r.toDomain())
        .toList();
  }
}
