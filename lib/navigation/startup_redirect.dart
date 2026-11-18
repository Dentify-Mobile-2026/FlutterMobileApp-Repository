import 'package:dentify_flutter/iam/data/storage/token_storage.dart';
import 'package:flutter/material.dart';

class StartupRedirect extends StatefulWidget {
  const StartupRedirect({super.key});

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
    final hasToken = await TokenStorage.hasValidToken();

    if (!mounted) return;

    if (hasToken) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

