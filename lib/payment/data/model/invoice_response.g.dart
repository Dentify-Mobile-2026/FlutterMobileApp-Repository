// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvoiceResponse _$InvoiceResponseFromJson(Map<String, dynamic> json) =>
    InvoiceResponse(
      id: (json['id'] as num).toInt(),
      appointmentId: (json['appointmentId'] as num).toInt(),
      patientName: json['patientName'] as String,
      dni: json['dni'] as String,
      email: json['email'] as String,
      amount: (json['amount'] as num).toInt(),
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$InvoiceResponseToJson(InvoiceResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'appointmentId': instance.appointmentId,
      'patientName': instance.patientName,
      'dni': instance.dni,
      'email': instance.email,
      'amount': instance.amount,
      'createdAt': instance.createdAt,
    };
