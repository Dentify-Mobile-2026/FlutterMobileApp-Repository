import 'package:dentify_flutter/dashboard/presentation/view/dashboard_screen.dart';
import 'package:dentify_flutter/iam/presentation/di/presentation_module.dart';
import 'package:dentify_flutter/iam/presentation/view/login.dart';
import 'package:dentify_flutter/iam/presentation/view/register.dart';
import 'package:dentify_flutter/inventory/presentation/view/items_view.dart';
import 'package:dentify_flutter/navigation/startup_redirect.dart';
import 'package:dentify_flutter/patientAttention/appointments/presentation/view/appointments_view.dart';
import 'package:dentify_flutter/payment/presentation/navigation/navigation.dart'; // Importa paymentRoutes
import 'package:dentify_flutter/patientAttention/patients/presentation/view/patients_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'drawer_wrapper.dart'; // Importa DrawerWrapper
import '../profile_screen.dart';

class DentifyApp extends ConsumerWidget {
  const DentifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginViewModel = ref.read(loginViewModelProvider);
    final registerViewModel = ref.read(registerViewModelProvider);
    final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();


    return MaterialApp(
      title: 'Dentify App',
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false, // Desactiva el banner de debug
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const StartupRedirect(),
        '/login':
            (context) => LoginPage(
              viewModel: loginViewModel,
              onLogin: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              toRegister: () {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil("/register", (route) => false);
              },
            ),
        '/register':
            (context) => RegisterPage(
              viewModel: registerViewModel,
              onRegister: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              toLogin: () {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil("/login", (route) => false);
              },
            ),
        '/appointments':
            (context) => DrawerWrapper(content: AppointmentsView()),
        '/profile': (context) => DrawerWrapper(content: ProfileScreen()),
        '/patients': (context) => DrawerWrapper(content: PatientsView()),
        '/home': (context) => const DrawerWrapper(content: DashboardScreen()),
        ...paymentRoutes(ref),
        '/inventory': (context) => DrawerWrapper(content: ItemsView()),
      },
    );
  }
}
