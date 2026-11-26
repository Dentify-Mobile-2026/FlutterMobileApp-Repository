import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/iam/presentation/di/presentation_module.dart';
import 'package:dentify_flutter/iam/presentation/viewmodel/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileView extends ConsumerStatefulWidget {
  final ProfileViewModel viewModel;
  const ProfileView({super.key, required this.viewModel});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileViewModelProvider.notifier).fetchUserInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(profileViewModelProvider.select((state) => state.isLoading));
    final userInfo =
        ref.watch(profileViewModelProvider.select((state) => state.userInfo));
    final errorMessage = ref
        .watch(profileViewModelProvider.select((state) => state.errorMessage));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userInfo != null
              ? SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mi Perfil',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const Text(
                          'Información de tu cuenta y consultorio dental',
                          style:
                              TextStyle(fontSize: 12.5, color: AppColors.muted),
                        ),
                        const SizedBox(height: 16),
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              'Error: $errorMessage',
                              style: const TextStyle(color: AppColors.danger),
                            ),
                          ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: AppColors.mint,
                                    child: Text(
                                      userInfo.fullName.isNotEmpty
                                          ? userInfo.fullName[0].toUpperCase()
                                          : 'D',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userInfo.fullName,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                        Text(
                                          userInfo.companyName,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              _infoRow(Icons.alternate_email, 'Usuario',
                                  userInfo.username),
                              _infoRow(Icons.email_outlined, 'Correo',
                                  userInfo.email),
                              _infoRow(Icons.business_outlined, 'Consultorio',
                                  userInfo.companyName),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () =>
                                  Navigator.pushNamed(context, 'update-info'),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('Editar Información'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => Navigator.pushNamed(
                                  context, 'update-password'),
                              icon: const Icon(Icons.lock_outline, size: 18),
                              label: const Text('Cambiar Contraseña'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => Navigator.pushNamed(
                                  context, 'business-hours'),
                              icon: const Icon(Icons.schedule_outlined, size: 18),
                              label: const Text('Horario de atención'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    errorMessage ??
                        'No se pudo cargar la información del perfil',
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.muted),
          const SizedBox(width: 10),
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
