import 'package:dentify_flutter/iam/presentation/widgets/auth_scaffold.dart';
import 'package:flutter/material.dart';
import '../viewmodel/register_view_model.dart';

class RegisterPage extends StatefulWidget {
  final RegisterViewModel viewModel;
  final VoidCallback onRegister;
  final VoidCallback toLogin;

  const RegisterPage({super.key, required this.viewModel, required this.onRegister, required this.toLogin});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  bool _hidePassword = true;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    await widget.viewModel.register();
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (widget.viewModel.isAuthenticated) {
      widget.onRegister();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final error = vm.errorMessage;
    return AuthScaffold(
      title: 'Create your account',
      subtitle: 'Start organizing appointments, patients and payments',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: TextField(onChanged: (v) => vm.firstName = v, decoration: const InputDecoration(labelText: 'First name'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(onChanged: (v) => vm.lastName = v, decoration: const InputDecoration(labelText: 'Last name'))),
            ],
          ),
          const SizedBox(height: 14),
          TextField(onChanged: (v) => vm.email = v, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline))),
          const SizedBox(height: 14),
          TextField(onChanged: (v) => vm.companyName = v, decoration: const InputDecoration(labelText: 'Practice name', prefixIcon: Icon(Icons.business_outlined))),
          const SizedBox(height: 14),
          TextField(onChanged: (v) => vm.username = v, decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: 14),
          TextField(
            obscureText: _hidePassword,
            onChanged: (v) => vm.password = v,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
              ),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: vm.trial,
            onChanged: (v) => setState(() => vm.trial = v),
            title: const Text('Start with a free trial'),
          ),
          if (error != null) AuthError(error),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                  : const Text('Create account'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: widget.toLogin, child: const Text('Already have an account? Sign in')),
        ],
      ),
    );
  }
}
