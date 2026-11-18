class Invoice {
  final int id;
  final int appointmentId;
  final String patientName;
  final String dni;
  final String email;
  final int amount;
  final String createdAt;

  Invoice({
    required this.id,
    required this.appointmentId,
    required this.patientName,
    required this.dni,
    required this.email,
    required this.amount,
    required this.createdAt,
  });

  // Convertir de JSON
  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      appointmentId: json['appointmentId'],
      patientName: json['patientName'],
      dni: json['dni'],
      email: json['email'],
      amount: json['amount'],
      createdAt: json['createdAt'],
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'patientName': patientName,
      'dni': dni,
      'email': email,
      'amount': amount,
      'createdAt': createdAt,
    };
  }
}
