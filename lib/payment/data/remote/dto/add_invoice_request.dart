class AddInvoiceRequest {
  final int amount;
  final int appointmentId;
  final int paymentMethodId;

  AddInvoiceRequest({
    required this.amount,
    required this.appointmentId,
    required this.paymentMethodId,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'appointmentId': appointmentId,
      'paymentMethodId': paymentMethodId,
    };
  }
}
