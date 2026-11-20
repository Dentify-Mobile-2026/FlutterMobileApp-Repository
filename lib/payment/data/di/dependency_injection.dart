import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/payment/data/remote/services/payment_method_service.dart';
import 'package:dentify_flutter/payment/data/repository/payment_method_repository_impl.dart';
import 'package:dentify_flutter/payment/domain/repository/payment_method_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentMethodServiceProvider = Provider<PaymentMethodService>((ref) {
  return PaymentMethodService(ApiConstants.baseUrl);
});

final paymentMethodRepositoryProvider = Provider<PaymentMethodRepository>((ref) {
  return PaymentMethodRepositoryImpl(ref.read(paymentMethodServiceProvider));
});
