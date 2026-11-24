import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/iam/data/remote/dto/update_infomation_request.dart';
import 'package:dentify_flutter/iam/presentation/di/presentation_module.dart';
import 'package:dentify_flutter/iam/presentation/viewmodel/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateInformationView extends ConsumerStatefulWidget {
  final ProfileViewModel viewModel;

  const UpdateInformationView({super.key, required this.viewModel});

  @override
  ConsumerState<UpdateInformationView> createState() =>
      _UpdateInformationViewState();
}

class _UpdateInformationViewState extends ConsumerState<UpdateInformationView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _companyController;

  @override
  void initState() {
    super.initState();
    final userInfo = ref.read(profileViewModelProvider).userInfo;
    final fullName = (userInfo?.fullName ?? '').trim();
    final spaceIdx = fullName.indexOf(' ');
    final firstName = spaceIdx == -1 ? fullName : fullName.substring(0, spaceIdx);
    final lastName =
        spaceIdx == -1 ? '' : fullName.substring(spaceIdx + 1).trim();

    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _emailController = TextEditingController(text: userInfo?.email ?? '');
    _companyController =
        TextEditingController(text: userInfo?.companyName ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(profileViewModelProvider.notifier).clearError();
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(profileViewModelProvider.notifier);
    await notifier.updateInformation(
      UpdateInformationRequest(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        companyName: _companyController.text.trim(),
      ),
    );
    if (ref.read(profileViewModelProvider).errorMessage == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Información actualizada correctamente')),
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
        title: const Text('Editar información'),
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
                              Icons.manage_accounts_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Datos del profesional',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Actualiza tus datos de contacto y consultorio',
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
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombres *',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Campo obligatorio'
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Apellidos *',
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Campo obligatorio'
                                      : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico *',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                        validator: (v) {
                          final value = (v ?? '').trim();
                          if (value.isEmpty) return 'Campo obligatorio';
                          if (!value.contains('@')) return 'Correo inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _companyController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del consultorio *',
                          prefixIcon: Icon(Icons.business_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Campo obligatorio'
                            : null,
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
                                : const Icon(Icons.save_outlined, size: 18),
                            label: const Text('Guardar cambios'),
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
}
