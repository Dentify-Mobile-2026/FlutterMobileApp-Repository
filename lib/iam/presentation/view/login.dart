import 'package:flutter/material.dart';
import '../viewmodel/login_view_model.dart';

class LoginPage extends StatefulWidget {
  final LoginViewModel viewModel;
  final VoidCallback onLogin;
  final VoidCallback toRegister;

  const LoginPage({
    super.key,
    required this.viewModel,
    required this.onLogin,
    required this.toRegister,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5FFFD),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/ic_launcher-playstore.png',
                height: 120,
              ),
              const SizedBox(height: 32),

              // Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                color: const Color(0xFFD1F2EB),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Welcome Back',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Username
                      TextField(
                        onChanged: (value) => widget.viewModel.username = value,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextField(
                        obscureText: true,
                        onChanged: (value) => widget.viewModel.password = value,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Error
                      if (widget.viewModel.errorMessage != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.viewModel.errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFD32F2F),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed:
                              _isLoading
                                  ? null
                                  : () async {
                                    setState(() => _isLoading = true);
                                    await widget.viewModel.login();
                                    if (!mounted) return;
                                    setState(() => _isLoading = false);
                                    if (widget.viewModel.isAuthenticated) {
                                      widget.onLogin();
                                    }
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0288D1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Register link
                      GestureDetector(
                        onTap: widget.toRegister,
                        child: Text(
                          '¿No tienes cuenta? Regístrate aquí',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
