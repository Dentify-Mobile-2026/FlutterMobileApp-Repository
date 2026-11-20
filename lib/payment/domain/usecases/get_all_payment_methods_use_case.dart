import 'package:dentify_flutter/payment/domain/model/payment_method.dart';
import 'package:dentify_flutter/payment/domain/repository/payment_method_repository.dart';

class GetAllPaymentMethodsUseCase {
  final PaymentMethodRepository repository;

  GetAllPaymentMethodsUseCase(this.repository);

  Future<List<PaymentMethod>> call() {
    return repository.getAll();
  }
}
