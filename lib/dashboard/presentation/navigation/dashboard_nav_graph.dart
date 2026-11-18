import 'package:dentify_flutter/dashboard/presentation/view/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


Map<String, WidgetBuilder> dashboardRoutes(WidgetRef ref) {
  return {
    '/dashboard': (context) => const DashboardScreen(),
  };
}