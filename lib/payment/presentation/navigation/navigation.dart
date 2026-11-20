import 'package:dentify_flutter/navigation/drawer_wrapper.dart';
import 'package:dentify_flutter/payment/presentation/view/invoice_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rutas del módulo de pagos. El alta de cobros se abre como diálogo desde
/// [InvoiceView], por lo que no necesita ruta propia.
Map<String, WidgetBuilder> paymentRoutes(WidgetRef ref) {
  return {
    '/payments': (context) => const DrawerWrapper(content: InvoiceView()),
  };
}
