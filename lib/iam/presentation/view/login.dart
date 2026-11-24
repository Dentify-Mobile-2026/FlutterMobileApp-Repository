import 'package:dentify_flutter/iam/presentation/widgets/auth_scaffold.dart';
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
  bool _hidePassword = true;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    await widget.viewModel.login();
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (widget.viewModel.isAuthenticated) {
      widget.onLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.viewModel.errorMessage;
    return AuthScaffold(
      title: 'Bienvenido de nuevo',
      subtitle: 'Gestiona tu consultorio dental en un solo lugar',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            onChanged: (value) => widget.viewModel.username = value,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Usuario',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            obscureText: _hidePassword,
            onChanged: (value) => widget.viewModel.password = value,
            onSubmitted: (_) => _isLoading ? null : _submit(),
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (error != null) AuthError(error),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                  : const Text('Iniciar sesión'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: widget.toRegister,
            child: const Text('¿No tienes cuenta? Regístrate'),
          ),
        ],
      ),
    );
  }
}
