import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/iam/data/remote/dto/update_password_request.dart';
import 'package:dentify_flutter/iam/presentation/di/presentation_module.dart';
import 'package:dentify_flutter/iam/presentation/viewmodel/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdatePasswordView extends ConsumerStatefulWidget {
  final ProfileViewModel viewModel;

  const UpdatePasswordView({super.key, required this.viewModel});

  @override
  ConsumerState<UpdatePasswordView> createState() => _UpdatePasswordViewState();
}

class _UpdatePasswordViewState extends ConsumerState<UpdatePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _currentPass = TextEditingController();
  final _newPass = TextEditingController();
  final _confirmPass = TextEditingController();

  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(profileViewModelProvider.notifier).clearError();
      }
    });
  }

  @override
  void dispose() {
    _currentPass.dispose();
    _newPass.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(profileViewModelProvider.notifier);
    await notifier.updatePassword(
      UpdatePasswordRequest(
        oldPassword: _currentPass.text,
        newPassword: _newPass.text,
      ),
    );
    if (ref.read(profileViewModelProvider).errorMessage == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada correctamente')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cambiar contraseña'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.mint,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.lock_reset_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Seguridad de la cuenta',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Ingresa tu contraseña actual y define una nueva de al menos 6 caracteres',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildPasswordField(
                        controller: _currentPass,
                        label: 'Contraseña actual *',
                        obscure: _hideCurrent,
                        onToggle: () =>
                            setState(() => _hideCurrent = !_hideCurrent),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Ingresa tu contraseña actual'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        controller: _newPass,
                        label: 'Nueva contraseña *',
                        obscure: _hideNew,
                        onToggle: () => setState(() => _hideNew = !_hideNew),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Ingresa una nueva contraseña';
                          }
                          if (v.length < 6) {
                            return 'Debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        controller: _confirmPass,
                        label: 'Confirmar nueva contraseña *',
                        obscure: _hideConfirm,
                        onToggle: () =>
                            setState(() => _hideConfirm = !_hideConfirm),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Confirma tu nueva contraseña';
                          }
                          if (v != _newPass.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.dangerLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.dangerBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 18,
                                color: AppColors.danger,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.errorMessage!,
                                  style: const TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: state.isLoading
                                ? null
                                : () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: state.isLoading ? null : _submit,
                            icon: state.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.check_outlined, size: 18),
                            label: const Text('Actualizar contraseña'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
