import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/iam/data/remote/services/session_validator.dart';
import 'package:dentify_flutter/iam/data/storage/token_storage.dart';
import 'package:flutter/material.dart';

class StartupRedirect extends StatefulWidget {
  /// Se puede inyectar en pruebas; por defecto valida contra el servicio configurado.
  final SessionValidator? validator;

  const StartupRedirect({super.key, this.validator});

  @override
  State<StartupRedirect> createState() => _StartupRedirectState();
}

class _StartupRedirectState extends State<StartupRedirect> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndRedirect();
  }

  Future<void> _checkAuthAndRedirect() async {
    final token = await TokenStorage.getAccessToken();
    var goHome = false;

    if (token != null && token.isNotEmpty) {
      // Un token guardado puede haber vencido o pertenecer a otra base: se valida antes de entrar.
      final validator = widget.validator ?? SessionValidator(ApiConstants.baseUrl);
      goHome = await validator.check(token) != SessionStatus.invalid;
      if (!goHome) await TokenStorage.clearTokens();
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, goHome ? '/home' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
