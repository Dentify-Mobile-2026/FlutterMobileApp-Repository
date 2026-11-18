import 'package:flutter/material.dart';
import '../viewmodel/register_view_model.dart';

class RegisterPage extends StatelessWidget {
  final RegisterViewModel viewModel;
  final VoidCallback onRegister;
  final VoidCallback toLogin;

  const RegisterPage({super.key, required this.viewModel, required this.onRegister, required this.toLogin});

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
              Image.asset(
                'assets/images/ic_launcher-playstore.png',
                height: 100,
              ),
              const SizedBox(height: 24),

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
                        'Create Account',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        label: 'First Name',
                        onChanged: (value) => viewModel.firstName = value,
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        label: 'Last Name',
                        onChanged: (value) => viewModel.lastName = value,
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        label: 'Email',
                        onChanged: (value) => viewModel.email = value,
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        label: 'Company Name',
                        onChanged: (value) => viewModel.companyName = value,
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        label: 'Username',
                        onChanged: (value) => viewModel.username = value,
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        label: 'Password',
                        obscure: true,
                        onChanged: (value) => viewModel.password = value,
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Checkbox(
                            value: viewModel.trial,
                            onChanged: (value) => viewModel.trial = value!,
                          ),
                          const Text('Start with trial'),
                        ],
                      ),

                      if (viewModel.errorMessage != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            viewModel.errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFD32F2F),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            viewModel.register();
                            if (viewModel.isAuthenticated) {
                              onRegister();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0288D1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: toLogin,
                        child: Text(
                          '¿Ya tienes una cuenta? Inicia sesión aquí',
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

  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    bool obscure = false,
  }) {
    return TextField(
      onChanged: onChanged,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
