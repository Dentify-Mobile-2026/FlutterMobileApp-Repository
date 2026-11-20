/// Error devuelto por la API de pagos (respuesta HTTP fuera del rango 2xx).
///
/// [message] contiene el texto del campo `error` del cuerpo cuando el servidor
/// lo envía, o un mensaje genérico en español en caso contrario.
class PaymentApiException implements Exception {
  final int statusCode;
  final String message;

  const PaymentApiException(this.statusCode, this.message);

  /// La cita ya tiene un comprobante registrado (HTTP 409).
  bool get isConflict => statusCode == 409;

  @override
  String toString() => message;
}
