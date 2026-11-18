import 'package:dentify_flutter/iam/presentation/di/presentation_module.dart';
import 'package:dentify_flutter/iam/presentation/viewmodel/profile_view_model.dart';
import 'package:dentify_flutter/iam/presentation/widgets/profile_field.dart';
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
    final isLoading = ref.watch(profileViewModelProvider.select((state) => state.isLoading));
    final userInfo = ref.watch(profileViewModelProvider.select((state) => state.userInfo));
    final errorMessage = ref.watch(profileViewModelProvider.select((state) => state.errorMessage));

    return Scaffold(
      backgroundColor: const Color(0xFFF5FFFD),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color.fromARGB(255, 204, 224, 245),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : userInfo != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Profile Information",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            "Error: $errorMessage",
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ProfileField(label: "Full Name", value: userInfo.fullName),
                      ProfileField(label: "Username", value: userInfo.username),
                      ProfileField(label: "Email", value: userInfo.email),
                      ProfileField(label: "Company", value: userInfo.companyName),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, 'update-info'),
                        icon: const Icon(Icons.edit),
                        label: const Text("Update Information"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C3E50),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, 'update-password'),
                        icon: const Icon(Icons.lock),
                        label: const Text("Change Password"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C3E50),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      errorMessage ?? "No se pudo cargar la información del perfil",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
      ),
    );
  }
}
