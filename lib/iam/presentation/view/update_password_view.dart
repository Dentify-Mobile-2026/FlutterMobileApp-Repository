import 'package:dentify_flutter/iam/presentation/di/presentation_module.dart';
import 'package:dentify_flutter/iam/presentation/viewmodel/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/dto/update_password_request.dart';

class UpdatePasswordView extends ConsumerWidget {
  final ProfileViewModel viewModel;

  const UpdatePasswordView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(profileViewModelProvider.notifier);
    final state = ref.watch(profileViewModelProvider);

    final currentPass = TextEditingController();
    final newPass = TextEditingController();
    final confirmPass = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF5FFFD),
      appBar: AppBar(
        title: const Text('Change Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2C3E50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            const Text(
              'Update Your Password',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 24),
            _buildPasswordInput("Current Password", currentPass),
            const SizedBox(height: 16),
            _buildPasswordInput("New Password", newPass),
            const SizedBox(height: 16),
            _buildPasswordInput("Confirm Password", confirmPass),
            const SizedBox(height: 24),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ElevatedButton.icon(
              onPressed: () async {
                if (newPass.text != confirmPass.text) {
                  viewModel.setError("Passwords do not match.");
                  return;
                }

                await viewModel.updatePassword(
                  UpdatePasswordRequest(oldPassword: currentPass.text, newPassword: newPass.text),
                );

                if (ref.read(profileViewModelProvider).errorMessage == null && context.mounted) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.lock_reset),
              label: const Text("Update Password"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C3E50),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2C3E50)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2C3E50), width: 1.5),
        ),
      ),
    );
  }
}
