import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di/presentation_module.dart';
import '../view/login.dart';
import '../view/register.dart';

// auth_routes.dart
Map<String, WidgetBuilder> authRoutes(WidgetRef ref) {
  final loginVM = ref.read(loginViewModelProvider);
  final registerVM = ref.read(registerViewModelProvider);
  return {
    '/login': (context) => LoginPage(
          viewModel: loginVM,
          onLogin: () {
            Navigator.pushReplacementNamed(context, '/home');
            
          },
          toRegister: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              "/register",
              (route) => false,
            );
          },
        ),
    '/register': (context) => RegisterPage(
          viewModel: registerVM,
          onRegister: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          toLogin: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              "/login",
              (route) => false,
            );
          },
        ),
  };
}

